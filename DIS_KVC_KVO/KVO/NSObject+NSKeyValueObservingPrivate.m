//
//  NSObject+NSKeyValueObservingPrivate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+NSKeyValueObservingPrivate.h"
#import "NSKeyValueObservationInfo.h"
#import "NSKeyValueObservance.h"
#import "NSObject+NSKeyValueObserverNotification.h"
#import "NSKeyValueChangeDictionary.h"
#import <objc/runtime.h>
#import <pthread.h>

extern pthread_mutex_t _NSKeyValueObserverRegistrationLock;
extern OSSpinLock NSKeyValueObservationInfoSpinLock;
extern pthread_t  _NSKeyValueObserverRegistrationLockOwner;

extern void os_lock_lock(void *);
extern void os_lock_unlock(void *);
extern void *_CFGetTSD(uint32_t slot);
extern void *_CFSetTSD(uint32_t slot, void *newVal,   void (*destructor)(void *));
extern void *NSAllocateScannedUncollectable(size_t);

void NSKVOPendingNotificationRetain(CFAllocatorRef allocator, const void *value) {
    //value->p1 ++;
}

void NSKVOPendingNotificationRelease(CFAllocatorRef allocator, const void *value) {
    
}

const CFArrayCallBacks NSKVOPendingNotificationArrayCallbacks = {
    0,
    NSKVOPendingNotificationRetain,
    NSKVOPendingNotificationRelease
};


@implementation NSObject (NSKeyValueObservingPrivate)

- (void)_changeValueForKey:(NSString *)key usingBlock:(void (^)())block {
    [self _changeValueForKeys:&key count:1 maybeOldValuesDict:nil usingBlock:block];
}

- (void)_changeValueForKey:(NSString *)key1 key:(NSString *)key2 key:(NSString *)key3 usingBlock:(void (^)(void))block {
    NSString *keys[3];
    keys[0] = key1;
    keys[1] = key2;
    keys[2] = key3;
    [self _changeValueForKeys:keys count:3 maybeOldValuesDict:nil usingBlock:block];
}

- (void)_changeValueForKeys:(NSString * *)keys count:(NSUInteger)keyCount maybeOldValuesDict:(id)oldValuesDict usingBlock:(void (^)(void))block {
    
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *observationInfo = self.observationInfo;
    [observationInfo retain];
    
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *implicitObservationInfo = [self _implicitObservationInfo];
    
    NSUInteger observationCount = 0;
    NSUInteger implicitObservationInfoCount = 0;
    NSUInteger totalObservationCount = 0;
    
    if(observationInfo) {
        observationCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    if(implicitObservationInfo) {
        implicitObservationInfoCount  = _NSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservationCount = observationCount + implicitObservationInfoCount;
    
    NSKeyValueObservance * observances[totalObservationCount];
    if(observationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observances,observationCount);
    }
    if(implicitObservationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observances + observationCount,implicitObservationInfoCount);
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
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
    
#if __LP64__
     unsigned char detailsBuff[1152]; //72 * 16
#else
     unsigned char detailsBuff[640]; //40 * 16
#endif
    memset(detailsBuff, 0, sizeof(detailsBuff));
    
    NSKVOPendingInfoLocalPush pendingInfoPush = {0};
    
    if(observationInfo && implicitObservationInfo) {
        //loc_12A3AA
        pendingInfoPush.capacity = 16;
        pendingInfoPush.isStackBuff = YES;
        pendingInfoPush.detailsBuff = detailsBuff;
        pendingInfoPush.count = 0;
        pendingInfoPush.p5 = YES;
        pendingInfoPush.p6 = 0;
        if(observationInfo && keyCount) {
            NSUInteger i = 0;
            do {
                NSString *key = keys[i];
                if(key) {
                    NSKeyValueWillChange(self, key, NO,observationInfo,NSKeyValueWillChangeBySetting,oldValuesDict,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationLocal,&pendingInfoPush,nil);
                }
            }while(++i != keyCount);
        }
        if(implicitObservationInfo && keyCount >= 1) {
            NSUInteger i = keyCount - 1;
            do {
                NSString *key = keys[i];
                if(key) {
                    NSKeyValueWillChange(self, key,NO,implicitObservationInfo,NSKeyValueWillChangeBySetting,oldValuesDict,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationLocal,&pendingInfoPush,nil);
                }
            }while((NSInteger)(--i) >= 0);
        }
    }
    if(block) {
        block();
    }
    NSKVOPendingInfoLocalPop pendingInfoPop = {0};
    if(pendingInfoPush.count > 0) {
        pendingInfoPop.detailsBuff = detailsBuff;
        pendingInfoPop.count = pendingInfoPush.count;
        pendingInfoPop.observer = 0;
        pendingInfoPop.oldValue = 0;
        pendingInfoPop.forwardValues_p1 = 0;
        pendingInfoPop.observationInfo = observationInfo;
        NSKeyValueDidChange(self,nil,NO,NSKeyValueDidChangeBySetting,(NSKeyValuePopPendingNotificationCallback)NSKeyValuePopPendingNotificationLocal,&pendingInfoPop);
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
    if(detailsBuff != pendingInfoPush.detailsBuff) {
        free(pendingInfoPush.detailsBuff);
    }
}

- (id)_implicitObservationInfo {
    return nil;
}

- (void)_notifyObserversForKeyPath:(NSString *)keyPath change:(NSKeyValueChangeDictionary *)change {
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    NSKeyValueObservationInfo *observationInfo = self.observationInfo;
    [observationInfo retain];
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    
    
    if(observationInfo) {
        NSKeyValueChangeDetails changeDetails = {0};
        NSKeyValueChangeDictionary *resultChange = nil;
        
        NSUInteger observanceCount =  _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
        NSKeyValueObservance *observance_objs[observanceCount];
        _NSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observanceCount);
        
        if(observanceCount) {
            //loc_B4385
            NSUInteger i = 0;
            NSKeyValueObservance *observance = nil;
            NSString *restOfKeyPath = nil;
            NSUInteger restOfKeyPathLength = 0;
            
            do {
                observance = observance_objs[i];
                
                restOfKeyPath = [observance.property restOfKeyPathIfContainedByValueForKeyPath:keyPath];
                
                if(restOfKeyPath) {
                    
                    restOfKeyPathLength = [restOfKeyPath length];
                    changeDetails.kind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
                    
                    if(observance.options & NSKeyValueObservingOptionOld) {
                       //loc_B4509
                       id value =  [change objectForKey:NSKeyValueChangeOldKey];
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
                    if(observance.options & NSKeyValueObservingOptionNew) {
                        //loc_B4574
                        id value = [change objectForKey:NSKeyValueChangeNewKey];
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
                    changeDetails.indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                    changeDetails.unknow1 = nil;
                    
                    NSKeyValueNotifyObserver(observance.observer,
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
                        changeDetails.kind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
                        changeDetails.oldValue = nil;
                        changeDetails.newValue = nil;
                        changeDetails.indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                        changeDetails.unknow1 = nil;
                        
                        NSKeyValueNotifyObserver(observance.observer,
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

- (void)_willChangeValuesForKeys:(id)keys {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    NSKeyValueObservationInfo *observationInfo = self.observationInfo;
    [observationInfo retain];
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservationInfo *implicitObservationInfo  = [self _implicitObservationInfo];
    NSUInteger observationCount = 0;
    NSUInteger implicitObservationInfoCount = 0;
    NSUInteger totalObservationCount = 0;
    
    if(observationInfo) {
        observationCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    if(implicitObservationInfo) {
        implicitObservationInfoCount  = _NSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservationCount = observationCount + implicitObservationInfoCount;
    
    NSKeyValueObservance * observances[totalObservationCount];
    if(observationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observances,observationCount);
    }
    if(implicitObservationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observances + observationCount,implicitObservationInfoCount);
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
    _NSKeyValueObserverRegistrationLockOwner = nil;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
    
    if(observationInfo || implicitObservationInfo) {
        NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
        if(!TSD) {
            TSD =  NSAllocateScannedUncollectable(sizeof(NSKeyValueObservingTSD));
            _CFSetTSD(NSKeyValueObservingTSDKey, TSD, NSKeyValueObservingTSDDestroy);
        }
        if(!TSD->pendingArray) {
            TSD->pendingArray = CFArrayCreateMutable(NULL,0,&NSKVOPendingNotificationArrayCallbacks);
        }
        
        NSKVOPendingInfoPerThreadPush pendingInfo = {0};
        //loc_12998F
        if(observationInfo) {
            pendingInfo.pendingArray = TSD->pendingArray;
            pendingInfo.count = 1;
            pendingInfo.observationInfo = observationInfo;
            NSKeyValueWillChange(self, keys, YES, observationInfo, NSKeyValueWillChangeBySetting, nil,  (NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
            //loc_1299DA
        }
        //loc_1299DA
        if(implicitObservationInfo) {
            pendingInfo.observationInfo = nil;
            NSKeyValueWillChange(self, keys, YES, implicitObservationInfo, NSKeyValueWillChangeBySetting, nil,  (NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread, &pendingInfo, nil);
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

- (void)_didChangeValuesForKeys:(id)keys {
    NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    
    if(TSD && TSD->pendingArray && CFArrayGetCount(TSD->pendingArray) > 0) {
        NSKVOPendingInfoPerThreadPop pendingInfo = {0};
        pendingInfo.pendingArray = TSD->pendingArray;
        pendingInfo.count = CFArrayGetCount(TSD->pendingArray);
        pendingInfo.notification = nil;
        pendingInfo.index = -1;
        pendingInfo.observance = nil;
        
        NSKeyValueDidChange(self, keys, YES, NSKeyValueDidChangeBySetting, (NSKeyValuePopPendingNotificationCallback)NSKeyValuePopPendingNotificationPerThread,&pendingInfo);
    }
}

- (void)_notifyObserversOfChangeFromValuesForKeys:(NSDictionary *)fromValueForKeys toValuesForKeys:(NSDictionary *)toValueForKeys {
    
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

- (CFMutableArrayRef)_pendingChangeNotificationsArrayForKey:(NSString *)key create:(BOOL)create {
    NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    if(create) {
        if(TSD->pendingArray) {
            return TSD->pendingArray;
        }
        if(!TSD) {
            TSD =  NSAllocateScannedUncollectable(sizeof(NSKeyValueObservingTSD));
            _CFSetTSD(NSKeyValueObservingTSDKey, TSD, NSKeyValueObservingTSDDestroy);
        }
        if(!TSD->pendingArray) {
            TSD->pendingArray = CFArrayCreateMutable(NULL,0,&NSKVOPendingNotificationArrayCallbacks);
        }
        return TSD->pendingArray;
    }
    else {
        return TSD ? TSD->pendingArray : NULL;
    }
}

+ (BOOL)_shouldAddObservationForwardersForKey:(NSString *)key {
    return YES;
}


@end

void NSKeyValueObservingTSDDestroy(void *data) {
    CFTypeRef pendingArray = ((NSKeyValueObservingTSD *)data)->pendingArray;
    if(pendingArray) {
        CFRelease(pendingArray);
    }
    free(data);
}

ImplicitObservanceAdditionInfo *NSKeyValueGetImplicitObservanceAdditionInfo() {
    NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    if(!TSD) {
        TSD = (NSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(NSKeyValueObservingTSD));
        _CFSetTSD(NSKeyValueObservingTSDKey, TSD, NSKeyValueObservingTSDDestroy);
    }
    return &TSD->implicitObservanceAdditionInfo;
}

ImplicitObservanceRemovalInfo *NSKeyValueGetImplicitObservanceRemovalInfo() {
    NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    if(!TSD) {
        TSD = (NSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(NSKeyValueObservingTSD));
        _CFSetTSD(NSKeyValueObservingTSDKey, TSD, NSKeyValueObservingTSDDestroy);
    }
    return &TSD->implicitObservanceRemovalInfo;
}

