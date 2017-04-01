//
//  NSObject+NSKeyValueObserverNotification.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/20.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+NSKeyValueObserverNotification.h"
#import "NSKeyValueObservationInfo.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import "NSKeyValueObservance.h"
#import "NSKeyValueProperty.h"
#import "NSKeyValueChangeDictionary.h"
#import "NSKeyValueContainerClass.h"
#import "NSKeyValueObserverCommon.h"
#import <pthread.h>
#import <objc/runtime.h>

extern pthread_mutex_t _NSKeyValueObserverRegistrationLock;
extern pthread_t _NSKeyValueObserverRegistrationLockOwner;
extern OSSpinLock NSKeyValueObservationInfoSpinLock;
extern BOOL _NSKeyValueObserverRegistrationEnableLockingAssertions;
extern dispatch_once_t isVMWare_onceToken;
extern BOOL isVMWare_doWorkarounds;


@implementation NSObject (NSKeyValueObserverNotification)

- (void)willChangeValueForKey:(NSString *)key {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *observationInfo = self.observationInfo;
    [observationInfo retain];
    
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *implicitObservationInfo = [self _implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    NSKeyValueObservance *observance_objs[totalObservanceCount];
    if(observationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observationInfoObservanceCount);
    }
    if(implicitObservationInfo) {
        _NSKeyValueObservationInfoGetObservances(implicitObservationInfo, observance_objs + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observance_objs[i].observer)) {
            observance_objs[i] = [observance_objs[i].observer retain];
        }
        else {
            observance_objs[i] = nil;
        }
    }

    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
    
    if(observationInfo || implicitObservationInfo) {
        CFMutableArrayRef pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:YES];
        if(observationInfo) {
            NSKVOPendingInfoPerThreadPush pendingInfo = {pendingArray, 1, observationInfo};
            NSKeyValueWillChange(self,key,NO,observationInfo,NSKeyValueWillChangeBySetting,nil,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread,&pendingInfo,nil);
        }
        if(implicitObservationInfo) {
            NSKVOPendingInfoPerThreadPush pendingInfo = {pendingArray, 1, NULL};
            NSKeyValueWillChange(self,key,NO,implicitObservationInfo,NSKeyValueWillChangeBySetting,nil,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread,&pendingInfo,nil);
        }
    }
    [observationInfo release];
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

- (void)didChangeValueForKey:(NSString *)key {
    CFMutableArrayRef pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount) {
            NSKVOPendingInfoPerThreadPop pendingInfo = {pendingArray, pendingCount, NULL, ~0, 0};
            NSKeyValueDidChange(self,key,0,NSKeyValueDidChangeBySetting,(NSKeyValuePopPendingNotificationCallback)NSKeyValuePopPendingNotificationPerThread,&pendingInfo);
        }
    }
}

- (void)willChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    NSKeyValueObservationInfo *observationInfo = [(id)self.observationInfo retain];
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *implicitObservationInfo = [self _implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    NSKeyValueObservance *observance_objs[totalObservanceCount];
    
    if(observationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observationInfoObservanceCount);
    }
    
    if(implicitObservationInfo) {
        _NSKeyValueObservationInfoGetObservances(implicitObservationInfo, observance_objs + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observance_objs[i].observer)) {
            observance_objs[i] = [observance_objs[i].observer retain];
        }
        else {
            observance_objs[i] = nil;
        }
    }
    
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
    
    if (observationInfo || implicitObservationInfo) {
        NSKVOPendingInfoPerThreadPush pendingInfo = {0};
        pendingInfo.pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:YES];
        pendingInfo.count = 1;
        pendingInfo.observationInfo = observationInfo;
        
        NSKVOArrayOrSetWillChangeInfo changeInfo = {changeKind, indexes};
        
        if (observationInfo) {
            NSKeyValueWillChange(self, key, NO, observationInfo, NSKeyValueWillChangeByOrderedToManyMutation, &changeInfo, NSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
        }
        if (implicitObservationInfo) {
            pendingInfo.observationInfo = NULL;
            NSKeyValueWillChange(self, key, NO, implicitObservationInfo, NSKeyValueWillChangeByOrderedToManyMutation, &changeInfo, NSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
        }
    }
    
    [observationInfo release];
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    CFMutableArrayRef pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            NSKVOPendingInfoPerThreadPop pendingInfo = {pendingArray, pendingCount, NULL, ~0, 0};
            NSKeyValueDidChange(self,key,NO,NSKeyValueDidChangeByOrderedToManyMutation,(NSKeyValuePopPendingNotificationCallback)NSKeyValuePopPendingNotificationPerThread,&pendingInfo);
        }
    }
}

- (void)willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    NSKeyValueObservationInfo *observationInfo = [(id)self.observationInfo retain];
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *implicitObservationInfo = [self _implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    NSKeyValueObservance *observance_objs[totalObservanceCount];
    
    if(observationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observationInfoObservanceCount);
    }
    
    if(implicitObservationInfo) {
        _NSKeyValueObservationInfoGetObservances(implicitObservationInfo, observance_objs + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observance_objs[i].observer)) {
            observance_objs[i] = [observance_objs[i].observer retain];
        }
        else {
            observance_objs[i] = nil;
        }
    }
    
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
    
    if (observationInfo || implicitObservationInfo) {
        NSKVOPendingInfoPerThreadPush pendingInfo = {0};
        pendingInfo.pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:YES];
        pendingInfo.count = 1;
        pendingInfo.observationInfo = observationInfo;
        if (observationInfo) {
            NSKeyValueWillChange(self, key, NO, observationInfo, NSKeyValueWillChangeBySetMutation, &mutationKind, NSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
        }
        if (implicitObservationInfo) {
            pendingInfo.observationInfo = NULL;
            NSKeyValueWillChange(self, key, NO, implicitObservationInfo, NSKeyValueWillChangeBySetMutation, &mutationKind, NSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
        }
    }
    [observationInfo release];
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

- (void)didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {
    CFMutableArrayRef pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            NSKVOPendingInfoPerThreadPop pendingInfo = {pendingArray, pendingCount, NULL, ~0, 0};
            NSKeyValueDidChange(self,key,NO,NSKeyValueDidChangeBySetMutation,(NSKeyValuePopPendingNotificationCallback)NSKeyValuePopPendingNotificationPerThread,&pendingInfo);
        }
    }
}


void NSKeyValueObservingAssertRegistrationLockNotHeld() {
    if(_NSKeyValueObserverRegistrationEnableLockingAssertions && _NSKeyValueObserverRegistrationLockOwner == pthread_self()) {
        assert(pthread_self() != _NSKeyValueObserverRegistrationLockOwner);
    }
}

void NSKVONotify(id observer, NSString *keyPath, id object, NSKeyValueChangeDictionary *changeDictionary, void *context) {
    NSKeyValueObservingAssertRegistrationLockNotHeld();
    [observer observeValueForKeyPath:keyPath ofObject:object change:changeDictionary context:context];
}

void NSKeyValueNotifyObserver(id observer,NSString * keyPath, id object, void *context, id originalObservable, BOOL isPriorNotification, NSKeyValueChangeDetails changeDetails, NSKeyValueChangeDictionary **changeDictionary) {
    if([observer respondsToSelector:@selector(_observeValueForKeyPath:ofObject:changeKind:oldValue:newValue:indexes:context:)]) {
        
    }
    else {
        if(*changeDictionary) {
            [*changeDictionary setDetailsNoCopy:changeDetails originalObservable:originalObservable];
        }
        else {
            *changeDictionary =  [[NSKeyValueChangeDictionary alloc] initWithDetailsNoCopy:changeDetails originalObservable:originalObservable isPriorNotification:isPriorNotification];
        }
        NSUInteger retainCountBefore = [*changeDictionary retainCount];
        NSKVONotify(observer, keyPath, object, *changeDictionary, context);
        if(retainCountBefore != (NSUInteger)INTMAX_MAX && retainCountBefore != [*changeDictionary retainCount]) {
            [*changeDictionary retainObjects];
        }
    }
}

void NSKeyValueWillChangeForObservance(id originalObservable, id dependentValueKeyOrKeys, BOOL isASet, NSKeyValueObservance * observance) {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
   
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *observationInfo = [originalObservable observationInfo];
    [observationInfo retain];
    
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *implicitObservationInfo = [originalObservable _implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _NSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    NSKeyValueObservance *observance_objs[totalObservanceCount];
    if(observationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observationInfoObservanceCount);
    }
    if(implicitObservationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observance_objs + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    if(totalObservanceCount) {
        NSUInteger i = 0;
        do {
            if(!object_isClass(observance_objs[i].observer)) {
                observance_objs[i] = [observance_objs[i].observer retain];
            }
            else {
                observance_objs[i] = nil;
            }
        }while(++i != totalObservanceCount);
    }
    
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
    
    if(observationInfo && implicitObservationInfo) {
        NSKVOPendingInfoPerThreadPush pendingInfo;
        if(isASet) {
            NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
            if(!TSD) {
                TSD = NSAllocateScannedUncollectable(sizeof(NSKeyValueObservingTSD));
                _CFSetTSD(NSKeyValueObservingTSDKey, TSD, NSKeyValueObservingTSDDestroy);
            }
            if(!TSD->pendingArray) {
                TSD->pendingArray = CFArrayCreateMutable(NULL, 0, &NSKVOPendingNotificationArrayCallbacks);
            }
            pendingInfo.pendingArray = TSD->pendingArray;
        }
        else {
           //loc_CB341
            pendingInfo.pendingArray = [originalObservable _pendingChangeNotificationsArrayForKey:dependentValueKeyOrKeys create:YES];
        }
        //loc_CB357
        pendingInfo.count = 1;
        pendingInfo.observationInfo = observationInfo;
        if(observationInfo) {
            NSKeyValueWillChange(originalObservable,dependentValueKeyOrKeys,isASet,observationInfo,NSKeyValueWillChangeBySetting,nil,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread,&pendingInfo, observance);
        }
        //loc_CB3A0
        if(implicitObservationInfo) {
            NSKeyValueWillChange(originalObservable,dependentValueKeyOrKeys,isASet,implicitObservationInfo,NSKeyValueWillChangeBySetting,nil,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread,&pendingInfo, observance);
        }
        //loc_CB3EC
    }
    //loc_CB3EC
    [observationInfo release];
    if(totalObservanceCount) {
        NSUInteger i = 0 ;
        do {
            [observance_objs[i] release];
        }while(++i != totalObservanceCount);
    }
    //loc_CB427
}

void NSKeyValueDidChangeForObservance(id originalObservable, id dependentValueKeyOrKeys, BOOL isASet, NSKeyValueObservance * observance) {
    CFMutableArrayRef pendingArray = NULL;
    if(isASet) {
        NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
        if(TSD) {
            pendingArray = TSD->pendingArray;
        }
        return;
    }
    else {
        pendingArray = [originalObservable _pendingChangeNotificationsArrayForKey:dependentValueKeyOrKeys create:NO];
    }
    
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            NSKVOPendingInfoPerThreadPop pendingInfo = {
                pendingArray,
                pendingCount,
                nil,
                -1,
                observance
            };
            NSKeyValueDidChange(originalObservable, dependentValueKeyOrKeys, isASet, NSKeyValueDidChangeBySetting, (NSKeyValuePopPendingNotificationCallback)NSKeyValuePopPendingNotificationPerThread, &pendingInfo);
        }
        //loc_CB4D5
    }
    //loc_CB4D5
}

#pragma mark - Will change callbacks

void NSKeyValueWillChangeByOrderedToManyMutation(NSKeyValueChangeDetails *changeDetails, id object, NSString *affectedKeyPath, BOOL match, int options, NSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained) {
    if (match) {
        id oldValue = nil;
        NSArray *oldObjects = nil;
        NSMutableData *oldObjectsData = nil;
        
        void *TSD1 = _CFGetTSD(0x20);
        void *TSD2 = _CFGetTSD(0x1F);
        if (!TSD1 || TSD1 != affectedKeyPath || TSD2 != object) {
            _CFSetTSD(0x1F, object, NULL);
            _CFSetTSD(0x20, affectedKeyPath, NULL);
            
            oldValue = [object valueForKey:affectedKeyPath];
            
            _CFSetTSD(0x1F, NULL, NULL);
            _CFSetTSD(0x20, NULL, NULL);
            
            if (oldValue) {
                if ([oldValue isKindOfClass:NSOrderedSet.self]) {
                    if (changeInfo->changeKind == NSKeyValueChangeReplacement || changeInfo->changeKind == NSKeyValueChangeInsertion) {
                        oldObjectsData = [[NSMutableData alloc] initWithLength:[oldValue count] * sizeof(id)];
                        void *bytes = oldObjectsData.mutableBytes;
                        [oldValue getObjects:bytes range:NSMakeRange(0, [oldValue count])];
                    }
                }
            }
        }
        if (options & NSKeyValueObservingOptionOld && changeInfo->changeKind != NSKeyValueChangeInsertion) {
            if (!oldValue) {
                oldValue = [object valueForKey:affectedKeyPath];
            }
            oldObjects = [oldValue objectsAtIndexes:changeInfo->indexes];
        }
            
        *detailsRetained = NO;
        
        changeDetails->kind = changeInfo->changeKind;
        if (oldObjects || !(options & 0x20)) {
            changeDetails->oldValue = oldObjects;
        }
        else {
            changeDetails->oldValue = oldValue;
        }
        changeDetails->newValue = nil;
        changeDetails->indexes = changeInfo->indexes;
        changeDetails->unknow1 = oldObjectsData;
    }
    else {
        id oldValue = nil;
        if (options & NSKeyValueObservingOptionOld) {
            oldValue = [object valueForKeyPath:affectedKeyPath];
        }
        if (!oldValue) {
            oldValue = [NSNull null];
        }
        
        *detailsRetained = NO;
        
        changeDetails->kind = NSKeyValueChangeSetting;
        changeDetails->oldValue = oldValue;
        changeDetails->newValue = nil;
        changeDetails->indexes = nil;
        changeDetails->unknow1 = nil;
    }
}

void NSKeyValueWillChangeBySetting(NSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, NSDictionary *oldValueDict, BOOL *detailsRetained) {
    id oldValue = nil;
    if(options & NSKeyValueObservingOptionOld) {
        if(oldValueDict) {
            oldValue = [oldValueDict objectForKey:keyPath];
        }
        else {
            oldValue = [object valueForKeyPath:keyPath];
        }
        
        if(!oldValue) {
            oldValue = [NSNull null];
        }
    }
    
    *detailsRetained = NO;
    
    changeDetails->kind = NSKeyValueChangeSetting;
    changeDetails->oldValue = oldValue;
    changeDetails->newValue = nil;
    changeDetails->indexes = nil;
    changeDetails->unknow1 = nil;
}

void NSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueChangeDetails changeDetails , NSKeyValuePropertyForwardingValues forwardingValues, NSKVOPendingInfoPerThreadPush *pendingInfo) {
    NSKVOPendingChangeNotification *pendingNotification = NSAllocateScannedUncollectable(sizeof(NSKVOPendingChangeNotification));
    pendingNotification->unknow1 = 1;
    pendingNotification->unknow2 = pendingInfo->count;
    pendingNotification->object = [object retain];
    pendingNotification->keyOrKeys = [keyOrKeys copy];
    pendingNotification->observationInfo = [pendingInfo->observationInfo retain];
    pendingNotification->observance = observance;
    pendingNotification->kind = changeDetails.kind;
    pendingNotification->oldValue = [changeDetails.oldValue retain];
    pendingNotification->newValue = [changeDetails.newValue retain];
    pendingNotification->indexes = [changeDetails.indexes retain];
    pendingNotification->changeDetails_unknow1 = [changeDetails.unknow1 retain];
    pendingNotification->forwardingValues_p1 = [forwardingValues.p1 retain];
    pendingNotification->forwardingValues_p2 = [forwardingValues.p2 retain];
    if(pendingNotification->observance) {
        dispatch_once(&isVMWare_onceToken, ^{
            isVMWare_doWorkarounds =  _CFAppVersionCheckLessThan("com.vmware.fusion", 5, 0, 0x0BFF00000);
        });
        if(!isVMWare_doWorkarounds) {
            [pendingNotification->observance.observer release];
        }
    }
    CFArrayAppendValue(pendingInfo->pendingArray, pendingNotification);
    NSKVOPendingNotificationRelease(0,pendingNotification);
}

void NSKeyValuePushPendingNotificationLocal(id object, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueChangeDetails changeDetails , NSKeyValuePropertyForwardingValues forwardingValues, NSKVOPendingInfoLocalPush *pendingInfo) {
    
    /*
     64 位下：
     (1) capicity * 72
     = capacity * 8 * 9 
     = capacity * 8 * (1 + 8)
     = capacity * 8 + capacity * 8 * 8
     = capacity << 3 + capacity << 6
     (2) 2 * capicity * 72 = capacity << 4 + capacity << 7
     
     32 位下：
     (1) capacity * 40
     = capcity * 8 * 5 
     = capacity * 8 * (1 + 4)
     = capacity * 8 + capacity * 8 * 4
     = capacity << 3 + capacity << 5
     (2) 2 * capacity * 40 = capacity << 4 + capacity << 6
     */
    
    //count 已经增长到 capacity
    if(pendingInfo->count == pendingInfo->capacity) {
        //扩容两倍
        pendingInfo->capacity = pendingInfo->count << 1;
        //detailsBuff来自栈(局部变量)
        if(pendingInfo->isStackBuff) {
            //分配新的内存
            void *detailsBuff = NSAllocateScannedUncollectable(
#if __LP64__
                                                               (pendingInfo->capacity << 4) + (pendingInfo->capacity << 7)
#else
                                                               (pendingInfo->capacity << 4) + (pendingInfo->capacity << 6)
#endif
                                                               );
            //将旧的detailsBuff拷贝到新buff
            memmove(detailsBuff, pendingInfo->detailsBuff,
#if __LP64__
                    (pendingInfo->count << 3) + (pendingInfo->count << 6)
#else
                    (pendingInfo->count << 3) + (pendingInfo->count << 5)
#endif
                    );
            pendingInfo->detailsBuff = detailsBuff;
            pendingInfo->isStackBuff = NO;
        }
        //detailsBuff来自堆
        else {
            //realloc内存
            void *detailsBuff = NSReallocateScannedUncollectable(pendingInfo->detailsBuff,
#if __LP64__
                                                                 (pendingInfo->capacity << 4) + (pendingInfo->capacity << 7)
#else
                                                                 (pendingInfo->capacity << 4) + (pendingInfo->capacity << 6)
#endif
                                                                 );
            pendingInfo->detailsBuff = detailsBuff;
        }
        //loc_4226A
        
    }
    
    //loc_42275
    uint8_t *start = (uint8_t *)pendingInfo->detailsBuff +
#if __LP64__
    (pendingInfo->count << 3) + (pendingInfo->count << 6)
#else
    (pendingInfo->count << 3) + (pendingInfo->count << 5)
#endif
    ;
    
    pendingInfo->count += 1;

    *((id *)start) = observance; start += sizeof(id);
    *((uint32_t *)start) = changeDetails.kind; start += sizeof(uint32_t);
    *((id *)start) = changeDetails.oldValue; start += sizeof(id);
    *((id *)start) = changeDetails.newValue; start += sizeof(id);
    *((id *)start) = changeDetails.indexes; start += sizeof(id);
    *((id *)start) = changeDetails.unknow1; start += sizeof(id);
    *((id *)start) = forwardingValues.p1; start += sizeof(id);
    *((id *)start) = forwardingValues.p2; start += sizeof(id);
    *((uint32_t *)start) = pendingInfo->p5; start += sizeof(uint32_t);
    *((id *)start) = keyOrKeys; start += sizeof(id);
    
    [changeDetails.oldValue retain];
    [forwardingValues.p1 retain];
    [observance.observer retain];
    
    /*
    edi = eax + eax * sizeof(id);
    *(buff + edi * 8) = observance;
    
    *(buff + edi * 8 + 0x04) = changeDetails.kind;
    *(buff + edi * 8 + 0x08) = changeDetails.oldValue;
    *(buff + edi * 8 + 0x0c) = changeDetails.newValue;
    *(buff + edi * 8 + 0x10) = changeDetails.indexes;
    *(buff + edi * 8 + 0x14) = changeDetails.unknow1;
    
    [*(buff + edi * 8 + 0x08) retain];
    
    *(buff + edi * 8 + 0x18) = forwardingValues.p1;
    *(buff + edi * 8 + 0x1C) = forwardingValues.p2;
    [forwardingValues.p1 retain];
    
    *(buff + edi * 8 + 0x20) = pendingInfo->p5;
    *(buff + edi * 8 + 0x24) = keyOrKeys;
    
    [*(buff + edi * 8) retain];
     */
    
}


void NSKeyValueWillChange(id object, id keyOrKeys, BOOL isASet, NSKeyValueObservationInfo *observationInfo, NSKeyValueWillChangeByCallback willChangeByCallback, void *changeInfo, NSKeyValuePushPendingNotificationCallback pushPendingNotificationCallback, void *pendingInfo, NSKeyValueObservance *observance) {
    NSUInteger observanceCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    
    NSKeyValueObservance *observanceBuff[observanceCount];
    _NSKeyValueObservationInfoGetObservances(observationInfo, observanceBuff, observanceCount);
    
    for (NSUInteger i = 0; i < observanceCount; ++i) {
        NSKeyValueObservance *eachObservance = observanceBuff[i];
        if(!observance || observance == eachObservance) {
            NSString* affectedKeyPath = nil;
            BOOL keyPathExactMatch = NO;
            NSKeyValuePropertyForwardingValues forwardingValues = {0};
            
            if(isASet) {
                affectedKeyPath = [eachObservance.property keyPathIfAffectedByValueForMemberOfKeys:keyOrKeys];
            }
            else {
                affectedKeyPath = [eachObservance.property keyPathIfAffectedByValueForKey:keyOrKeys exactMatch:&keyPathExactMatch];
            }
            
            if(affectedKeyPath) {
                if( [eachObservance.property object:object withObservance:eachObservance willChangeValueForKeyOrKeys:keyOrKeys recurse:YES forwardingValues:&forwardingValues] ) {
                    NSKeyValueChangeDetails changeDetails = {0};
                    BOOL detailsRetained;
                    NSKeyValueChangeDictionary *changeDictionary = nil;
                    
                    willChangeByCallback(&changeDetails, object, affectedKeyPath,keyPathExactMatch,eachObservance.options, changeInfo, &detailsRetained);
                    pushPendingNotificationCallback(object, keyOrKeys, eachObservance, changeDetails , forwardingValues, pendingInfo);
                    
                    if(eachObservance.options & NSKeyValueObservingOptionPrior) {
                        NSKeyValueNotifyObserver(eachObservance.observer, affectedKeyPath,  object, eachObservance.context, eachObservance.originalObservable, YES,changeDetails, &changeDictionary);
                    }
                    
                    if(detailsRetained) {
                        [changeDetails.oldValue release];
                        [changeDetails.newValue release];
                        [changeDetails.indexes release];
                        [changeDetails.unknow1 release];
                    }
                    
                    [changeDictionary release];
                }
            }
        }
    }
}

BOOL _NSKeyValueCheckObservationInfoForPendingNotification(id object, NSKeyValueObservance *observance, NSKeyValueObservationInfo * observationInfo) {
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *info = nil;
    if(observance.property.containerClass) {
        info = observance.property.containerClass.cachedObservationInfoImplementation(object, @selector(observationInfo));
    }
    else {
        info = [object observationInfo];
    }
    
    if(!info) {
        os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
        return NO;
    }
    
    if(info == observationInfo) {
        os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
        return YES;
    }
    
    BOOL contains = _NSKeyValueObservationInfoContainsObservance(info, observance);
    
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    return contains;
}

BOOL NSKeyValuePopPendingNotificationPerThread(id object,id keyOrKeys, NSKeyValueObservance **observance, NSKeyValueChangeDetails *changeDetails,NSKeyValuePropertyForwardingValues *forwardValues,id *findKeyOrKeys, NSKVOPendingInfoPerThreadPop* pendingInfo) {
    if(pendingInfo->notification) {
        CFArrayRemoveValueAtIndex(pendingInfo->pendingArray, pendingInfo->index);
        if(pendingInfo->notification->unknow2) {
            return NO;
        }
    }
    else {
        pendingInfo->index = pendingInfo->count;
    }
    
    for (NSInteger i = pendingInfo->count - 1; i >=0 ; --i) {
        NSKVOPendingChangeNotification *changeNotification = (NSKVOPendingChangeNotification *)CFArrayGetValueAtIndex(pendingInfo->pendingArray, i);
        if (changeNotification->object == object && [changeNotification->keyOrKeys isEqual:keyOrKeys] && (!pendingInfo->observance || changeNotification->observance == pendingInfo->observance)) {
            //loc_55958
            if (!changeNotification->observationInfo || _NSKeyValueCheckObservationInfoForPendingNotification(changeNotification->object,changeNotification->observance, changeNotification->observationInfo)) {
                //loc_559AE
                *observance = changeNotification->observance;
                
                changeDetails->kind = changeNotification->kind;
                changeDetails->oldValue = changeNotification->oldValue;
                changeDetails->newValue = changeNotification->newValue;
                changeDetails->indexes = changeNotification->indexes;
                changeDetails->unknow1 = changeNotification->changeDetails_unknow1;
                
                forwardValues->p1 = changeNotification->forwardingValues_p1;
                forwardValues->p2 = changeNotification->forwardingValues_p2;
                
                *findKeyOrKeys = keyOrKeys;
                
                pendingInfo->notification = changeNotification;
                pendingInfo->index = i;
                //loc_559A3
                return YES;
            }
            CFArrayRemoveValueAtIndex(pendingInfo->pendingArray, i);
            if (changeNotification->unknow2 != 0) {
                return NO;
            }
        }
    }
    return NO;
}

BOOL NSKeyValuePopPendingNotificationLocal(id object,id keyOrKeys, NSKeyValueObservance **observance, NSKeyValueChangeDetails *changeDetails,NSKeyValuePropertyForwardingValues *forwardValues,id *findKeyOrKeys, NSKVOPendingInfoLocalPop* pendingInfo) {
    
    [pendingInfo->observer release];
    [pendingInfo->oldValue release];
    [pendingInfo->forwardValues_p1 release];
    
    uint8_t *start = NULL;
    
    NSKeyValueObservance *observanceLocal = nil;
    NSKeyValueChange kind = 0;
    id oldValue = nil,newValue= nil,indexes= nil,observationInfo= nil;
    id forwardValues_p1 = nil,  forwardValues_p2 = nil;
    id keyOrKeysLocal = nil;
    
    if(pendingInfo->count > 0) {
        do {
            pendingInfo->count --;
            
            start = (uint8_t *)pendingInfo->detailsBuff +
#if __LP64__
            (pendingInfo->count << 3) + (pendingInfo->count << 6)
#else
            (pendingInfo->count << 3) + (pendingInfo->count << 5)
#endif
            ;

            observanceLocal = *((id *)start); start += sizeof(id);
            kind = *((uint32_t *)start); start += sizeof(uint32_t);
            oldValue = *((id *)start); start += sizeof(id);
            newValue = *((id *)start); start += sizeof(id);
            indexes = *((id *)start); start += sizeof(id);
            observationInfo = *((id *)start); start += sizeof(id);
            forwardValues_p1 = *((id *)start); start += sizeof(id);
            forwardValues_p2 = *((id *)start); start += sizeof(id);
            /*observance = *((id *)start);*/ start += sizeof(uint32_t);
            keyOrKeysLocal = *((id *)start); start += sizeof(id);
            
            if(observanceLocal) {
                if(!_NSKeyValueCheckObservationInfoForPendingNotification(object, observanceLocal, observationInfo)) {
                    [observanceLocal.observer release];
                    [oldValue release];
                    [forwardValues_p1 release];
                    
                    continue;
                }
            }
            
            *observance = observanceLocal;
            
            changeDetails->kind = kind;
            changeDetails->oldValue = oldValue;
            changeDetails->newValue = newValue;
            changeDetails->indexes = indexes;
            changeDetails->observationInfo = observationInfo;
            
            forwardValues->p1 = forwardValues_p1;
            forwardValues->p2 = forwardValues_p2;
            
            *findKeyOrKeys = keyOrKeysLocal;
            
            pendingInfo->observer = observanceLocal.observer;
            pendingInfo->oldValue = oldValue;
            pendingInfo->forwardValues_p1 = forwardValues_p1;

            
            /*
            //loc_4268F
            *observance = *(ebx+edi*8);
            
            changeDetails->kind = *(ebx+edi*8 + 0x04);
            changeDetails->oldValue = *(ebx+edi*8 + 0x08);
            changeDetails->newValue = *(ebx+edi*8 + 0x0C);
            changeDetails->indexes = *(ebx+edi*8 + 0x10);
            changeDetails->unknow1 = *(ebx+edi*8 + 0x14);
            
            forwardValues->p1 = *(ebx+edi*8 + 0x18);
            forwardValues->p2 = *(ebx+edi*8 + 0x1C);
            
            *findKeyOrKeys = *(ebx+edi*8 + 0x24);
            
            *(pendingInfo + 0x08) = *(ebx+edi*8).observer;
            *(pendingInfo + 0x0C) = *(ebx+edi*8 + 0x08);
            *(pendingInfo + 0x10) = *(ebx+edi*8 + 0x18);
            */
            return YES;
        }
        while((NSInteger)pendingInfo->count > 0);
    }
    return NO;
}

void NSKeyValueDidChangeBySetting(NSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL exactMatch, int options, NSKeyValueChangeDetails changeDetails) {
    id newValue = nil;
    if(exactMatch) {
        newValue = [object valueForKeyPath:keyPath];
        if(!newValue) {
            newValue = [NSNull null];
        }
    }
    else {
        newValue = changeDetails.newValue;
    }
    resultChangeDetails->kind = changeDetails.kind;
    resultChangeDetails->oldValue = changeDetails.oldValue;
    resultChangeDetails->newValue = newValue;
    resultChangeDetails->indexes = changeDetails.indexes;
    resultChangeDetails->unknow1 = changeDetails.unknow1;
}

void NSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,NSKeyValueDidChangeByCallback didChangeByCallback, NSKeyValuePopPendingNotificationCallback popPendingNotificationCallback, void *pendingInfo) {
    NSKeyValueObservance *observance = nil;
    NSKeyValueChangeDetails changeDetails = {0};
    NSKeyValuePropertyForwardingValues forwardValues = {0};
    id findKeyOrKeys = nil;
    NSKeyValueChangeDictionary *changeDictionary = nil;
    
    while(popPendingNotificationCallback(object, keyOrKeys, &observance, &changeDetails, &forwardValues, &findKeyOrKeys, pendingInfo)) {
        [observance.property object:object withObservance:observance didChangeValueForKeyOrKeys:findKeyOrKeys recurse:YES forwardingValues:forwardValues];
        BOOL exactMatch = NO;
        if(!isASet) {
            exactMatch = CFEqual(observance.property.keyPath, findKeyOrKeys);
        }
        
        NSKeyValueChangeDetails resultDetails = {0};
        
        didChangeByCallback(&resultDetails, object, observance.property.keyPath, exactMatch, observance.options, changeDetails);
        
        changeDetails = resultDetails;
        
        NSKeyValueNotifyObserver(observance.observer,observance.property.keyPath, object,observance.context,observance.originalObservable,NO,changeDetails, &changeDictionary);
    }
    
    [changeDictionary release];
}

@end
