//
//  NSObject+DSKeyValueObservingPrivate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+DSKeyValueObservingPrivate.h"
#import "DSKeyValueObservationInfo.h"
#import "DSKeyValueObservance.h"
#import "DSKeyValueChangeDictionary.h"
#import "DSKeyValueObserverCommon.h"
#import "DSKeyValueCodingCommon.h"
#import "NSObject+DSKeyValueObserverNotification.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueObservingCustomization.h"

const void *DSKVOPendingNotificationRetain(CFAllocatorRef allocator, const void *value) {
    DSKVOPendingChangeNotificationPerThread *notification = (DSKVOPendingChangeNotificationPerThread *)value;
    notification->retainCount ++;
    return notification;
}

void DSKVOPendingNotificationRelease(CFAllocatorRef allocator, const void *value) {
    DSKVOPendingChangeNotificationPerThread *notification = (DSKVOPendingChangeNotificationPerThread *)value;
    notification->retainCount --;
    if (notification->retainCount <= 0) {
        [notification->observance.observer release];
        [notification->affectingValuesMap release];
        [notification->changingValue release];
        [notification->extraData release];
        [notification->indexes release];
        [notification->newValue release];
        [notification->oldValue release];
        [notification->observationInfo release];
        [notification->keyOrKeys release];
        [notification->object release];
        
        free(notification);
    }
}

const CFArrayCallBacks DSKVOPendingNotificationArrayCallbacks = {
    0,
    DSKVOPendingNotificationRetain,
    DSKVOPendingNotificationRelease
};


@implementation NSObject (DSKeyValueObservingPrivate)

- (void)_d_changeValueForKey:(NSString *)key usingBlock:(void (^)())block {
    [self _d_changeValueForKeys:&key count:1 maybeOldValuesDict:nil usingBlock:block];
}

- (void)_d_changeValueForKey:(NSString *)key1 key:(NSString *)key2 key:(NSString *)key3 usingBlock:(void (^)(void))block {
    NSString *keys[3];
    keys[0] = key1;
    keys[1] = key2;
    keys[2] = key3;
    [self _d_changeValueForKeys:keys count:3 maybeOldValuesDict:nil usingBlock:block];
}

- (void)_d_changeValueForKeys:(NSString * *)keys count:(NSUInteger)keyCount maybeOldValuesDict:(id)oldValuesDict usingBlock:(void (^)(void))block {
    
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *observationInfo = self.d_observationInfo;
    [observationInfo retain];
    
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *implicitObservationInfo = [self _d_implicitObservationInfo];
    
    NSUInteger observationCount = 0;
    NSUInteger implicitObservationInfoCount = 0;
    NSUInteger totalObservationCount = 0;
    
    if(observationInfo) {
        observationCount = _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    if(implicitObservationInfo) {
        implicitObservationInfoCount  = _DSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservationCount = observationCount + implicitObservationInfoCount;
    
    DSKeyValueObservance * observances[totalObservationCount];
    if(observationInfo) {
        _DSKeyValueObservationInfoGetObservances(observationInfo, observances,observationCount);
    }
    if(implicitObservationInfo) {
        _DSKeyValueObservationInfoGetObservances(observationInfo, observances + observationCount,implicitObservationInfoCount);
    }
    
    for (NSUInteger i = 0; i < totalObservationCount; ++i) {
        if(!object_isClass(observances[i].observer)) {
            observances[i] = [observances[i].observer retain];
        }
        else {
            observances[i] = nil;
        }
    }

    _DSKeyValueObserverRegistrationLockOwner = NULL;
    
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    DSKVOPendingChangeNotificationLocal notifications[16] = {0x00};

    DSKVOPushInfoLocal pushInfo = {0};
    
    if(observationInfo || implicitObservationInfo) {
        //loc_12A3AA
        pushInfo.capacity = 16;
        pushInfo.notificationsInStack = YES;
        pushInfo.notifications = notifications;
        pushInfo.notificationCount = 0;
        pushInfo.unknow_1 = YES;
        pushInfo.unknow_2 = 0;
        
        if(observationInfo && keyCount) {
            for (NSUInteger i = 0; i < keyCount; ++i) {
                NSString *key = keys[i];
                if(key) {
                    DSKeyValueWillChange(self, key, NO,observationInfo,(DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetting,oldValuesDict,(DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationLocal,&pushInfo,nil);
                }
            }
        }
        
        if(implicitObservationInfo && keyCount >= 1) {
            for (NSInteger i = (keyCount - 1); i >= 0; --i) {
                NSString *key = keys[i];
                if(key) {
                    DSKeyValueWillChange(self, key,NO,implicitObservationInfo,(DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetting,oldValuesDict,(DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationLocal,&pushInfo,nil);
                }
            }
        }
    }
    
    if(block) {
        block();
    }
    
    DSKVOPopInfoLocal popInfo = {0};
    
    if(pushInfo.notificationCount > 0) {
        popInfo.notifications = pushInfo.notifications;
        popInfo.notificationCount = pushInfo.notificationCount;
        popInfo.observer = 0;
        popInfo.oldValue = 0;
        popInfo.lastChangingValue = 0;
        popInfo.observationInfo = observationInfo;
        
        DSKeyValueDidChange(self,nil,NO,(DSKVODidChangeDetailSetupFunc)DSKeyValueDidChangeBySetting,(DSKVODidChangeNotificationPopFunc)DSKeyValuePopPendingNotificationLocal,&popInfo);
    }
    //loc_12A552
    [observationInfo release];
    //loc_12A587
    for (int i = 0; i < totalObservationCount; ++i) {
        [observances[i] release];
    }

    //loc_12A59B
    if(notifications != pushInfo.notifications) {
        //说明在push的过程中在堆上分配了新的内存
        free(pushInfo.notifications);
    }
}

- (id)_d_implicitObservationInfo {
    return nil;
}

- (CFMutableArrayRef)_d_pendingChangeNotificationsArrayForKey:(NSString *)key create:(BOOL)create {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    CFMutableArrayRef pendingArray = NULL;
    if (TSD) {
        pendingArray = TSD->pendingArray;
    }
    if (create && !pendingArray) {
        if(!TSD) {
            TSD =  NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
            _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
        }
        if(!TSD->pendingArray) {
            TSD->pendingArray = CFArrayCreateMutable(NULL,0,&DSKVOPendingNotificationArrayCallbacks);
        }
        pendingArray = TSD->pendingArray;
    }
    
    return pendingArray;
}

+ (BOOL)_d_shouldAddObservationForwardersForKey:(NSString *)key {
    return YES;
}


@end

void DSKeyValueObservingTSDDestroy(void *data) {
    CFTypeRef pendingArray = ((DSKeyValueObservingTSD *)data)->pendingArray;
    if(pendingArray) {
        CFRelease(pendingArray);
    }
    free(data);
}

ImplicitObservanceAdditionInfo *DSKeyValueGetImplicitObservanceAdditionInfo() {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if(!TSD) {
        TSD = (DSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
        _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
    }
    return &TSD->implicitObservanceAdditionInfo;
}

ImplicitObservanceRemovalInfo *DSKeyValueGetImplicitObservanceRemovalInfo() {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if(!TSD) {
        TSD = (DSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
        _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
    }
    return &TSD->implicitObservanceRemovalInfo;
}

