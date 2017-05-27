//
//  NSObject+DSKeyValueObserverNotification.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/20.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+DSKeyValueObserverNotification.h"
#import "DSKeyValueObservationInfo.h"
#import "DSKeyValueObservance.h"
#import "DSKeyValueProperty.h"
#import "DSKeyValueChangeDictionary.h"
#import "DSKeyValueContainerClass.h"
#import "DSKeyValueObserverCommon.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "NSObject+DSKeyValueObservingCustomization.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueCoding.h"


@implementation NSObject (DSKeyValueObserverNotification)

- (void)d_willChangeValueForKey:(NSString *)key {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *observationInfo = self.d_observationInfo;
    [observationInfo retain];
    
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *implicitObservationInfo = [self _d_implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    DSKeyValueObservance *observanceBuff[totalObservanceCount];
    if(observationInfo) {
        _DSKeyValueObservationInfoGetObservances(observationInfo, observanceBuff, observationInfoObservanceCount);
    }
    if(implicitObservationInfo) {
        _DSKeyValueObservationInfoGetObservances(implicitObservationInfo, observanceBuff + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observanceBuff[i].observer)) {
            observanceBuff[i] = [observanceBuff[i].observer retain];
        }
        else {
            observanceBuff[i] = nil;
        }
    }

    _DSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    if(observationInfo || implicitObservationInfo) {
        CFMutableArrayRef pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:YES];
        if(observationInfo) {
            DSKVOPushInfoPerThread pushInfo = {pendingArray, YES, observationInfo};
            LOG_KVO(@"object: %@, will change value for key: %@, observationInfo: %@, pushInfo: %@",simple_desc(self), key, simple_desc(observationInfo), NSStringFromPushInfoPerThread(&pushInfo));
            DSKeyValueWillChange(self,key,NO,observationInfo,(DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetting,nil,(DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread,&pushInfo,nil);
        }
        if(implicitObservationInfo) {
            DSKVOPushInfoPerThread pushInfo = {pendingArray, YES, NULL};
            LOG_KVO(@"object: %@, will change value for key: %@, implicitObservationInfo: %@, pushInfo: %@",simple_desc(self), key, simple_desc(implicitObservationInfo), NSStringFromPushInfoPerThread(&pushInfo));
            DSKeyValueWillChange(self,key,NO,implicitObservationInfo,(DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetting,nil,(DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread,&pushInfo,nil);
        }
    }
    
    [observationInfo release];
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observanceBuff[i] release];
    }
}

- (void)d_didChangeValueForKey:(NSString *)key {
    CFMutableArrayRef pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount) {
            DSKVOPopInfoPerThread popInfo = {pendingArray, pendingCount, nil, -1, nil};
            LOG_KVO(@"object: %@, did change value for key: %@, popInfo: %@",simple_desc(self), key, NSStringFromPopInfoPerThread(&popInfo));
            DSKeyValueDidChange(self,key,0,DSKeyValueDidChangeBySetting,(DSKVODidChangeNotificationPopFunc)DSKeyValuePopPendingNotificationPerThread,&popInfo);
        }
    }
}

- (void)d_willChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    DSKeyValueObservationInfo *observationInfo = [(id)self.d_observationInfo retain];
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *implicitObservationInfo = [self _d_implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    DSKeyValueObservance *observance_objs[totalObservanceCount];
    
    if(observationInfo) {
        _DSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observationInfoObservanceCount);
    }
    
    if(implicitObservationInfo) {
        _DSKeyValueObservationInfoGetObservances(implicitObservationInfo, observance_objs + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observance_objs[i].observer)) {
            observance_objs[i] = [observance_objs[i].observer retain];
        }
        else {
            observance_objs[i] = nil;
        }
    }
    
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    if (observationInfo || implicitObservationInfo) {
        DSKVOPushInfoPerThread pushInfo = {0};
        pushInfo.pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:YES];
        pushInfo.beginningOfChange = YES;
        pushInfo.observationInfo = observationInfo;
        
        DSKVOCollectionWillChangeInfo changeInfo = {.changeKind = changeKind, .indexes = indexes};
        
        if (observationInfo) {
            DSKeyValueWillChange(self, key, NO, observationInfo, (DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeByOrderedToManyMutation, &changeInfo, (DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
        if (implicitObservationInfo) {
            pushInfo.observationInfo = NULL;
            DSKeyValueWillChange(self, key, NO, implicitObservationInfo, (DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeByOrderedToManyMutation, &changeInfo, (DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
    }
    
    [observationInfo release];
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

- (void)d_didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    CFMutableArrayRef pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            DSKVOPopInfoPerThread popInfo = {pendingArray, pendingCount, nil, -1, nil};
            DSKeyValueDidChange(self,key,NO,(DSKVODidChangeDetailSetupFunc)DSKeyValueDidChangeByOrderedToManyMutation,(DSKVODidChangeNotificationPopFunc)DSKeyValuePopPendingNotificationPerThread,&popInfo);
        }
    }
}

- (void)d_willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    DSKeyValueObservationInfo *observationInfo = [(id)self.d_observationInfo retain];
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *implicitObservationInfo = [self _d_implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    DSKeyValueObservance *observance_objs[totalObservanceCount];
    
    if(observationInfo) {
        _DSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observationInfoObservanceCount);
    }
    
    if(implicitObservationInfo) {
        _DSKeyValueObservationInfoGetObservances(implicitObservationInfo, observance_objs + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observance_objs[i].observer)) {
            observance_objs[i] = [observance_objs[i].observer retain];
        }
        else {
            observance_objs[i] = nil;
        }
    }
    
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    if (observationInfo || implicitObservationInfo) {
        DSKVOCollectionWillChangeInfo changeInfo = {.mutationKind = mutationKind, .objects = objects};
        
        DSKVOPushInfoPerThread pushInfo = {0};
        pushInfo.pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:YES];
        pushInfo.beginningOfChange = YES;
        pushInfo.observationInfo = observationInfo;
        if (observationInfo) {
            DSKeyValueWillChange(self, key, NO, observationInfo, (DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetMutation, &changeInfo, (DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
        if (implicitObservationInfo) {
            pushInfo.observationInfo = NULL;
            DSKeyValueWillChange(self, key, NO, implicitObservationInfo, (DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetMutation, &changeInfo, (DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
    }
    
    [observationInfo release];
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

- (void)d_didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {
    CFMutableArrayRef pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            DSKVOPopInfoPerThread popInfo = {pendingArray, pendingCount, NULL, -1, 0};
            DSKeyValueDidChange(self,key,NO, (DSKVODidChangeDetailSetupFunc)DSKeyValueDidChangeBySetMutation,(DSKVODidChangeNotificationPopFunc)DSKeyValuePopPendingNotificationPerThread,&popInfo);
        }
    }
}

@end

BOOL _DSKeyValueCheckObservationInfoForPendingNotification(id object, DSKeyValueObservance *observance, DSKeyValueObservationInfo * observationInfo) {
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *info = nil;
    if(observance.property.containerClass) {
        info = observance.property.containerClass.cachedObservationInfoImplementation(object, @selector(observationInfo));
    }
    else {
        info = [object observationInfo];
    }
    
    if(!info) {
        os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
        return NO;
    }
    
    if(info == observationInfo) {
        os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
        return YES;
    }
    
    BOOL contains = _DSKeyValueObservationInfoContainsObservance(info, observance);
    
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    return contains;
}


void DSKeyValueWillChangeForObservance(id object, id keyOrKeys, BOOL keyOrKeysIsASet, DSKeyValueObservance * observance) {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
   
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *observationInfo = [object d_observationInfo];
    [observationInfo retain];
    
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *implicitObservationInfo = [object _d_implicitObservationInfo];
    
    NSUInteger observationInfoObservanceCount = 0;
    NSUInteger implicitObservationInfoObservanceCount = 0;
    NSUInteger totalObservanceCount = 0;
    
    if(observationInfo) {
        observationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
    }
    if(implicitObservationInfo) {
        implicitObservationInfoObservanceCount = _DSKeyValueObservationInfoGetObservanceCount(implicitObservationInfo);
    }
    
    totalObservanceCount = observationInfoObservanceCount + implicitObservationInfoObservanceCount;
    
    DSKeyValueObservance *observance_objs[totalObservanceCount];
    if(observationInfo) {
        _DSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observationInfoObservanceCount);
    }
    if(implicitObservationInfo) {
        _DSKeyValueObservationInfoGetObservances(observationInfo, observance_objs + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observance_objs[i].observer)) {
            observance_objs[i] = [observance_objs[i].observer retain];
        }
        else {
            observance_objs[i] = nil;
        }
    }
    
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    if(observationInfo || implicitObservationInfo) {
        DSKVOPushInfoPerThread pushInfo;
        if(keyOrKeysIsASet) {
            DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
            if(!TSD) {
                TSD = NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
                _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
            }
            if(!TSD->pendingArray) {
                TSD->pendingArray = CFArrayCreateMutable(NULL, 0, &DSKVOPendingNotificationArrayCallbacks);
            }
            pushInfo.pendingArray = TSD->pendingArray;
        }
        else {
            pushInfo.pendingArray = [object _d_pendingChangeNotificationsArrayForKey:keyOrKeys create:YES];
        }
        pushInfo.beginningOfChange = YES;
        pushInfo.observationInfo = observationInfo;
        if(observationInfo) {
            DSKeyValueWillChange(object,keyOrKeys,keyOrKeysIsASet,observationInfo,(DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetting,nil,(DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread,&pushInfo, observance);
        }
        if(implicitObservationInfo) {
            DSKeyValueWillChange(object,keyOrKeys,keyOrKeysIsASet,implicitObservationInfo,(DSKVOWillChangeDetailSetupFunc)DSKeyValueWillChangeBySetting,nil,(DSKVOWillChangeNotificationPushFunc)DSKeyValuePushPendingNotificationPerThread,&pushInfo, observance);
        }
    }
    
    [observationInfo release];
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

void DSKeyValueDidChangeForObservance(id object, id keyOrKeys, BOOL keyOrKeysIsASet, DSKeyValueObservance * observance) {
    CFMutableArrayRef pendingArray = NULL;
    if(keyOrKeysIsASet) {
        DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
        if (!TSD) {
            return;
        }
        pendingArray = TSD->pendingArray;
    }
    else {
        pendingArray = [object _d_pendingChangeNotificationsArrayForKey:keyOrKeys create:NO];
    }
    
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            DSKVOPopInfoPerThread popInfo = {pendingArray,pendingCount,nil,-1,observance};
            DSKeyValueDidChange(object, keyOrKeys, keyOrKeysIsASet, (DSKVODidChangeDetailSetupFunc)DSKeyValueDidChangeBySetting, (DSKVODidChangeNotificationPopFunc)DSKeyValuePopPendingNotificationPerThread, &popInfo);
        }
    }
}

void DSKeyValueWillChangeBySetting(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, NSDictionary *oldValueDict, BOOL *detailsRetained) {
    id oldValue = nil;
    if(options & NSKeyValueObservingOptionOld) {
        if(oldValueDict) {
            oldValue = [oldValueDict objectForKey:keyPath];
        }
        else {
            oldValue = [object d_valueForKeyPath:keyPath];
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
    changeDetails->extraData = nil;
    
    LOG_KVO(@"object: %@, keyPath: %@, keyPathExactMatch:%@, options: 0X%02X, oldValueDict: %@, detailsRetained:%s, result changeDetails: %@",simple_desc(object), keyPath, bool_desc(keyPathExactMatch), options, oldValueDict, bool_desc(*detailsRetained), NSStringFromKeyValueChangeDetails(changeDetails));
}

void DSKeyValueDidChangeBySetting(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails) {
    id newValue = nil;
    if(options & NSKeyValueObservingOptionNew) {
        newValue = [object d_valueForKeyPath:keyPath];
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
    resultChangeDetails->extraData = changeDetails.extraData;
    
    LOG_KVO(@"object: %@, keyPath: %@, keyPathExactMatch:%@, options: 0X%02X, passed changeDetails: %@,   result changeDetails: %@",simple_desc(object), keyPath, bool_desc(keyPathExactMatch), options, NSStringFromKeyValueChangeDetails(&changeDetails), NSStringFromKeyValueChangeDetails(resultChangeDetails));
}

void DSKeyValueWillChangeByOrderedToManyMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOCollectionWillChangeInfo *changeInfo, BOOL *detailsRetained) {
    if (keyPathExactMatch) {
        id oldValue = nil;
        NSArray *oldObjects = nil;
        NSMutableData *oldObjectsData = nil;
        
        NSString *keypathTSD = _CFGetTSD(DSKeyValueObservingKeyPathTSDKey);
        id objectTSD = _CFGetTSD(DSKeyValueObservingObjectTSDKey);
        if (!keypathTSD || keypathTSD != keyPath || objectTSD != object) {
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, object, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, keyPath, NULL);
            
            oldValue = [object d_valueForKey:keyPath];
            
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, NULL, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, NULL, NULL);
            
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
                oldValue = [object d_valueForKey:keyPath];
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
        changeDetails->extraData = oldObjectsData;
    }
    else {
        id oldValue = nil;
        if (options & NSKeyValueObservingOptionOld) {
            oldValue = [object d_valueForKeyPath:keyPath];
            if (!oldValue) {
                oldValue = [NSNull null];
            }
        }
        
        *detailsRetained = NO;
        
        changeDetails->kind = NSKeyValueChangeSetting;
        changeDetails->oldValue = oldValue;
        changeDetails->newValue = nil;
        changeDetails->indexes = nil;
        changeDetails->extraData = nil;
    }
}

void DSKeyValueDidChangeByOrderedToManyMutation(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails) {
    if (keyPathExactMatch) {
        id newValue = nil;
        
        NSIndexSet *indexes = changeDetails.indexes;
        
        NSString *keypathTSD = _CFGetTSD(DSKeyValueObservingKeyPathTSDKey);
        id objectTSD = _CFGetTSD(DSKeyValueObservingObjectTSDKey);
        if (!keypathTSD || keypathTSD != keyPath || objectTSD != object) {
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, object, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, keyPath, NULL);
            
            newValue = [object d_valueForKey:keyPath];
            
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, NULL, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, NULL, NULL);
            
            if (newValue) {
                if ([newValue isKindOfClass:NSOrderedSet.self]) {
                    if (changeDetails.kind == NSKeyValueChangeReplacement) {
                        id *oldObjs = (id *)[changeDetails.extraData bytes];
                        __block NSMutableIndexSet *copiedIndexes = nil;
                        [changeDetails.indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * stop) {
                            id eachObject = [newValue objectAtIndex:idx];
                            if (eachObject == oldObjs[idx]) {
                                if (!copiedIndexes) {
                                    copiedIndexes = [changeDetails.indexes mutableCopy];
                                }
                                [copiedIndexes removeIndex: idx];
                            }
                        }];
                        if (copiedIndexes) {
                            [copiedIndexes autorelease];
                            indexes = copiedIndexes;
                        }
                        [changeDetails.extraData release];
                        changeDetails.extraData = nil;
                    }
                    if (changeDetails.kind == NSKeyValueChangeInsertion) {
                        __block NSUInteger offset = 0;
                        __block NSMutableIndexSet *copiedIndexes = nil;
                        id *oldObjs = (id *)[changeDetails.extraData bytes];
                        NSUInteger oldObjsCount = [changeDetails.extraData length] / sizeof(id);
                        
                        [changeDetails.indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                            NSUInteger i = idx - offset;
                            id oldObj = nil;
                            if (i < oldObjsCount) {
                                oldObj = oldObjs[i];
                            }
                            id newObj = nil;
                            if (idx < [newValue count]) {
                                newObj = [newValue objectAtIndex:idx];
                            }
                            
                            if (newObj == oldObj) {
                                if (!copiedIndexes) {
                                    copiedIndexes = [changeDetails.indexes mutableCopy];
                                }
                                [copiedIndexes removeIndex: idx];
                            }
                            else {
                                offset ++;
                            }
                        }];
                        
                        if (copiedIndexes) {
                            [copiedIndexes autorelease];
                            indexes = copiedIndexes;
                        }
                        [changeDetails.extraData release];
                        changeDetails.extraData = nil;
                    }
                }
            }
        }
        
        NSArray *newObjects = nil;
        if ((options & NSKeyValueObservingOptionNew) && changeDetails.kind != NSKeyValueChangeRemoval) {
            if (!newValue) {
                newValue = [object d_valueForKey:keyPath];
            }
            
            newObjects = [newValue objectsAtIndexes:indexes];
        }
        
        resultChangeDetails->kind = changeDetails.kind;
        resultChangeDetails->oldValue = changeDetails.oldValue;
        resultChangeDetails->newValue = newObjects;
        resultChangeDetails->indexes = indexes;
        resultChangeDetails->extraData = changeDetails.extraData;
    }
    else {
        id newValue = nil;
        if (options & NSKeyValueObservingOptionNew) {
            newValue = [object d_valueForKeyPath:keyPath];
            if (!newValue) {
                newValue = [NSNull null];
            }
        }
        else {
            newValue = changeDetails.newValue;
        }
        resultChangeDetails->kind = changeDetails.kind;
        resultChangeDetails->oldValue = changeDetails.oldValue;
        resultChangeDetails->newValue = changeDetails.newValue;
        resultChangeDetails->indexes = changeDetails.indexes;
        resultChangeDetails->extraData = changeDetails.extraData;
    }
}

void DSKeyValueWillChangeBySetMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOCollectionWillChangeInfo *changeInfo, BOOL *detailsRetained) {
    if (keyPathExactMatch) {
        NSKeyValueChange kind = 0;
        id oldValue = nil;
        id newValue = nil;
        NSIndexSet *indexes = nil;
        NSMutableData *oldObjectsData = nil;
        
        switch (changeInfo->mutationKind) {
            case NSKeyValueUnionSetMutation: {
                kind = NSKeyValueChangeInsertion;
                
                if (options & NSKeyValueObservingOptionNew) {
                    id currentValue = [object d_valueForKey:keyPath];
                    if ([changeInfo->objects intersectsSet:currentValue]) {
                        newValue = [changeInfo->objects mutableCopy];
                        if (currentValue) {
                            [newValue minusSet: currentValue];
                        }
                    }
                    else {
                        //loc_D0FBF
                        newValue = [changeInfo->objects copy];
                    }
                }
            }
                break;
            case NSKeyValueMinusSetMutation: {
                kind = NSKeyValueChangeRemoval;
                
                if (options & NSKeyValueObservingOptionOld) {
                    id currentValue = [object d_valueForKey:keyPath];
                    if ([changeInfo->objects isSubsetOfSet:currentValue]) {
                        oldValue = [changeInfo->objects copy];
                    }
                    else {
                        //loc_D0FDB
                        oldValue = [changeInfo->objects mutableCopy];
                        if (currentValue) {
                            [oldValue intersectSet:currentValue];
                        }
                    }
                }
            }
                break;
            case NSKeyValueIntersectSetMutation: {
                kind = NSKeyValueChangeRemoval;
                
                if (options & NSKeyValueObservingOptionOld) {
                    //loc_D0F6F
                    oldValue = [[object d_valueForKey:keyPath] mutableCopy];
                    if (changeInfo->objects) {
                        [oldValue minusSet:changeInfo->objects];
                    }
                }
            }
                break;
            case NSKeyValueSetSetMutation: {
                kind = NSKeyValueChangeReplacement;
                
                id currentValue = nil;
                if (options & NSKeyValueObservingOptionOld) {
                    currentValue = [object d_valueForKey:keyPath];
                    oldValue = [currentValue mutableCopy];
                    if (changeInfo->objects) {
                        [oldValue minusSet:changeInfo->objects];
                    }
                }
                
                if (options & NSKeyValueObservingOptionNew) {
                    if (!currentValue) {
                        currentValue = [object d_valueForKey:keyPath];
                    }
                    newValue =  [changeInfo->objects mutableCopy];
                    if (currentValue) {
                        [newValue minusSet:currentValue];
                    }
                }
            }
                break;
            default:
                break;
        }
        
        *detailsRetained = YES;
        
        changeDetails->kind = kind;
        changeDetails->oldValue = oldValue;
        changeDetails->newValue = newValue;
        changeDetails->indexes = indexes;
        changeDetails->extraData = oldObjectsData;
    }
    else {
        //loc_D0E23
        id oldValue = nil;
        if (options & NSKeyValueObservingOptionOld) {
            oldValue = [object d_valueForKeyPath:keyPath];
            if (!oldValue) {
                oldValue = [NSNull null];
            }
        }
        
        *detailsRetained = NO;
        
        changeDetails->kind = NSKeyValueChangeSetting;
        changeDetails->oldValue = oldValue;
        changeDetails->newValue = nil;
        changeDetails->indexes = nil;
        changeDetails->extraData = nil;
    }
}

void DSKeyValueDidChangeBySetMutation(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails) {
    if (keyPathExactMatch) {
        *resultChangeDetails = changeDetails;
    }
    else {
        id newValue = nil;
        if (options & NSKeyValueObservingOptionNew) {
            //loc_D116D
            newValue = [object valueForKeyPath:keyPath];
            if (!newValue) {
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
        resultChangeDetails->extraData = changeDetails.extraData;
    }
}


void DSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPushInfoPerThread *pushInfo) {
    DSKVOPendingChangeNotificationPerThread *pendingNotification = NSAllocateScannedUncollectable(sizeof(DSKVOPendingChangeNotificationPerThread));
    
    pendingNotification->retainCount = 1;//引用计数初始化为1
    pendingNotification->beginningOfChange = pushInfo->beginningOfChange;
    pendingNotification->object = [object retain];
    pendingNotification->keyOrKeys = [keyOrKeys copy];
    pendingNotification->observationInfo = [pushInfo->observationInfo retain];
    pendingNotification->observance = observance;
    pendingNotification->kind = changeDetails.kind;
    pendingNotification->oldValue = [changeDetails.oldValue retain];
    pendingNotification->newValue = [changeDetails.newValue retain];
    pendingNotification->indexes = [changeDetails.indexes retain];
    pendingNotification->extraData = [changeDetails.extraData retain];
    pendingNotification->changingValue = [forwardingValues.changingValue retain];
    pendingNotification->affectingValuesMap = [forwardingValues.affectingValuesMap retain];
    
    [pendingNotification->observance.observer retain];
    
    //追加Notification 到 pendingArray， 会使Notification引用计数+1 => 2
    CFArrayAppendValue(pushInfo->pendingArray, pendingNotification);
    //引用计数减1 => 1,便于后续正确释放
    DSKVOPendingNotificationRelease(NULL,pendingNotification);
    //在一次will change中，下一个push进来的Notification不再是 "起始"
    pushInfo->beginningOfChange = NO;
    
    LOG_KVO(@"object: %@, keyOrKeys: %@, observance:%@, changeDetails: %@, forwardingValues: %@, pushInfo:%@, pushed notification: %@, pending count after push: %zd",simple_desc(object), keyOrKeys, simple_desc(observance), NSStringFromKeyValueChangeDetails(&changeDetails), NSStringFromPropertyForwardingValues(&forwardingValues), NSStringFromPushInfoPerThread(pushInfo), NSStringFromPendingChangeNotificationPerThread(pendingNotification), CFArrayGetCount(pushInfo->pendingArray));
}

BOOL DSKeyValuePopPendingNotificationPerThread(id object,id keyOrKeys, DSKeyValueObservance **popedObservance, DSKeyValueChangeDetails *popedChangeDetails,DSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, DSKVOPopInfoPerThread* popInfo) {
    if(popInfo->lastPopedNotification) {
        //上一次正确地pop，删除上一次pop掉的notification
        CFArrayRemoveValueAtIndex(popInfo->pendingArray, popInfo->lastPopdIndex);
        //上一次pop的是一次change的"起始"
        if(popInfo->lastPopedNotification->beginningOfChange) {
            //结束pop
            return NO;
        }
    }
    else {
        //总是从pendingArray 的末端开始pop，保证后入先出
        popInfo->lastPopdIndex = popInfo->pendingCount;
    }
    
    for (NSInteger i = popInfo->lastPopdIndex - 1; i >=0 ; --i) {
        DSKVOPendingChangeNotificationPerThread *changeNotification = (DSKVOPendingChangeNotificationPerThread *)CFArrayGetValueAtIndex(popInfo->pendingArray, i);
        if (changeNotification->object == object && [changeNotification->keyOrKeys isEqual:keyOrKeys] && (!popInfo->observance || changeNotification->observance == popInfo->observance)) {
            if (!changeNotification->observationInfo || _DSKeyValueCheckObservationInfoForPendingNotification(changeNotification->object,changeNotification->observance, changeNotification->observationInfo)) {
                //找到期望的notification
                *popedObservance = changeNotification->observance;
                
                popedChangeDetails->kind = changeNotification->kind;
                popedChangeDetails->oldValue = changeNotification->oldValue;
                popedChangeDetails->newValue = changeNotification->newValue;
                popedChangeDetails->indexes = changeNotification->indexes;
                popedChangeDetails->extraData = changeNotification->extraData;
                
                popedForwardValues->changingValue = changeNotification->changingValue;
                popedForwardValues->affectingValuesMap = changeNotification->affectingValuesMap;
                
                *popedKeyOrKeys = keyOrKeys;
                
                popInfo->lastPopedNotification = changeNotification;
                popInfo->lastPopdIndex = i;
                
                LOG_KVO(@"object: %@, keyOrKeys: %@, popedObservance:%@, popedChangeDetails: %@, popedForwardValues: %@, popedKeyOrKeys:%@, popInfo: %@",simple_desc(object), keyOrKeys, simple_desc(*popedObservance), NSStringFromKeyValueChangeDetails(popedChangeDetails), NSStringFromPropertyForwardingValues(popedForwardValues), *popedKeyOrKeys, NSStringFromPopInfoPerThread(popInfo));
                
                return YES;
            }
            //这是一个无人认领的Notification，删除之
            CFArrayRemoveValueAtIndex(popInfo->pendingArray, i);
            //不是期望的Notification，并且已经是一次change的起始
            if (changeNotification->beginningOfChange) {
                //结束pop循环
                return NO;
            }
        }
    }
    return NO;
}

void DSKeyValuePushPendingNotificationLocal(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPushInfoLocal *pushInfo) {
    //count 已经增长到 capacity
    if(pushInfo->notificationCount == pushInfo->capacity) {
        //扩容两倍
        pushInfo->capacity = pushInfo->notificationCount * 2;
        //notifications来自栈
        if(pushInfo->notificationsInStack) {
            //分配新的内存
            DSKVOPendingChangeNotificationLocal *notifications = NSAllocateScannedUncollectable(pushInfo->capacity * sizeof(DSKVOPendingChangeNotificationLocal));
            //将旧的notifications拷贝到新notifications
            memmove(notifications, pushInfo->notifications,pushInfo->notificationCount * sizeof(DSKVOPendingChangeNotificationLocal));
            pushInfo->notifications = notifications;
            pushInfo->notificationsInStack = NO;
        }
        //notifications来自堆
        else {
            //直接realloc内存
            DSKVOPendingChangeNotificationLocal *notifications = NSReallocateScannedUncollectable(pushInfo->notifications,pushInfo->capacity * sizeof(DSKVOPendingChangeNotificationLocal));
            pushInfo->notifications = notifications;
        }
    }
    
    //新最后一个可用的notification指针
    DSKVOPendingChangeNotificationLocal *notification = pushInfo->notifications + pushInfo->notificationCount;
    //插入新notification后， count加一
    pushInfo->notificationCount += 1;

    notification->observance = observance;
    notification->kind = changeDetails.kind;
    notification->oldValue = changeDetails.oldValue;
    notification->newValue = changeDetails.newValue;
    notification->indexes = changeDetails.indexes;
    notification->extraData = changeDetails.extraData;
    notification->changingValue = forwardingValues.changingValue;
    notification->affectingValuesMap = forwardingValues.affectingValuesMap;
    notification->unknow_1 = pushInfo->unknow_1;
    notification->keyOrKeys = keyOrKeys;
    
    [changeDetails.oldValue retain];
    [forwardingValues.changingValue retain];
    [observance.observer retain];
}

BOOL DSKeyValuePopPendingNotificationLocal(id object,id keyOrKeys, DSKeyValueObservance **popedObservance, DSKeyValueChangeDetails *popedChangeDetails,DSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, DSKVOPopInfoLocal* popInfo) {
    [popInfo->observer release];
    [popInfo->oldValue release];
    [popInfo->lastChangingValue release];
    
    while(popInfo->notificationCount > 0) {
        popInfo->notificationCount --;
        
        DSKVOPendingChangeNotificationLocal *notification = popInfo->notifications + popInfo->notificationCount;
        
        if (notification->observance) {
            if(!_DSKeyValueCheckObservationInfoForPendingNotification(object, notification->observance, popInfo->observationInfo)) {
                [notification->observance.observer release];
                [notification->oldValue release];
                [notification->changingValue release];
                continue;
            }
        }
        
        *popedObservance = notification->observance;
        
        popedChangeDetails->kind = notification->kind;
        popedChangeDetails->oldValue = notification->oldValue;
        popedChangeDetails->newValue = notification->newValue;
        popedChangeDetails->indexes = notification->indexes;
        popedChangeDetails->extraData = notification->extraData;
        
        popedForwardValues->changingValue = notification->changingValue;
        popedForwardValues->affectingValuesMap = notification->affectingValuesMap;
        
        *popedKeyOrKeys = notification->keyOrKeys;
        
        popInfo->observer = notification->observance.observer;
        popInfo->oldValue = notification->oldValue;
        popInfo->lastChangingValue = notification->changingValue;
        
        return YES;
    }
    
    return NO;
}


void DSKeyValueWillChange(id object, id keyOrKeys, BOOL isASet, DSKeyValueObservationInfo *observationInfo, DSKVOWillChangeDetailSetupFunc willChangeDetailSetupFunc, void *changeInfo, DSKVOWillChangeNotificationPushFunc willChangeNotificationPushFunc, void *pushInfo, DSKeyValueObservance *observance) {
    NSUInteger observanceCount = _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
    DSKeyValueObservance *observanceBuff[observanceCount];
    
    _DSKeyValueObservationInfoGetObservances(observationInfo, observanceBuff, observanceCount);
    
    LOG_KVO(@"object: %@, keyOrKeys: %@, isASet: %@, observationInfo: %@, changeInfo: %p, pushInfo: %p, observance: %@, observanceCount: %zd", simple_desc(object), keyOrKeys, bool_desc(isASet), simple_desc(observationInfo),changeInfo, pushInfo, simple_desc(observance), observanceCount);
    
    for (NSUInteger i = 0; i < observanceCount; ++i) {
        DSKeyValueObservance *eachObservance = observanceBuff[i];
        if(!observance || observance == eachObservance) {
            NSString* affectedKeyPath = nil;
            BOOL keyPathExactMatch = NO;
            DSKeyValuePropertyForwardingValues forwardingValues = {0};
            
            if(isASet) {
                affectedKeyPath = [eachObservance.property keyPathIfAffectedByValueForMemberOfKeys:keyOrKeys];
            }
            else {
                affectedKeyPath = [eachObservance.property keyPathIfAffectedByValueForKey:keyOrKeys exactMatch:&keyPathExactMatch];
            }
            
            if(affectedKeyPath) {
                if( [eachObservance.property object:object withObservance:eachObservance willChangeValueForKeyOrKeys:keyOrKeys recurse:YES forwardingValues:&forwardingValues] ) {
                    DSKeyValueChangeDetails changeDetails = {0};
                    BOOL detailsRetained;
                    DSKeyValueChangeDictionary *changeDictionary = nil;
                    
                    willChangeDetailSetupFunc(&changeDetails, object, affectedKeyPath,keyPathExactMatch,eachObservance.options, changeInfo, &detailsRetained);
                    
                    willChangeNotificationPushFunc(object, keyOrKeys, eachObservance, changeDetails , forwardingValues, pushInfo);
                    
                    if(eachObservance.options & NSKeyValueObservingOptionPrior) {
                        DSKeyValueNotifyObserver(eachObservance.observer, affectedKeyPath,  object, eachObservance.context, eachObservance.originalObservable, YES,changeDetails, &changeDictionary);
                    }
                    
                    if(detailsRetained) {
                        [changeDetails.oldValue release];
                        [changeDetails.newValue release];
                        [changeDetails.indexes release];
                        [changeDetails.extraData release];
                    }
                    
                    [changeDictionary release];
                }
            }
        }
    }
}

void DSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,DSKVODidChangeDetailSetupFunc didChangeDetailSetupFunc, DSKVODidChangeNotificationPopFunc didChangeNotificationPopFunc, void *popInfo) {
    LOG_KVO(@"object: %@, keyOrKeys: %@, isASet: %@, popInfo: %p", simple_desc(object), keyOrKeys, bool_desc(isASet), popInfo);
    DSKeyValueObservance *popedObservance = nil;
    DSKeyValueChangeDetails popedChangeDetails = {0};
    DSKeyValuePropertyForwardingValues popedForwardValues = {0};
    id popedKeyOrKeys = nil;
    DSKeyValueChangeDictionary *changeDictionary = nil;
    
    while(didChangeNotificationPopFunc(object, keyOrKeys, &popedObservance, &popedChangeDetails, &popedForwardValues, &popedKeyOrKeys, popInfo)) {
        [popedObservance.property object:object withObservance:popedObservance didChangeValueForKeyOrKeys:popedKeyOrKeys recurse:YES forwardingValues:popedForwardValues];
        BOOL exactMatch = NO;
        if(!isASet) {
            exactMatch = CFEqual(popedObservance.property.keyPath, popedKeyOrKeys);
        }
        
        DSKeyValueChangeDetails resultDetails = {0};
        
        didChangeDetailSetupFunc(&resultDetails, object, popedObservance.property.keyPath, exactMatch, popedObservance.options, popedChangeDetails);
        
        popedChangeDetails = resultDetails;
        
        DSKeyValueNotifyObserver(popedObservance.observer,popedObservance.property.keyPath, object,popedObservance.context,popedObservance.originalObservable,NO,popedChangeDetails, &changeDictionary);
    }
    
    [changeDictionary release];
}

void DSKVONotify(id observer, NSString *keyPath, id object, NSDictionary *changeDictionary, void *context) {
    DSKeyValueObservingAssertRegistrationLockNotHeld();
    LOG_KVO("value for keyPath: %@ of object: %@ changed, notify observer: %@, with changeDictionary: %@, context: %p",keyPath, simple_desc(object), simple_desc(observer), changeDictionary, context);
    [observer observeValueForKeyPath:keyPath ofObject:object change:changeDictionary context:context];
}

void DSKeyValueNotifyObserver(id observer,NSString * keyPath, id object, void *context, id originalObservable, BOOL isPriorNotification, DSKeyValueChangeDetails changeDetails, DSKeyValueChangeDictionary **changeDictionary) {
    if(*changeDictionary) {
        [*changeDictionary setDetailsNoCopy:changeDetails originalObservable:originalObservable];
    }
    else {
        *changeDictionary =  [[DSKeyValueChangeDictionary alloc] initWithDetailsNoCopy:changeDetails originalObservable:originalObservable isPriorNotification:isPriorNotification];
    }
    
    NSUInteger retainCountBefore = [*changeDictionary retainCount];
    
    DSKVONotify(observer, keyPath, object, *changeDictionary, context);
    
    if(retainCountBefore != (NSUInteger)INTMAX_MAX && retainCountBefore != [*changeDictionary retainCount]) {
        [*changeDictionary retainObjects];
    }
}

