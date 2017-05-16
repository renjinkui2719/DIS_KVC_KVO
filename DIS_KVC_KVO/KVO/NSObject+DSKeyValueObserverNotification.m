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
#import "NSObject+DSKeyValueObserverRegistration.h"

@implementation NSObject (DSKeyValueObserverNotification)

- (void)d_willChangeValueForKey:(NSString *)key {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *observationInfo = self.observationInfo;
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
            DSKeyValueWillChange(self,key,NO,observationInfo,DSKeyValueWillChangeBySetting,nil,(DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationPerThread,&pushInfo,nil);
        }
        if(implicitObservationInfo) {
            DSKVOPushInfoPerThread pushInfo = {pendingArray, YES, NULL};
            DSKeyValueWillChange(self,key,NO,implicitObservationInfo,DSKeyValueWillChangeBySetting,nil,(DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationPerThread,&pushInfo,nil);
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
            DSKeyValueDidChange(self,key,0,DSKeyValueDidChangeBySetting,(DSKeyValuePopPendingNotificationCallback)DSKeyValuePopPendingNotificationPerThread,&popInfo);
        }
    }
}

- (void)d_willChange:(DSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    DSKeyValueObservationInfo *observationInfo = [(id)self.observationInfo retain];
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
        pushInfo.pushAsLastPop = YES;
        pushInfo.observationInfo = observationInfo;
        
        DSKVOArrayOrSetWillChangeInfo changeInfo = {changeKind, indexes};
        
        if (observationInfo) {
            DSKeyValueWillChange(self, key, NO, observationInfo, DSKeyValueWillChangeByOrderedToManyMutation, &changeInfo, DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
        if (implicitObservationInfo) {
            pushInfo.observationInfo = NULL;
            DSKeyValueWillChange(self, key, NO, implicitObservationInfo, DSKeyValueWillChangeByOrderedToManyMutation, &changeInfo, DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
    }
    
    [observationInfo release];
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

- (void)d_didChange:(DSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    CFMutableArrayRef pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            DSKVOPopInfoPerThread popInfo = {pendingArray, pendingCount, nil, -1, nil};
            DSKeyValueDidChange(self,key,NO,DSKeyValueDidChangeByOrderedToManyMutation,(DSKeyValuePopPendingNotificationCallback)DSKeyValuePopPendingNotificationPerThread,&popInfo);
        }
    }
}

- (void)d_willChangeValueForKey:(NSString *)key withSetMutation:(DSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    DSKeyValueObservationInfo *observationInfo = [(id)self.observationInfo retain];
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
        pushInfo.pushAsLastPop = YES;
        pushInfo.observationInfo = observationInfo;
        if (observationInfo) {
            DSKeyValueWillChange(self, key, NO, observationInfo, DSKeyValueWillChangeBySetMutation, &mutationKind, DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
        if (implicitObservationInfo) {
            pushInfo.observationInfo = NULL;
            DSKeyValueWillChange(self, key, NO, implicitObservationInfo, DSKeyValueWillChangeBySetMutation, &mutationKind, DSKeyValuePushPendingNotificationPerThread, &pushInfo, nil);
        }
    }
    [observationInfo release];
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        [observance_objs[i] release];
    }
}

- (void)d_didChangeValueForKey:(NSString *)key withSetMutation:(DSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {
    CFMutableArrayRef pendingArray = [self _d_pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            DSKVOPopInfoPerThread popInfo = {pendingArray, pendingCount, NULL, -1, 0};
            DSKeyValueDidChange(self,key,NO,DSKeyValueDidChangeBySetMutation,(DSKeyValuePopPendingNotificationCallback)DSKeyValuePopPendingNotificationPerThread,&popInfo);
        }
    }
}

@end


void DSKVONotify(id observer, NSString *keyPath, id object, NSDictionary *changeDictionary, void *context) {
    DSKeyValueObservingAssertRegistrationLockNotHeld();
    [observer observeValueForKeyPath:keyPath ofObject:object change:changeDictionary context:context];
}

void DSKeyValueNotifyObserver(id observer,NSString * keyPath, id object, void *context, id originalObservable, BOOL isPriorNotification, DSKeyValueChangeDetails changeDetails, DSKeyValueChangeDictionary **changeDictionary) {
    if([observer respondsToSelector:@selector(_observeValueForKeyPath:ofObject:changeKind:oldValue:newValue:indexes:context:)]) {
        
    }
    else {
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
}

void DSKeyValueWillChangeForObservance(id originalObservable, id dependentValueKeyOrKeys, BOOL isASet, DSKeyValueObservance * observance) {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
   
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *observationInfo = [originalObservable observationInfo];
    [observationInfo retain];
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    DSKeyValueObservationInfo *implicitObservationInfo = [originalObservable _d_implicitObservationInfo];
    
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
    
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    if(observationInfo && implicitObservationInfo) {
        DSKVOPushInfoPerThread pushInfo;
        if(isASet) {
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
           //loc_CB341
            pushInfo.pendingArray = [originalObservable _d_pendingChangeNotificationsArrayForKey:dependentValueKeyOrKeys create:YES];
        }
        //loc_CB357
        pushInfo.pushAsLastPop = YES;
        pushInfo.observationInfo = observationInfo;
        if(observationInfo) {
            DSKeyValueWillChange(originalObservable,dependentValueKeyOrKeys,isASet,observationInfo,DSKeyValueWillChangeBySetting,nil,(DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationPerThread,&pushInfo, observance);
        }
        //loc_CB3A0
        if(implicitObservationInfo) {
            DSKeyValueWillChange(originalObservable,dependentValueKeyOrKeys,isASet,implicitObservationInfo,DSKeyValueWillChangeBySetting,nil,(DSKeyValuePushPendingNotificationCallback)DSKeyValuePushPendingNotificationPerThread,&pushInfo, observance);
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

void DSKeyValueDidChangeForObservance(id originalObservable, id dependentValueKeyOrKeys, BOOL isASet, DSKeyValueObservance * observance) {
    CFMutableArrayRef pendingArray = NULL;
    if(isASet) {
        DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
        if(TSD) {
            pendingArray = TSD->pendingArray;
        }
        return;
    }
    else {
        pendingArray = [originalObservable _d_pendingChangeNotificationsArrayForKey:dependentValueKeyOrKeys create:NO];
    }
    
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount > 0) {
            DSKVOPopInfoPerThread popInfo = {
                pendingArray,
                pendingCount,
                nil,
                -1,
                observance
            };
            DSKeyValueDidChange(originalObservable, dependentValueKeyOrKeys, isASet, DSKeyValueDidChangeBySetting, (DSKeyValuePopPendingNotificationCallback)DSKeyValuePopPendingNotificationPerThread, &popInfo);
        }
        //loc_CB4D5
    }
    //loc_CB4D5
}

#pragma mark - Will change callbacks

void DSKeyValueWillChangeByOrderedToManyMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained) {
    if (keyPathExactMatch) {
        id oldValue = nil;
        NSArray *oldObjects = nil;
        NSMutableData *oldObjectsData = nil;
        
        NSString *keypathTSD = _CFGetTSD(DSKeyValueObservingKeyPathTSDKey);
        id objectTSD = _CFGetTSD(DSKeyValueObservingObjectTSDKey);
        if (!keypathTSD || keypathTSD != keyPath || objectTSD != object) {
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, object, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, keyPath, NULL);
            
            oldValue = [object valueForKey:keyPath];
            
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, NULL, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, NULL, NULL);
            
            if (oldValue) {
                if ([oldValue isKindOfClass:NSOrderedSet.self]) {
                    if (changeInfo->changeKind == DSKeyValueChangeReplacement || changeInfo->changeKind == DSKeyValueChangeInsertion) {
                        oldObjectsData = [[NSMutableData alloc] initWithLength:[oldValue count] * sizeof(id)];
                        void *bytes = oldObjectsData.mutableBytes;
                        [oldValue getObjects:bytes range:NSMakeRange(0, [oldValue count])];
                    }
                }
            }
        }
        if (options & DSKeyValueObservingOptionOld && changeInfo->changeKind != DSKeyValueChangeInsertion) {
            if (!oldValue) {
                oldValue = [object valueForKey:keyPath];
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
        if (options & DSKeyValueObservingOptionOld) {
            oldValue = [object valueForKeyPath:keyPath];
            if (!oldValue) {
                oldValue = [NSNull null];
            }
        }
        
        *detailsRetained = NO;
        
        changeDetails->kind = DSKeyValueChangeSetting;
        changeDetails->oldValue = oldValue;
        changeDetails->newValue = nil;
        changeDetails->indexes = nil;
        changeDetails->extraData = nil;
    }
}

void DSKeyValueDidChangeByOrderedToManyMutation(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL exactMatch, int options, DSKeyValueChangeDetails changeDetails) {
    if (exactMatch) {
        id newValue = nil;
        
        NSIndexSet *indexes = changeDetails.indexes;
        
        NSString *keypathTSD = _CFGetTSD(DSKeyValueObservingKeyPathTSDKey);
        id objectTSD = _CFGetTSD(DSKeyValueObservingObjectTSDKey);
        if (!keypathTSD || keypathTSD != keyPath || objectTSD != object) {
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, object, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, keyPath, NULL);
            
            newValue = [object valueForKey:keyPath];
            
            _CFSetTSD(DSKeyValueObservingObjectTSDKey, NULL, NULL);
            _CFSetTSD(DSKeyValueObservingKeyPathTSDKey, NULL, NULL);
            
            if (newValue) {
                if ([newValue isKindOfClass:NSOrderedSet.self]) {
                    if (changeDetails.kind == DSKeyValueChangeReplacement) {
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
                    if (changeDetails.kind == DSKeyValueChangeInsertion) {
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
        if ((options & DSKeyValueObservingOptionNew) && changeDetails.kind != DSKeyValueChangeRemoval) {
            if (!newValue) {
                newValue = [object valueForKey:keyPath];
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
        if (options & DSKeyValueObservingOptionNew) {
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
        resultChangeDetails->newValue = changeDetails.newValue;
        resultChangeDetails->indexes = changeDetails.indexes;
        resultChangeDetails->extraData = changeDetails.extraData;
    }
}

void DSKeyValueWillChangeBySetMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained) {
    if (keyPathExactMatch) {
        DSKeyValueChange kind = 0;
        id oldValue = nil;
        id newValue = nil;
        NSIndexSet *indexes = nil;
        NSMutableData *oldObjectsData = nil;
        
        switch (changeInfo->mutationKind) {
            case DSKeyValueUnionSetMutation: {
                kind = DSKeyValueChangeInsertion;
                
                if (options & DSKeyValueObservingOptionNew) {
                    id currentValue = [object valueForKey:keyPath];
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
            case DSKeyValueMinusSetMutation: {
                kind = DSKeyValueChangeRemoval;
                
                if (options & DSKeyValueObservingOptionOld) {
                    id currentValue = [object valueForKey:keyPath];
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
            case DSKeyValueIntersectSetMutation: {
                kind = DSKeyValueChangeRemoval;
                
                if (options & DSKeyValueObservingOptionOld) {
                    //loc_D0F6F
                    oldValue = [[object valueForKey:keyPath] mutableCopy];
                    if (changeInfo->objects) {
                        [oldValue minusSet:changeInfo->objects];
                    }
                }
            }
                break;
            case DSKeyValueSetSetMutation: {
                kind = DSKeyValueChangeReplacement;
                
                id currentValue = nil;
                if (options & DSKeyValueObservingOptionOld) {
                    currentValue = [object valueForKey:keyPath];
                    oldValue = [currentValue mutableCopy];
                    if (changeInfo->objects) {
                        [oldValue minusSet:changeInfo->objects];
                    }
                }
                
                if (options & DSKeyValueObservingOptionNew) {
                    if (!currentValue) {
                        currentValue = [object valueForKey:keyPath];
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
        if (options & DSKeyValueObservingOptionOld) {
            oldValue = [object valueForKeyPath:keyPath];
            if (!oldValue) {
                oldValue = [NSNull null];
            }
        }
        
        *detailsRetained = NO;
        
        changeDetails->kind = DSKeyValueChangeSetting;
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
        if (options & DSKeyValueObservingOptionNew) {
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

void DSKeyValueWillChangeBySetting(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, NSDictionary *oldValueDict, BOOL *detailsRetained) {
    id oldValue = nil;
    if(options & DSKeyValueObservingOptionOld) {
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
    
    changeDetails->kind = DSKeyValueChangeSetting;
    changeDetails->oldValue = oldValue;
    changeDetails->newValue = nil;
    changeDetails->indexes = nil;
    changeDetails->extraData = nil;
}

void DSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPushInfoPerThread *pushInfo) {
    DSKVOPendingChangeNotificationPerThread *pendingNotification = NSAllocateScannedUncollectable(sizeof(DSKVOPendingChangeNotificationPerThread));
    pendingNotification->retainCount = 1;
    pendingNotification->pushAsLastPop = pushInfo->pushAsLastPop;
    pendingNotification->object = [object retain];
    pendingNotification->keyOrKeys = [keyOrKeys copy];
    pendingNotification->observationInfo = [pushInfo->observationInfo retain];
    pendingNotification->observance = observance;
    pendingNotification->kind = changeDetails.kind;
    pendingNotification->oldValue = [changeDetails.oldValue retain];
    pendingNotification->newValue = [changeDetails.newValue retain];
    pendingNotification->indexes = [changeDetails.indexes retain];
    pendingNotification->extraData = [changeDetails.extraData retain];
    pendingNotification->forwardingValues_p1 = [forwardingValues.changingRelationshipObject retain];
    pendingNotification->forwardingValues_p2 = [forwardingValues.p2 retain];
    
    [pendingNotification->observance.observer retain];
    
    CFArrayAppendValue(pushInfo->pendingArray, pendingNotification);
  
    DSKVOPendingNotificationRelease(NULL,pendingNotification);
}

void DSKeyValuePushPendingNotificationLocal(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPendingInfoLocalPush *pendingInfo) {
    //count 已经增长到 capacity
    if(pendingInfo->detailsCount == pendingInfo->capacity) {
        //扩容两倍
        pendingInfo->capacity = pendingInfo->detailsCount * 2;
        //detailsBuff来自栈(局部变量)
        if(pendingInfo->isStackBuff) {
            //分配新的内存
            void *detailsBuff = NSAllocateScannedUncollectable(pendingInfo->capacity * sizeof(DSKVOPendingInfoLocalDetail));
            //将旧的detailsBuff拷贝到新buff
            memmove(detailsBuff, pendingInfo->detailsBuff,pendingInfo->detailsCount * sizeof(DSKVOPendingInfoLocalDetail));
            pendingInfo->detailsBuff = detailsBuff;
            pendingInfo->isStackBuff = NO;
        }
        //detailsBuff来自堆
        else {
            //直接realloc内存
            void *detailsBuff = NSReallocateScannedUncollectable(pendingInfo->detailsBuff,pendingInfo->capacity * sizeof(DSKVOPendingInfoLocalDetail));
            pendingInfo->detailsBuff = detailsBuff;
        }
    }
    
    //新detail指针
    DSKVOPendingInfoLocalDetail *detail = pendingInfo->detailsBuff + pendingInfo->detailsCount;
    //插入新detail后， count加一
    pendingInfo->detailsCount += 1;

    detail->observance = observance;
    detail->kind = changeDetails.kind;
    detail->oldValue = changeDetails.oldValue;
    detail->newValue = changeDetails.newValue;
    detail->indexes = changeDetails.indexes;
    detail->extraData = changeDetails.extraData;
    detail->forwardingValues_p1 = forwardingValues.changingRelationshipObject;
    detail->forwardingValues_p2 = forwardingValues.p2;
    detail->p5 = pendingInfo->p5;
    detail->keyOrKeys = keyOrKeys;
    
    [changeDetails.oldValue retain];
    [forwardingValues.changingRelationshipObject retain];
    [observance.observer retain];
}

BOOL DSKeyValuePopPendingNotificationLocal(id object,id keyOrKeys, DSKeyValueObservance **popedObservance, DSKeyValueChangeDetails *popedChangeDetails,DSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, DSKVOPendingInfoLocalPop* pendingInfo) {
    
    [pendingInfo->observer release];
    [pendingInfo->oldValue release];
    [pendingInfo->forwardValues_p1 release];
    
    while(pendingInfo->detailsCount > 0) {
        pendingInfo->detailsCount --;
        
        DSKVOPendingInfoLocalDetail *detail = pendingInfo->detailsBuff + pendingInfo->detailsCount;
        
        if (detail->observance) {
            if(!_DSKeyValueCheckObservationInfoForPendingNotification(object, detail->observance, pendingInfo->observationInfo)) {
                [detail->observance.observer release];
                [detail->oldValue release];
                [detail->forwardingValues_p1 release];
                continue;
            }
        }
        
        *popedObservance = detail->observance;
        
        popedChangeDetails->kind = detail->kind;
        popedChangeDetails->oldValue = detail->oldValue;
        popedChangeDetails->newValue = detail->newValue;
        popedChangeDetails->indexes = detail->indexes;
        popedChangeDetails->extraData = detail->extraData;
        
        popedForwardValues->changingRelationshipObject = detail->forwardingValues_p1;
        popedForwardValues->p2 = detail->forwardingValues_p1;
        
        *popedKeyOrKeys = detail->keyOrKeys;
        
        pendingInfo->observer = detail->observance.observer;
        pendingInfo->oldValue = detail->oldValue;
        pendingInfo->forwardValues_p1 = detail->forwardingValues_p1;
        
        return YES;
    }
    
    return NO;
}


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

void DSKeyValueDidChangeBySetting(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails) {
    id newValue = nil;
    if(options & DSKeyValueObservingOptionNew) {
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
    resultChangeDetails->extraData = changeDetails.extraData;
}


BOOL DSKeyValuePopPendingNotificationPerThread(id object,id keyOrKeys, DSKeyValueObservance **popedObservance, DSKeyValueChangeDetails *popedChangeDetails,DSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, DSKVOPopInfoPerThread* popInfo) {
    if(popInfo->lastPopedNotification) {
        CFArrayRemoveValueAtIndex(popInfo->pendingArray, popInfo->lastPopdIndex);
        if(popInfo->lastPopedNotification->pushAsLastPop) {
            //return NO;
        }
    }
    else {
        popInfo->lastPopdIndex = popInfo->pendingCount;
    }
    
    for (NSInteger i = popInfo->lastPopdIndex - 1; i >=0 ; --i) {
        DSKVOPendingChangeNotificationPerThread *changeNotification = (DSKVOPendingChangeNotificationPerThread *)CFArrayGetValueAtIndex(popInfo->pendingArray, i);
        if (changeNotification->object == object && [changeNotification->keyOrKeys isEqual:keyOrKeys] && (!popInfo->observance || changeNotification->observance == popInfo->observance)) {
            if (!changeNotification->observationInfo || _DSKeyValueCheckObservationInfoForPendingNotification(changeNotification->object,changeNotification->observance, changeNotification->observationInfo)) {
                *popedObservance = changeNotification->observance;
                
                popedChangeDetails->kind = changeNotification->kind;
                popedChangeDetails->oldValue = changeNotification->oldValue;
                popedChangeDetails->newValue = changeNotification->newValue;
                popedChangeDetails->indexes = changeNotification->indexes;
                popedChangeDetails->extraData = changeNotification->extraData;
                
                popedForwardValues->changingRelationshipObject = changeNotification->forwardingValues_p1;
                popedForwardValues->p2 = changeNotification->forwardingValues_p2;
                
                *popedKeyOrKeys = keyOrKeys;
                
                popInfo->lastPopedNotification = changeNotification;
                popInfo->lastPopdIndex = i;
                return YES;
            }
            
            CFArrayRemoveValueAtIndex(popInfo->pendingArray, i);
            
            if (changeNotification->pushAsLastPop) {
                //return NO;
            }
        }
    }
    return NO;
}

void DSKeyValueWillChange(id object, id keyOrKeys, BOOL isASet, DSKeyValueObservationInfo *observationInfo, DSKeyValueWillChangeByCallback willChangeByCallback, void *changeInfo, DSKeyValuePushPendingNotificationCallback pushPendingNotificationCallback, void *pushInfo, DSKeyValueObservance *observance) {
    NSUInteger observanceCount = _DSKeyValueObservationInfoGetObservanceCount(observationInfo);
    
    DSKeyValueObservance *observanceBuff[observanceCount];
    _DSKeyValueObservationInfoGetObservances(observationInfo, observanceBuff, observanceCount);
    
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
                    
                    willChangeByCallback(&changeDetails, object, affectedKeyPath,keyPathExactMatch,eachObservance.options, changeInfo, &detailsRetained);
                    pushPendingNotificationCallback(object, keyOrKeys, eachObservance, changeDetails , forwardingValues, pushInfo);
                    
                    if(eachObservance.options & DSKeyValueObservingOptionPrior) {
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

void DSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,DSKeyValueDidChangeByCallback didChangeByCallback, DSKeyValuePopPendingNotificationCallback popPendingNotificationCallback, void *popInfo) {
    DSKeyValueObservance *popedObservance = nil;
    DSKeyValueChangeDetails popedChangeDetails = {0};
    DSKeyValuePropertyForwardingValues popedForwardValues = {0};
    id popedKeyOrKeys = nil;
    DSKeyValueChangeDictionary *changeDictionary = nil;
    
    while(popPendingNotificationCallback(object, keyOrKeys, &popedObservance, &popedChangeDetails, &popedForwardValues, &popedKeyOrKeys, popInfo)) {
        [popedObservance.property object:object withObservance:popedObservance didChangeValueForKeyOrKeys:popedKeyOrKeys recurse:YES forwardingValues:popedForwardValues];
        BOOL exactMatch = NO;
        if(!isASet) {
            exactMatch = CFEqual(popedObservance.property.keyPath, popedKeyOrKeys);
        }
        
        DSKeyValueChangeDetails resultDetails = {0};
        
        didChangeByCallback(&resultDetails, object, popedObservance.property.keyPath, exactMatch, popedObservance.options, popedChangeDetails);
        
        popedChangeDetails = resultDetails;
        
        DSKeyValueNotifyObserver(popedObservance.observer,popedObservance.property.keyPath, object,popedObservance.context,popedObservance.originalObservable,NO,popedChangeDetails, &changeDictionary);
    }
    
    [changeDictionary release];
}


