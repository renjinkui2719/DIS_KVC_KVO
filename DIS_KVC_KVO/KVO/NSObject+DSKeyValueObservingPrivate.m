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
#import "NSObject+DSKeyValueObserverNotification.h"
#import "DSKeyValueChangeDictionary.h"
#import "DSKeyValueObserverCommon.h"
#import "DSKeyValueCodingCommon.h"
#import "NSObject+DSKeyValueObserverRegistration.h"

extern pthread_mutex_t _DSKeyValueObserverRegistrationLock;
extern OSSpinLock DSKeyValueObservationInfoSpinLock;
extern pthread_t  _DSKeyValueObserverRegistrationLockOwner;

extern dispatch_once_t isVMWare_onceToken;
extern BOOL isVMWare_doWorkarounds;

const void *DSKVOPendingNotificationRetain(CFAllocatorRef allocator, const void *value) {
    DSKVOPendingChangeNotification *ntf = (DSKVOPendingChangeNotification *)value;
    ntf->retainCount ++;
    return ntf;
}

void DSKVOPendingNotificationRelease(CFAllocatorRef allocator, const void *value) {
    DSKVOPendingChangeNotification *ntf = (DSKVOPendingChangeNotification *)value;
    ntf->retainCount --;
    if (ntf->retainCount <= 0) {
        if (ntf->observance) {
            dispatch_once(&isVMWare_onceToken, ^{
                isVMWare_doWorkarounds =  _CFAppVersionCheckLessThan("com.vmware.fusion", 5, 0, 0x0BFF00000);
            });
            if(!isVMWare_doWorkarounds) {
                [ntf->observance.observer release];
            }
        }
        [ntf->forwardingValues_p2 release];
        [ntf->forwardingValues_p1 release];
        [ntf->extraData release];
        [ntf->indexes release];
        [ntf->newValue release];
        [ntf->oldValue release];
        [ntf->observationInfo release];
        [ntf->keyOrKeys release];
        [ntf->object release];
        
        free(ntf);
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
    
    DSKeyValueObservationInfo *observationInfo = self.observationInfo;
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
    
    if(totalObservationCount) {
        NSUInteger i = 0;
        do{
            if(!object_isClass(observances[i].observer)) {
                observances[i] = [observances[i].observer retain];
            }
            else {
                observances[i] = nil;
            }
        }while(++i != totalObservationCount);
    }
    //loc_12A374
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    unsigned char detailsBuff[16 * sizeof(DSKVOPendingInfoLocalDetail)];
    memset(detailsBuff, 0, sizeof(detailsBuff));
    
    DSKVOPendingInfoLocalPush pendingInfoPush = {0};
    
    if(observationInfo && implicitObservationInfo) {
        //loc_12A3AA
        pendingInfoPush.capacity = 16;
        pendingInfoPush.isStackBuff = YES;
        pendingInfoPush.detailsBuff = (DSKVOPendingInfoLocalDetail *)detailsBuff;
        pendingInfoPush.detailsCount = 0;
        pendingInfoPush.p5 = YES;
        pendingInfoPush.p6 = 0;
        if(observationInfo && keyCount) {
            NSUInteger i = 0;
            do {
                NSString *key = keys[i];
                if(key) {
                    DSKeyValueWillChange(self, key, NO,observationInfo,DSKeyValueWillChangeBySetting,oldValuesDict,(DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationLocal,&pendingInfoPush,nil);
                }
            }while(++i != keyCount);
        }
        if(implicitObservationInfo && keyCount >= 1) {
            NSUInteger i = keyCount - 1;
            do {
                NSString *key = keys[i];
                if(key) {
                    DSKeyValueWillChange(self, key,NO,implicitObservationInfo,DSKeyValueWillChangeBySetting,oldValuesDict,(DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationLocal,&pendingInfoPush,nil);
                }
            }while((NSInteger)(--i) >= 0);
        }
    }
    if(block) {
        block();
    }
    DSKVOPendingInfoLocalPop pendingInfoPop = {0};
    if(pendingInfoPush.detailsCount > 0) {
        pendingInfoPop.detailsBuff = (DSKVOPendingInfoLocalDetail *)detailsBuff;
        pendingInfoPop.detailsCount = pendingInfoPush.detailsCount;
        pendingInfoPop.observer = 0;
        pendingInfoPop.oldValue = 0;
        pendingInfoPop.forwardValues_p1 = 0;
        pendingInfoPop.observationInfo = observationInfo;
        DSKeyValueDidChange(self,nil,NO,DSKeyValueDidChangeBySetting,(DSKeyValuePopPendingNotificationCallback)DSKeyValuePopPendingNotificationLocal,&pendingInfoPop);
    }
    //loc_12A552
    [observationInfo release];
    //loc_12A587
    if(totalObservationCount) {
        NSUInteger i = 0;
        do{
            [observances[i] release];
        }while(++i != totalObservationCount);
    }
    //loc_12A59B
    if(detailsBuff != (unsigned char *)pendingInfoPush.detailsBuff) {
        free(pendingInfoPush.detailsBuff);
    }
}

- (id)_d_implicitObservationInfo {
    return nil;
}

- (void)_d_notifyObserversForKeyPath:(NSString *)keyPath change:(DSKeyValueChangeDictionary *)change {
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    DSKeyValueObservationInfo *observationInfo = self.observationInfo;
    [observationInfo retain];
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    
    
    if(observationInfo) {
        DSKeyValueChangeDetails changeDetails = {0};
        DSKeyValueChangeDictionary *resultChange = nil;
        
        NSUInteger observanceCount =  _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
        DSKeyValueObservance *observance_objs[observanceCount];
        _DSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observanceCount);
        
        if(observanceCount) {
            //loc_B4385
            NSUInteger i = 0;
            DSKeyValueObservance *observance = nil;
            NSString *restOfKeyPath = nil;
            NSUInteger restOfKeyPathLength = 0;
            
            do {
                observance = observance_objs[i];
                
                restOfKeyPath = [observance.property restOfKeyPathIfContainedByValueForKeyPath:keyPath];
                
                if(restOfKeyPath) {
                    
                    restOfKeyPathLength = [restOfKeyPath length];
                    changeDetails.kind = [[change objectForKey:DSKeyValueChangeKindKey] integerValue];
                    
                    if(observance.options & DSKeyValueObservingOptionOld) {
                       //loc_B4509
                       id value =  [change objectForKey:DSKeyValueChangeOldKey];
                        if(restOfKeyPathLength) {
                           value =  [value valueForKeyPath:restOfKeyPath];
                        }
                        if(!value) {
                            value = [NSNull null];
                        }
                        changeDetails.oldValue = value;
                    }
                    else {
                        //loc_B455A
                        changeDetails.oldValue = nil;
                    }
                    //loc_B455A
                    if(observance.options & DSKeyValueObservingOptionNew) {
                        //loc_B4574
                        id value = [change objectForKey:DSKeyValueChangeNewKey];
                        if(restOfKeyPathLength) {
                            value = [value valueForKeyPath:restOfKeyPath];
                        }
                        if(!value) {
                            value = [NSNull null];
                        }
                        changeDetails.newValue = value;
                        //loc_B45BE
                    }
                    else {
                        //loc_B45BE
                        changeDetails.newValue = nil;
                    }
                    //loc_B45BE
                    changeDetails.indexes = [change objectForKey:DSKeyValueChangeIndexesKey];
                    changeDetails.extraData = nil;
                    
                    DSKeyValueNotifyObserver(observance.observer,
                                             [observance.property keyPath],
                                             self,
                                             observance.context,
                                             observance.originalObservable,
                                             NO,
                                             changeDetails,
                                             &resultChange
                                             );
                    //loc_B4663
                }
                else {
                    //loc_B4409
                    if([observance.property matchesWithoutOperatorComponentsKeyPath:keyPath]) {
                        changeDetails.kind = [[change objectForKey:DSKeyValueChangeKindKey] integerValue];
                        changeDetails.oldValue = nil;
                        changeDetails.newValue = nil;
                        changeDetails.indexes = [change objectForKey:DSKeyValueChangeIndexesKey];
                        changeDetails.extraData = nil;
                        
                        DSKeyValueNotifyObserver(observance.observer,
                                                 [observance.property keyPath],
                                                 self,
                                                 observance.context,
                                                 observance.originalObservable,
                                                 NO,
                                                 changeDetails,
                                                 &resultChange
                                                 );
                        //loc_B4663
                    }
                }
                //loc_B4663
                
            }while(++i != observanceCount);
            //loc_B4678
        }
        //loc_B4678
        [resultChange release];
        [observationInfo release];
    }
}

- (void)_d_willChangeValuesForKeys:(id)keys {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    DSKeyValueObservationInfo *observationInfo = self.observationInfo;
    [observationInfo retain];
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *implicitObservationInfo  = [self _d_implicitObservationInfo];
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
    
    if(totalObservationCount) {
        NSUInteger i = 0;
        do{
            if(!object_isClass(observances[i].observer)) {
                observances[i] = [observances[i].observer retain];
            }
            else {
                observances[i] = nil;
            }
        }while(++i != totalObservationCount);
    }

    //loc_129910
    _DSKeyValueObserverRegistrationLockOwner = nil;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    if(observationInfo || implicitObservationInfo) {
        DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
        if(!TSD) {
            TSD =  NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
            _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
        }
        if(!TSD->pendingArray) {
            TSD->pendingArray = CFArrayCreateMutable(NULL,0,&DSKVOPendingNotificationArrayCallbacks);
        }
        
        DSKVOPendingInfoPerThreadPush pendingInfo = {0};
        //loc_12998F
        if(observationInfo) {
            pendingInfo.pendingArray = TSD->pendingArray;
            pendingInfo.count = 1;
            pendingInfo.observationInfo = observationInfo;
            DSKeyValueWillChange(self, keys, YES, observationInfo, DSKeyValueWillChangeBySetting, nil,  (DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
            //loc_1299DA
        }
        //loc_1299DA
        if(implicitObservationInfo) {
            pendingInfo.observationInfo = nil;
            DSKeyValueWillChange(self, keys, YES, implicitObservationInfo, DSKeyValueWillChangeBySetting, nil,  (DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
        }
        //loc_129A1C
    }
    else {
        //loc_129A1C
    }
    //loc_129A1C
    [observationInfo release];
    
    if(totalObservationCount) {
        NSUInteger i = 0;
        do{
            [observances[i] release];
        }while(++i != totalObservationCount);
    }
}

- (void)_d_didChangeValuesForKeys:(id)keys {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    
    if(TSD && TSD->pendingArray && CFArrayGetCount(TSD->pendingArray) > 0) {
        DSKVOPendingInfoPerThreadPop pendingInfo = {0};
        pendingInfo.pendingArray = TSD->pendingArray;
        pendingInfo.pendingCount = CFArrayGetCount(TSD->pendingArray);
        pendingInfo.lastPopedNotification = nil;
        pendingInfo.lastPopdIndex = -1;
        pendingInfo.observance = nil;
        
        DSKeyValueDidChange(self, keys, YES, DSKeyValueDidChangeBySetting, (DSKeyValuePopPendingNotificationCallback)DSKeyValuePopPendingNotificationPerThread,&pendingInfo);
    }
}

- (void)_d_notifyObserversOfChangeFromValuesForKeys:(NSDictionary *)fromValueForKeys toValuesForKeys:(NSDictionary *)toValueForKeys {
    
    NSUInteger fromCount = [fromValueForKeys count];
    NSUInteger toCount = [fromValueForKeys count];
    
    NSUInteger countSum = fromCount + toCount;
    if((NSInteger)(countSum) < 0) {
        [NSException raise:NSGenericException format:@"*** attempt to create a temporary id buffer which is too large or with a negative count (%lu) -- possibly data is corrupt", countSum];
    }
    
    NSUInteger buff_size = (countSum <= 100 ? ((countSum > 0 ? countSum : 1)) : 1);
    id keys_buff[buff_size];
    
    id *keys = keys_buff;
    
    if(countSum > 0x100) {
        keys = NSAllocateObjectArray(countSum);
        if(!keys) {
            [NSException raise:NSMallocException format:@"*** attempt to create a temporary id buffer of length (%lu) failed", countSum];
        }
        //loc_129C49
    }
    else {
        memset(keys, 0, buff_size * sizeof(id));
        //loc_129C49
    }
    
    __block NSInteger index = 0;
    //loc_129C49
    [toValueForKeys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if(![fromValueForKeys objectForKey:key]) {
            keys[index++] = key;
        }
    }];
    
    __block NSInteger p1 = 0;
    __block NSInteger p2 = 0;
    __block NSInteger p3 = 0;
    [fromValueForKeys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
    }];
}

- (CFMutableArrayRef)_d_pendingChangeNotificationsArrayForKey:(NSString *)key create:(BOOL)create {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if(create) {
        if(TSD->pendingArray) {
            return TSD->pendingArray;
        }
        if(!TSD) {
            TSD =  NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
            _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
        }
        if(!TSD->pendingArray) {
            TSD->pendingArray = CFArrayCreateMutable(NULL,0,&DSKVOPendingNotificationArrayCallbacks);
        }
        return TSD->pendingArray;
    }
    else {
        return TSD ? TSD->pendingArray : NULL;
    }
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

