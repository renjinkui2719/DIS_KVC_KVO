//
//  NSObject+NSKeyValueObserverRegistration.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+NSKeyValueObserverRegistration.h"
#import "NSKeyValueProperty.h"
#import "NSKeyValueContainerClass.h"
#import "NSKeyValueObservance.h"
#import "NSKeyValueObservationInfo.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import "NSObject+NSKeyValueObserverNotification.h"
#import "NSKeyValueChangeDictionary.h"
#import "NSKeyValuePropertyCreate.h"
#import "NSKeyValueObserverCommon.h"
#import <pthread.h>
#import <objc/runtime.h>

pthread_mutex_t _NSKeyValueObserverRegistrationLock = PTHREAD_MUTEX_INITIALIZER;
pthread_t _NSKeyValueObserverRegistrationLockOwner = NULL;

void NSKeyValueObserverRegistrationLockUnlock() {
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
}

void NSKeyValueObserverRegistrationLockLock() {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
}

@implementation NSObject (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    NSKeyValueProperty * property = NSKeyValuePropertyForIsaAndKeyPath(self.class,keyPath);
    
    [self _addObserver:observer forProperty:property options:options context:context];
    
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    if (!TSD) {
        TSD = (NSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(NSKeyValueObservingTSD));
        _CFSetTSD(NSKeyValueObservingTSDKey, TSD, NSKeyValueObservingTSDDestroy);
    }

    NSKeyValueObservingTSD backTSD = *(TSD);
    TSD->implicitObservanceRemovalInfo.context = context;
    TSD->implicitObservanceRemovalInfo.flag = YES;
    
    [self removeObserver:observer forKeyPath:keyPath];
    
    *(TSD) = backTSD;
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    NSKeyValueProperty * property = NSKeyValuePropertyForIsaAndKeyPath(self.class,keyPath);
    
    [self _removeObserver:observer forProperty:property];
    
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
}

- (void)_removeObserver:(id)observer forProperty:(NSKeyValueProperty *)property {
    NSKeyValueObservationInfo *retainedObervationInfo = _NSKeyValueRetainedObservationInfoForObject(self, property.containerClass);
    if (retainedObervationInfo) {
        void *context = NULL;
        BOOL flag = NO;
        id originalObservable = nil;
        BOOL fromCache = NO;
        NSKeyValueObservance *observance = nil;
        
        NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
        if (TSD && TSD->implicitObservanceRemovalInfo.relationshipObject == self && TSD->implicitObservanceRemovalInfo.observer == observer && [TSD->implicitObservanceRemovalInfo.keyPathFromRelatedObject isEqualToString:property.keyPath]) {
            originalObservable = TSD->implicitObservanceRemovalInfo.object;
            context = TSD->implicitObservanceRemovalInfo.context;
            flag = TSD->implicitObservanceRemovalInfo.flag;
        }
        NSKeyValueObservationInfo *createdObservationInfo = _NSKeyValueObservationInfoCreateByRemoving(retainedObervationInfo, observer, property, context, flag, originalObservable, &fromCache, &observance);
        if (observance) {
            [observance retain];
            _NSKeyValueReplaceObservationInfoForObject(self, property.containerClass, retainedObervationInfo, createdObservationInfo, NULL);
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

- (void)_addObserver:(id)observer forProperty:(NSKeyValueProperty *)property options:(int)options context:(void *)context {
    if(options & NSKeyValueObservingOptionInitial) {
        NSString *keyPath = [property keyPath];
        _NSKeyValueObserverRegistrationLockOwner = NULL;
        pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
        
        id newValue = nil;
        if (options & NSKeyValueObservingOptionNew) {
            id newValue = [self valueForKeyPath:keyPath];
            if (!newValue) {
                newValue = [NSNull null];
            }
        }
        
        NSKeyValueChangeDictionary *changeDictionary = nil;
        NSKeyValueChangeDetails changeDetails = {0};
        changeDetails.kind = NSKeyValueChangeSetting;
        changeDetails.oldValue = nil;
        changeDetails.newValue = newValue;
        changeDetails.indexes = nil;
        changeDetails.unknow1 = nil;
        
        NSKeyValueNotifyObserver(observer,keyPath, self, context, nil, NO,changeDetails, &changeDictionary);
        
        [changeDictionary release];
        
        pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
        _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    }
    
    NSKeyValueObservationInfo *retainedObservInfo = _NSKeyValueRetainedObservationInfoForObject(self,property.containerClass);
    
    NSKeyValueObservingTSD *TSD = NULL;
    id originalObservable = nil;
    if(options & NSKeyValueObservingOptionNew) {
        TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    }
    if (TSD) {
        originalObservable = TSD->implicitObservanceAdditionInfo.object;
    }
    BOOL fromCache = NO;
    NSKeyValueObservance *observance = nil;
    
    NSKeyValueObservationInfo *createdObservInfo = _NSKeyValueObservationInfoCreateByAdding(retainedObservInfo, observer, property, options, context, originalObservable,&fromCache,&observance);
   
    _NSKeyValueReplaceObservationInfoForObject(self,property.containerClass,retainedObservInfo,createdObservInfo,0);
    
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


