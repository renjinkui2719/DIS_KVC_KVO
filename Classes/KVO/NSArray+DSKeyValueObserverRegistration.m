//
//  NSArray+DSKeyValueObserverRegistration.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/29.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSArray+DSKeyValueObserverRegistration.h"
#import "DSKeyValueObserverCommon.h"
#import "DSKeyValuePropertyCreate.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueObservingPrivate.h"


@implementation NSArray (DSKeyValueObserverRegistration)

- (void)d_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> addObserver:forKeyPath:options:context:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)d_addObserver:(NSObject *)observer toObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        DSKeyValueProperty *property = nil;
        if (objectClass) {
            property = DSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _d_addObserver:observer forProperty:property options:options context:context];
    }
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
}

- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> removeObserver:forKeyPath:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> removeObserver:forKeyPath:context:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)d_removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath {
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        DSKeyValueProperty *property = nil;
        if (objectClass) {
            property = DSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _d_removeObserver:observer forProperty:property];
    }
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
}

- (void)d_removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if (!TSD) {
        TSD = (DSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
        _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
    }
    
    DSKeyValueObservingTSD backTSD = *(TSD);
    
    pthread_mutex_lock(&_DSKeyValueObserverRegistrationLock);
    _DSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    TSD->implicitObservanceRemovalInfo.context = context;
    TSD->implicitObservanceRemovalInfo.shouldCompareContext = YES;
    
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        DSKeyValueProperty *property = nil;
        if (objectClass) {
            property = DSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _d_removeObserver:observer forProperty:property];
    }
    _DSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DSKeyValueObserverRegistrationLock);
    
    *(TSD) = backTSD;
}

@end
