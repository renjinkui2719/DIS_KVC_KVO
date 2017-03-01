//
//  NSObject+NSKeyValueObserverNotification.m
//  KV
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
#import <pthread.h>
#import <objc/runtime.h>

extern pthread_mutex_t _NSKeyValueObserverRegistrationLock;
extern pthread_t _NSKeyValueObserverRegistrationLockOwner;
extern OSSpinLock NSKeyValueObservationInfoSpinLock;
extern BOOL _NSKeyValueObserverRegistrationEnableLockingAssertions;
extern dispatch_once_t isVMWare_onceToken;
extern BOOL isVMWare_doWorkarounds;

extern void os_lock_lock(void *);
extern void os_lock_unlock(void *);
extern void *_CFGetTSD(uint32_t slot);
extern void *_CFSetTSD(uint32_t slot, void *newVal, void (*destructor)(void *));
extern void *NSAllocateScannedUncollectable(size_t);
extern void *NSReallocateScannedUncollectable(void *, size_t);


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
    
    if(observationInfo || implicitObservationInfo) {
        CFMutableArrayRef pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:YES];
        if(observationInfo) {
            NSKVOPendingInfoPerThreadPush pendingInfo = {pendingArray, 1, observationInfo};
            NSKeyValueWillChange(self,key,NO,observationInfo,NSKeyValueWillChangeBySetting,nil,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread,&pendingInfo,nil);
        }
        //loc_117F1
        if(implicitObservationInfo) {
            NSKVOPendingInfoPerThreadPush pendingInfo = {pendingArray, 1, NULL};
            NSKeyValueWillChange(self,key,NO,implicitObservationInfo,NSKeyValueWillChangeBySetting,nil,(NSKeyValuePushPendingNotificationCallback)NSKeyValuePushPendingNotificationPerThread,&pendingInfo,nil);
        }
        //loc_1182F
    }
    //loc_1182F
    [observationInfo release];
    if(totalObservanceCount) {
        NSUInteger i=0;
        do {
            [observance_objs[i] release];
        }while(totalObservanceCount);
    }
}

- (void)didChangeValueForKey:(NSString *)key {
    CFMutableArrayRef pendingArray = [self _pendingChangeNotificationsArrayForKey:key create:YES];
    if(pendingArray) {
        NSUInteger pendingCount = CFArrayGetCount(pendingArray);
        if(pendingCount) {
            NSKVOPendingInfoPerThreadPop pendingInfo = {pendingArray, pendingCount, NULL, ~0, 0};
            NSKeyValueDidChange(self,key,0,NSKeyValueDidChangeBySetting,(NSKeyValuePopPendingNotificationCallback)NSKeyValuePopPendingNotificationPerThread,&pendingInfo);
        }
    }
}

- (void)willChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    
}

- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    
}

- (void)willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {

}

- (void)didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects {
    
}



void NSKeyValueObservingAssertRegistrationLockNotHeld() {
    if(_NSKeyValueObserverRegistrationEnableLockingAssertions && _NSKeyValueObserverRegistrationLockOwner == pthread_self()) {
        assert(pthread_self() != _NSKeyValueObserverRegistrationLockOwner);
    }
}

void NSKVONotify(id observer, NSString *keyPath, id object, NSKeyValueChangeDictionary *change, void *context) {
    NSKeyValueObservingAssertRegistrationLockNotHeld();
    [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

void NSKeyValueNotifyObserver(id observer,NSString * keyPath, id object, void *context, id originalObservable, BOOL isPriorNotification, NSKeyValueChangeDetails changeDetails, NSKeyValueChangeDictionary **pChange) {
    if([observer respondsToSelector:@selector(_observeValueForKeyPath:ofObject:changeKind:oldValue:newValue:indexes:context:)]) {
        
    }
    else {
        if(*pChange) {
            [*pChange setDetailsNoCopy:changeDetails originalObservable:originalObservable];
        }
        else {
            *pChange =  [[NSKeyValueChangeDictionary alloc] initWithDetailsNoCopy:changeDetails originalObservable:originalObservable isPriorNotification:isPriorNotification];
        }
        NSUInteger retainCountBefore = [*pChange retainCount];
        NSKVONotify(observer, keyPath, object, *pChange, context);
        if(retainCountBefore != (NSUInteger)INTMAX_MAX && retainCountBefore != [*pChange retainCount]) {
            [*pChange retainObjects];
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

void NSKeyValueWillChangeBySetting(NSKeyValueChangeDetails *changeDetails, id object, NSString *affectedKeyPath, BOOL match, int options, NSDictionary *oldValueDict, BOOL *detailsRetained) {
    
    id oldValue = nil;
    if(options & NSKeyValueObservingOptionOld) {
        if(oldValueDict) {
            oldValue = [oldValueDict objectForKey:affectedKeyPath];
        }
        else {
            oldValue = [object valueForKeyPath:affectedKeyPath];
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
    changeDetails->observationInfo = nil;
}

void NSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueChangeDetails changeDetails , NSKeyValuePropertyForwardingValues forwardingValues, NSKVOPendingInfoPerThreadPush *pendingInfo) {
    NSKVOPendingNotification *pendingNotification = NSAllocateScannedUncollectable(sizeof(NSKVOPendingNotification));
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
    pendingNotification->observationInfo = [changeDetails.observationInfo retain];
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
    *((id *)start) = changeDetails.observationInfo; start += sizeof(id);
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


void NSKeyValueWillChange(id object, id keyOrKeys, BOOL isASet, NSKeyValueObservationInfo *observationInfo, NSKeyValueWillChangeByCallback willChangeByCallback, NSDictionary *oldValueDict, NSKeyValuePushPendingNotificationCallback pushPendingNotificationCallback, void *pendingInfo, NSKeyValueObservance *observance) {
    
    NSUInteger observanceCount = _NSKeyValueObservationInfoGetObservanceCount(observationInfo);
    
    NSKeyValueObservance *observance_objs[observanceCount];
    _NSKeyValueObservationInfoGetObservances(observationInfo, observance_objs, observanceCount);
    
    if(observanceCount) {
        NSUInteger i = 0 ;
        do {
            NSKeyValueObservance *observanceObj = observance_objs[i];
            if(!observance || observance == observanceObj) {
                NSString* keyPath = nil;
                BOOL exactMatch = NO;
                NSKeyValuePropertyForwardingValues forwardingValues = {0};
                
                if(isASet) {
                    keyPath = [observanceObj.property keyPathIfAffectedByValueForMemberOfKeys:keyOrKeys];
                }
                else {
                    keyPath = [observanceObj.property keyPathIfAffectedByValueForKey:keyOrKeys exactMatch:&exactMatch];
                }
                if(keyPath) {
                    if( [observanceObj.property object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:YES forwardingValues:&forwardingValues] ) {
                        NSKeyValueChangeDetails changeDetails = {0};
                        BOOL detailsRetained;
                        NSKeyValueChangeDictionary *change = nil;
                        
                        willChangeByCallback(&changeDetails, object, keyPath,exactMatch,observanceObj.options, oldValueDict, &detailsRetained);
                        pushPendingNotificationCallback(object, keyOrKeys, observance, changeDetails , forwardingValues, pendingInfo);
                        
                        if(observanceObj.options & NSKeyValueObservingOptionPrior) {
                            NSKeyValueNotifyObserver(observance.observer, keyPath,  object, observance.context, observance.originalObservable, YES,changeDetails, &change);
                        }

                        if(detailsRetained) {
                            [changeDetails.oldValue release];
                            [changeDetails.newValue release];
                            [changeDetails.indexes release];
                            [changeDetails.observationInfo release];
                        }
                        [change release];
                    }
                }
            }
        }while(++i != observanceCount);
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
    
    //loc_558F9
    if(pendingInfo->index > 0) {
        NSUInteger i = pendingInfo->index - 1;
        do {
            NSKVOPendingNotification *pendingNorification = (NSKVOPendingNotification *)CFArrayGetValueAtIndex(pendingInfo->pendingArray, i);
            if(pendingNorification->object == object) {
                if([pendingNorification->keyOrKeys isEqual:keyOrKeys]) {
                    if(!pendingInfo->observance || pendingNorification->observance == pendingInfo->observance) {
                        if(pendingNorification->observationInfo) {
                            if(!_NSKeyValueCheckObservationInfoForPendingNotification(pendingNorification->object,pendingNorification->observance, pendingNorification->observationInfo)) {
                                CFArrayRemoveValueAtIndex(pendingInfo->pendingArray, i);
                                if(!pendingNorification->unknow2) {
                                    continue;
                                }
                                else {
                                   //loc_559A3
                                    break;
                                }
                            }
                        }
                        //loc_559AE
                        *observance = pendingNorification->observance;
                        
                        changeDetails->observationInfo = pendingNorification->observationInfo;
                        changeDetails->kind = pendingNorification->kind;
                        changeDetails->oldValue = pendingNorification->oldValue;
                        changeDetails->newValue = pendingNorification->newValue;
                        changeDetails->indexes = pendingNorification->indexes;
                        
                        forwardValues->p1 = pendingNorification->forwardingValues_p1;
                        forwardValues->p2 = pendingNorification->forwardingValues_p2;
                        
                        *findKeyOrKeys = keyOrKeys;
                        
                        pendingInfo->notification = pendingNorification;
                        pendingInfo->index = i;
                        //loc_559A3
                        return YES;
                    }
                }
            }
        }while(i-- > 1);
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

void NSKeyValueDidChangeBySetting(NSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL equal, int options, NSKeyValueChangeDetails changeDetails) {
    id newValue = nil;
    if(equal) {
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
    resultChangeDetails->observationInfo = changeDetails.observationInfo;
}

void NSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,NSKeyValueDidChangeByCallback didChangeByCallback, NSKeyValuePopPendingNotificationCallback popPendingNotificationCallback, void *pendingInfo) {
    NSKeyValueObservance *observance = nil;
    NSKeyValueChangeDetails changeDetails = {0};
    NSKeyValuePropertyForwardingValues forwardValues = {0};
    id findKeyOrKeys = nil;
    NSKeyValueChangeDictionary *changeDictionary = nil;
    
    BOOL find = popPendingNotificationCallback(object, keyOrKeys, &observance, &changeDetails, &forwardValues, &findKeyOrKeys, pendingInfo);
    
    if(find) {
        do {
            [observance.property object:object withObservance:observance didChangeValueForKeyOrKeys:findKeyOrKeys recurse:YES forwardingValues:forwardValues];
            BOOL equal = NO;
            if(!isASet) {
                equal = CFEqual(observance.property.keyPath, findKeyOrKeys);
            }
            
            NSKeyValueChangeDetails resultDetails = {0};
            didChangeByCallback(&resultDetails, object, observance.property.keyPath, equal, observance.options, changeDetails);
            changeDetails = resultDetails;

            NSKeyValueNotifyObserver(observance.observer,observance.property.keyPath, object,observance.context,observance.originalObservable,NO,changeDetails, &changeDictionary);
            
            find = popPendingNotificationCallback(object, keyOrKeys, &observance, &changeDetails, &forwardValues, &findKeyOrKeys, pendingInfo);
        }while(find);
    }
    
    [changeDictionary release];
}

@end
