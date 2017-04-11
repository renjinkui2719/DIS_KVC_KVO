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
    
    NSKeyValueObservance *observanceBuff[totalObservanceCount];
    if(observationInfo) {
        _NSKeyValueObservationInfoGetObservances(observationInfo, observanceBuff, observationInfoObservanceCount);
    }
    if(implicitObservationInfo) {
        _NSKeyValueObservationInfoGetObservances(implicitObservationInfo, observanceBuff + observationInfoObservanceCount, implicitObservationInfoObservanceCount);
    }
    
    for (NSUInteger i = 0; i < totalObservanceCount; ++i) {
        if(!object_isClass(observanceBuff[i].observer)) {
            observanceBuff[i] = [observanceBuff[i].observer retain];
        }
        else {
            observanceBuff[i] = nil;
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
        [observanceBuff[i] release];
    }
}

- (void)didChangeValueForKey:(NSString *)key {
    CFMutableArrayRef pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:NO];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount) {
            NSKVOPendingInfoPerThreadPop pendingInfo = {pendingArray, pendingCount, nil, ~0, nil};
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
            NSKVOPendingInfoPerThreadPop pendingInfo = {pendingArray, pendingCount, nil, ~0, nil};
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

void NSKeyValueWillChangeByOrderedToManyMutation(NSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, NSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained) {
    if (keyPathExactMatch) {
        id oldValue = nil;
        NSArray *oldObjects = nil;
        NSMutableData *oldObjectsData = nil;
        
        NSString *keypathTSD = _CFGetTSD(NSKeyValueObservingKeyPathTSDKey);
        id objectTSD = _CFGetTSD(NSKeyValueObservingObjectTSDKey);
        if (!keypathTSD || keypathTSD != keyPath || objectTSD != object) {
            _CFSetTSD(NSKeyValueObservingObjectTSDKey, object, NULL);
            _CFSetTSD(NSKeyValueObservingKeyPathTSDKey, keyPath, NULL);
            
            oldValue = [object valueForKey:keyPath];
            
            _CFSetTSD(NSKeyValueObservingObjectTSDKey, NULL, NULL);
            _CFSetTSD(NSKeyValueObservingKeyPathTSDKey, NULL, NULL);
            
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
        changeDetails->oldObjectsData = oldObjectsData;
    }
    else {
        id oldValue = nil;
        if (options & NSKeyValueObservingOptionOld) {
            oldValue = [object valueForKeyPath:keyPath];
            if (!oldValue) {
                oldValue = [NSNull null];
            }
        }
        
        *detailsRetained = NO;
        
        changeDetails->kind = NSKeyValueChangeSetting;
        changeDetails->oldValue = oldValue;
        changeDetails->newValue = nil;
        changeDetails->indexes = nil;
        changeDetails->oldObjectsData = nil;
    }
}

void NSKeyValueDidChangeByOrderedToManyMutation(NSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL exactMatch, int options, NSKeyValueChangeDetails changeDetails) {
    if (exactMatch) {
        id newValue = nil;
        
        NSIndexSet *indexes = changeDetails.indexes;
        
        NSString *keypathTSD = _CFGetTSD(NSKeyValueObservingKeyPathTSDKey);
        id objectTSD = _CFGetTSD(NSKeyValueObservingObjectTSDKey);
        if (!keypathTSD || keypathTSD != keyPath || objectTSD != object) {
            _CFSetTSD(NSKeyValueObservingObjectTSDKey, object, NULL);
            _CFSetTSD(NSKeyValueObservingKeyPathTSDKey, keyPath, NULL);
            
            newValue = [object valueForKey:keyPath];
            
            _CFSetTSD(NSKeyValueObservingObjectTSDKey, NULL, NULL);
            _CFSetTSD(NSKeyValueObservingKeyPathTSDKey, NULL, NULL);
            
            if (newValue) {
                if ([newValue isKindOfClass:NSOrderedSet.self]) {
                    if (changeDetails.kind == NSKeyValueChangeReplacement) {
                        id *oldObjs = (id *)[changeDetails.oldObjectsData bytes];
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
                        [changeDetails.oldObjectsData release];
                        changeDetails.oldObjectsData = nil;
                    }
                    if (changeDetails.kind == NSKeyValueChangeInsertion) {
                        __block NSUInteger offset = 0;
                        __block NSMutableIndexSet *copiedIndexes = nil;
                        id *oldObjs = (id *)[changeDetails.oldObjectsData bytes];
                        NSUInteger oldObjsCount = changeDetails.oldObjectsData.length / sizeof(id);
                        
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
                        [changeDetails.oldObjectsData release];
                        changeDetails.oldObjectsData = nil;
                    }
                }
            }
        }
        
        NSArray *newObjects = nil;
        if ((options & NSKeyValueObservingOptionNew) && changeDetails.kind != NSKeyValueChangeRemoval) {
            if (!newValue) {
                newValue = [object valueForKey:keyPath];
            }
            
            newObjects = [newValue objectsAtIndexes:indexes];
        }
        
        resultChangeDetails->kind = changeDetails.kind;
        resultChangeDetails->oldValue = changeDetails.oldValue;
        resultChangeDetails->newValue = newObjects;
        resultChangeDetails->indexes = indexes;
        resultChangeDetails->oldObjectsData = changeDetails.oldObjectsData;
    }
    else {
        id newValue = nil;
        if (options & NSKeyValueObservingOptionNew) {
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
        resultChangeDetails->oldObjectsData = changeDetails.oldObjectsData;
    }
}

void NSKeyValueWillChangeBySetMutation(NSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, NSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained) {
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
            case NSKeyValueMinusSetMutation: {
                kind = NSKeyValueChangeRemoval;
                
                if (options & NSKeyValueObservingOptionOld) {
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
            case NSKeyValueIntersectSetMutation: {
                kind = NSKeyValueChangeRemoval;
                
                if (options & NSKeyValueObservingOptionOld) {
                    //loc_D0F6F
                    oldValue = [[object valueForKey:keyPath] mutableCopy];
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
                    currentValue = [object valueForKey:keyPath];
                    oldValue = [currentValue mutableCopy];
                    if (changeInfo->objects) {
                        [oldValue minusSet:changeInfo->objects];
                    }
                }
                
                if (options & NSKeyValueObservingOptionNew) {
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
        changeDetails->oldObjectsData = oldObjectsData;
    }
    else {
        //loc_D0E23
        id oldValue = nil;
        if (options & NSKeyValueObservingOptionOld) {
            oldValue = [object valueForKeyPath:keyPath];
            if (!oldValue) {
                oldValue = [NSNull null];
            }
        }
        
        *detailsRetained = NO;
        
        changeDetails->kind = NSKeyValueChangeSetting;
        changeDetails->oldValue = oldValue;
        changeDetails->newValue = nil;
        changeDetails->indexes = nil;
        changeDetails->oldObjectsData = nil;
    }
}

void NSKeyValueDidChangeBySetMutation(NSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, NSKeyValueChangeDetails changeDetails) {
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
        resultChangeDetails->oldObjectsData = changeDetails.oldObjectsData;
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
    changeDetails->oldObjectsData = nil;
}

void NSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueChangeDetails changeDetails , NSKeyValuePropertyForwardingValues forwardingValues, NSKVOPendingInfoPerThreadPush *pendingInfo) {
    NSKVOPendingChangeNotification *pendingNotification = NSAllocateScannedUncollectable(sizeof(NSKVOPendingChangeNotification));
    pendingNotification->retainCount = 1;
    pendingNotification->unknow2 = pendingInfo->count;
    pendingNotification->object = [object retain];
    pendingNotification->keyOrKeys = [keyOrKeys copy];
    pendingNotification->observationInfo = [pendingInfo->observationInfo retain];
    pendingNotification->observance = observance;
    pendingNotification->kind = changeDetails.kind;
    pendingNotification->oldValue = [changeDetails.oldValue retain];
    pendingNotification->newValue = [changeDetails.newValue retain];
    pendingNotification->indexes = [changeDetails.indexes retain];
    pendingNotification->oldObjectsData = [changeDetails.oldObjectsData retain];
    pendingNotification->forwardingValues_p1 = [forwardingValues.p1 retain];
    pendingNotification->forwardingValues_p2 = [forwardingValues.p2 retain];
    if(pendingNotification->observance) {
        dispatch_once(&isVMWare_onceToken, ^{
            isVMWare_doWorkarounds =  _CFAppVersionCheckLessThan("com.vmware.fusion", 5, 0, 0x0BFF00000);
        });
        if(!isVMWare_doWorkarounds) {
            [pendingNotification->observance.observer retain];
        }
    }
    CFArrayAppendValue(pendingInfo->pendingArray, pendingNotification);
    NSKVOPendingNotificationRelease(NULL,pendingNotification);
}

void NSKeyValuePushPendingNotificationLocal(id object, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueChangeDetails changeDetails , NSKeyValuePropertyForwardingValues forwardingValues, NSKVOPendingInfoLocalPush *pendingInfo) {
    //count 已经增长到 capacity
    if(pendingInfo->detailsCount == pendingInfo->capacity) {
        //扩容两倍
        pendingInfo->capacity = pendingInfo->detailsCount * 2;
        //detailsBuff来自栈(局部变量)
        if(pendingInfo->isStackBuff) {
            //分配新的内存
            void *detailsBuff = NSAllocateScannedUncollectable(pendingInfo->capacity * sizeof(NSKVOPendingInfoLocalDetail));
            //将旧的detailsBuff拷贝到新buff
            memmove(detailsBuff, pendingInfo->detailsBuff,pendingInfo->detailsCount * sizeof(NSKVOPendingInfoLocalDetail));
            pendingInfo->detailsBuff = detailsBuff;
            pendingInfo->isStackBuff = NO;
        }
        //detailsBuff来自堆
        else {
            //直接realloc内存
            void *detailsBuff = NSReallocateScannedUncollectable(pendingInfo->detailsBuff,pendingInfo->capacity * sizeof(NSKVOPendingInfoLocalDetail));
            pendingInfo->detailsBuff = detailsBuff;
        }
    }
    
    //新detail指针
    NSKVOPendingInfoLocalDetail *detail = pendingInfo->detailsBuff + pendingInfo->detailsCount;
    //插入新detail后， count加一
    pendingInfo->detailsCount += 1;

    detail->observance = observance;
    detail->kind = changeDetails.kind;
    detail->oldValue = changeDetails.oldValue;
    detail->newValue = changeDetails.newValue;
    detail->indexes = changeDetails.indexes;
    detail->oldObjectsData = changeDetails.oldObjectsData;
    detail->forwardingValues_p1 = forwardingValues.p1;
    detail->forwardingValues_p2 = forwardingValues.p2;
    detail->p5 = pendingInfo->p5;
    detail->keyOrKeys = keyOrKeys;
    
    [changeDetails.oldValue retain];
    [forwardingValues.p1 retain];
    [observance.observer retain];
}

BOOL NSKeyValuePopPendingNotificationLocal(id object,id keyOrKeys, NSKeyValueObservance **popedObservance, NSKeyValueChangeDetails *popedChangeDetails,NSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, NSKVOPendingInfoLocalPop* pendingInfo) {
    
    [pendingInfo->observer release];
    [pendingInfo->oldValue release];
    [pendingInfo->forwardValues_p1 release];
    
    while(pendingInfo->detailsCount > 0) {
        pendingInfo->detailsCount --;
        
        NSKVOPendingInfoLocalDetail *detail = pendingInfo->detailsBuff + pendingInfo->detailsCount;
        
        if (detail->observance) {
            if(!_NSKeyValueCheckObservationInfoForPendingNotification(object, detail->observance, pendingInfo->observationInfo)) {
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
        popedChangeDetails->oldObjectsData = detail->oldObjectsData;
        
        popedForwardValues->p1 = detail->forwardingValues_p1;
        popedForwardValues->p2 = detail->forwardingValues_p1;
        
        *popedKeyOrKeys = detail->keyOrKeys;
        
        pendingInfo->observer = detail->observance.observer;
        pendingInfo->oldValue = detail->oldValue;
        pendingInfo->forwardValues_p1 = detail->forwardingValues_p1;
        
        return YES;
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
    resultChangeDetails->oldObjectsData = changeDetails.oldObjectsData;
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

BOOL NSKeyValuePopPendingNotificationPerThread(id object,id keyOrKeys, NSKeyValueObservance **popedObservance, NSKeyValueChangeDetails *popedChangeDetails,NSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, NSKVOPendingInfoPerThreadPop* pendingInfo) {
    if(pendingInfo->lastPopedNotification) {
        CFArrayRemoveValueAtIndex(pendingInfo->pendingArray, pendingInfo->lastPopdIndex);
        if(pendingInfo->lastPopedNotification->unknow2 != 0) {
            return NO;
        }
    }
    else {
        pendingInfo->lastPopdIndex = pendingInfo->pendingCount;
    }
    
    for (NSInteger i = pendingInfo->lastPopdIndex - 1; i >=0 ; --i) {
        NSKVOPendingChangeNotification *changeNotification = (NSKVOPendingChangeNotification *)CFArrayGetValueAtIndex(pendingInfo->pendingArray, i);
        if (changeNotification->object == object && [changeNotification->keyOrKeys isEqual:keyOrKeys] && (!pendingInfo->observance || changeNotification->observance == pendingInfo->observance)) {
            if (!changeNotification->observationInfo || _NSKeyValueCheckObservationInfoForPendingNotification(changeNotification->object,changeNotification->observance, changeNotification->observationInfo)) {
                *popedObservance = changeNotification->observance;
                
                popedChangeDetails->kind = changeNotification->kind;
                popedChangeDetails->oldValue = changeNotification->oldValue;
                popedChangeDetails->newValue = changeNotification->newValue;
                popedChangeDetails->indexes = changeNotification->indexes;
                popedChangeDetails->oldObjectsData = changeNotification->oldObjectsData;
                
                popedForwardValues->p1 = changeNotification->forwardingValues_p1;
                popedForwardValues->p2 = changeNotification->forwardingValues_p2;
                
                *popedKeyOrKeys = keyOrKeys;
                
                pendingInfo->lastPopedNotification = changeNotification;
                pendingInfo->lastPopdIndex = i;
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
                        [changeDetails.oldObjectsData release];
                    }
                    
                    [changeDictionary release];
                }
            }
        }
    }
}

void NSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,NSKeyValueDidChangeByCallback didChangeByCallback, NSKeyValuePopPendingNotificationCallback popPendingNotificationCallback, void *pendingInfo) {
    NSKeyValueObservance *popedObservance = nil;
    NSKeyValueChangeDetails popedChangeDetails = {0};
    NSKeyValuePropertyForwardingValues popedForwardValues = {0};
    id popedKeyOrKeys = nil;
    NSKeyValueChangeDictionary *changeDictionary = nil;
    
    while(popPendingNotificationCallback(object, keyOrKeys, &popedObservance, &popedChangeDetails, &popedForwardValues, &popedKeyOrKeys, pendingInfo)) {
        [popedObservance.property object:object withObservance:popedObservance didChangeValueForKeyOrKeys:popedKeyOrKeys recurse:YES forwardingValues:popedForwardValues];
        BOOL exactMatch = NO;
        if(!isASet) {
            exactMatch = CFEqual(popedObservance.property.keyPath, popedKeyOrKeys);
        }
        
        NSKeyValueChangeDetails resultDetails = {0};
        
        didChangeByCallback(&resultDetails, object, popedObservance.property.keyPath, exactMatch, popedObservance.options, popedChangeDetails);
        
        popedChangeDetails = resultDetails;
        
        NSKeyValueNotifyObserver(popedObservance.observer,popedObservance.property.keyPath, object,popedObservance.context,popedObservance.originalObservable,NO,popedChangeDetails, &changeDictionary);
    }
    
    [changeDictionary release];
}

@end
