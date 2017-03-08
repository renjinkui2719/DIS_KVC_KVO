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
#import "NSKeyValueComputedProperty.h"
#import "NSKeyValueUnnestedProperty.h"
#import "NSKeyValueNestedProperty.h"
#import "NSKeyValueObservationInfo.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import "NSObject+NSKeyValueObserverNotification.h"
#import "NSKeyValueChangeDictionary.h"
#import "NSKeyValuePropertyCreate.h"

#import <pthread.h>
#import <objc/runtime.h>

extern pthread_mutex_t _NSKeyValueObserverRegistrationLock;
extern pthread_t _NSKeyValueObserverRegistrationLockOwner;
extern CFDictionaryRef NSKeyValueObservationInfoPerObject;
extern CFMutableSetRef NSKeyValueProperties;

NSKeyValueProperty *NSKeyValuePropertyForIsaAndKeyPath(Class isa, NSString *keypath);
NSKeyValueProperty * NSKeyValuePropertyForIsaAndKeyPathInner( Class isa, NSString *keyPath, CFMutableSetRef propertySet);
extern void *_CFGetTSD(uint32_t slot);
extern void *_CFSetTSD(uint32_t slot, void *newVal, void (*destructor)(void *));
extern NSKeyValueObservationInfo *_NSKeyValueRetainedObservationInfoForObject(id object, NSKeyValueContainerClass *containerClass);

@implementation NSObject (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    Class cls = object_getClass(self);
    NSKeyValueProperty * property = NSKeyValuePropertyForIsaAndKeyPath(cls,keyPath);
    
    [self _addObserver:observer forProperty:property options:options context:context];
    
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {

}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {

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
        
        //loc_1C02D
        NSKeyValueChangeDictionary *changeDict = nil;
        NSKeyValueChangeDetails changeDetails = {0};
        changeDetails.kind = NSKeyValueChangeSetting;
        changeDetails.oldValue = nil;
        changeDetails.newValue = newValue;
        changeDetails.indexes = nil;
        changeDetails.observationInfo = nil;
        
        NSKeyValueNotifyObserver(observer,keyPath, self, context, nil, NO,changeDetails, &changeDict);
        
        //loc_1C090
        [changeDict release];
        
        pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
        _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    }
    
    //loc_1C0D0

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
    
    if(retainedObservInfo) {
        [retainedObservInfo release];
    }
}

@end

void NSKeyValueObserverRegistrationLockUnlock() {
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
}

void NSKeyValueObserverRegistrationLockLock() {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
}
