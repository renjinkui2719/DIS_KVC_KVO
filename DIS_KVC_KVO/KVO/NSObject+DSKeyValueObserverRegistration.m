//
//  DSObject+DSKeyValueObserverRegistration.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+DSKeyValueObserverRegistration.h"
#import "DSKeyValueProperty.h"
#import "DSKeyValueContainerClass.h"
#import "DSKeyValueObservance.h"
#import "DSKeyValueObservationInfo.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "NSObject+DSKeyValueObserverNotification.h"
#import "DSKeyValueChangeDictionary.h"
#import "DSKeyValuePropertyCreate.h"
#import "DSKeyValueObserverCommon.h"

pthread_mutex_t _DSKeyValueObserverRegistrationLock = PTHREAD_MUTEX_INITIALIZER;
pthread_t _DSKeyValueObserverRegistrationLockOwner = NULL;

NSString *const DSKeyValueChangeOriginalObservableKey = @"originalObservable";
NSString *const DSKeyValueChangeKindKey = @"originalObservable";
NSString *const DSKeyValueChangeNewKey = @"originalObservable";
NSString *const DSKeyValueChangeOldKey = @"originalObservable";
NSString *const DSKeyValueChangeIndexesKey = @"originalObservable";
NSString *const DSKeyValueChangeNotificationIsPriorKey = @"originalObservable";

void DSKeyValueObserverRegistrationLockUnlock() {
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
}

void DSKeyValueObserverRegistrationLockLock() {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
}

@implementation NSObject (DSKeyValueObserverRegistration)

- (void)d_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(DSKeyValueObservingOptions)options context:(nullable void *)context {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    DSKeyValueProperty * property = DSKeyValuePropertyForIsaAndKeyPath(self.class,keyPath);
    
    [self _d_addObserver:observer forProperty:property options:options context:context];
    
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
}

- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if (!TSD) {
        TSD = (DSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
        _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
    }

    DSKeyValueObservingTSD backTSD = *(TSD);
    TSD->implicitObservanceRemovalInfo.context = context;
    TSD->implicitObservanceRemovalInfo.flag = YES;
    
    [self removeObserver:observer forKeyPath:keyPath];
    
    *(TSD) = backTSD;
}

- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    DSKeyValueProperty * property = DSKeyValuePropertyForIsaAndKeyPath(self.class,keyPath);
    
    [self _d_removeObserver:observer forProperty:property];
    
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
}

- (void)_d_removeObserver:(id)observer forProperty:(DSKeyValueProperty *)property {
    DSKeyValueObservationInfo *retainedObervationInfo = _DSKeyValueRetainedObservationInfoForObject(self, property.containerClass);
    if (retainedObervationInfo) {
        void *context = NULL;
        BOOL flag = NO;
        id originalObservable = nil;
        BOOL fromCache = NO;
        DSKeyValueObservance *observance = nil;
        
        DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
        if (TSD && TSD->implicitObservanceRemovalInfo.relationshipObject == self && TSD->implicitObservanceRemovalInfo.observer == observer && [TSD->implicitObservanceRemovalInfo.keyPathFromRelatedObject isEqualToString:property.keyPath]) {
            originalObservable = TSD->implicitObservanceRemovalInfo.object;
            context = TSD->implicitObservanceRemovalInfo.context;
            flag = TSD->implicitObservanceRemovalInfo.flag;
        }
        DSKeyValueObservationInfo *createdObservationInfo = _DSKeyValueObservationInfoCreateByRemoving(retainedObervationInfo, observer, property, context, flag, originalObservable, &fromCache, &observance);
        if (observance) {
            [observance retain];
            _DSKeyValueReplaceObservationInfoForObject(self, property.containerClass, retainedObervationInfo, createdObservationInfo);
            [property object:self didRemoveObservance:observance recurse:YES];
            if (!createdObservationInfo) {
                if (self.class != property.containerClass.originalClass) {
                    object_setClass(self, property.containerClass.originalClass);
                }
            }
            [observance release];
            [createdObservationInfo release];
            [retainedObervationInfo release];
            
            return;
        }
    }

    [NSException raise:NSRangeException format:@"Cannot remove an observer <%@ %p> for the key path \"%@\" from <%@ %p> because it is not registered as an observer.",[observer class], observer, property.keyPath, self.class, self];
}

- (void)_d_addObserver:(id)observer forProperty:(DSKeyValueProperty *)property options:(int)options context:(void *)context {
    if(options & DSKeyValueObservingOptionInitial) {
        NSString *keyPath = [property keyPath];
        _DSKeyValueObserverRegistrationLockOwner = NULL;
        pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
        
        id newValue = nil;
        if (options & DSKeyValueObservingOptionNew) {
            id newValue = [self valueForKeyPath:keyPath];
            if (!newValue) {
                newValue = [NSNull null];
            }
        }
        
        DSKeyValueChangeDictionary *changeDictionary = nil;
        DSKeyValueChangeDetails changeDetails = {0};
        changeDetails.kind = DSKeyValueChangeSetting;
        changeDetails.oldValue = nil;
        changeDetails.newValue = newValue;
        changeDetails.indexes = nil;
        changeDetails.extraData = nil;
        
        DSKeyValueNotifyObserver(observer,keyPath, self, context, nil, NO,changeDetails, &changeDictionary);
        
        [changeDictionary release];
        
        pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
        _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    }
    
    DSKeyValueObservationInfo *retainedObservInfo = _DSKeyValueRetainedObservationInfoForObject(self,property.containerClass);
    
    DSKeyValueObservingTSD *TSD = NULL;
    id originalObservable = nil;
    if(options & DSKeyValueObservingOptionNew) {
        TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    }
    if (TSD) {
        originalObservable = TSD->implicitObservanceAdditionInfo.object;
    }
    BOOL fromCache = NO;
    DSKeyValueObservance *observance = nil;
    
    DSKeyValueObservationInfo *createdObservInfo = _DSKeyValueObservationInfoCreateByAdding(retainedObservInfo, observer, property, options, context, originalObservable,&fromCache,&observance);
   
    _DSKeyValueReplaceObservationInfoForObject(self,property.containerClass,retainedObservInfo,createdObservInfo);
    
    [property object:self didAddObservance:observance recurse:YES];
    
    Class isaForAutonotifying = [property isaForAutonotifying];
    if(isaForAutonotifying) {
        Class cls = object_getClass(self);
        if(cls != isaForAutonotifying) {
            object_setClass(self,isaForAutonotifying);
        }
    }
    
    [createdObservInfo release];
    
    [retainedObservInfo release];
}

@end


