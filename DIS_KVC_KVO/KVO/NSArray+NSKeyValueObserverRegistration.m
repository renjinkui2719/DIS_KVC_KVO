//
//  NSArray+NSKeyValueObserverRegistration.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/29.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSArray+NSKeyValueObserverRegistration.h"
#import "NSKeyValueObserverCommon.h"
#import "NSKeyValuePropertyCreate.h"
#import "NSObject+NSKeyValueObserverRegistration.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import <objc/runtime.h>
#import <pthread.h>

@implementation NSArray (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> addObserver:forKeyPath:options:context:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)addObserver:(NSObject *)observer toObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        NSKeyValueProperty *property = nil;
        if (objectClass) {
            property = NSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _addObserver:observer forProperty:property options:options context:context];
    }
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> removeObserver:forKeyPath:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> removeObserver:forKeyPath:context:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath {
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        NSKeyValueProperty *property = nil;
        if (objectClass) {
            property = NSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _removeObserver:observer forProperty:property];
    }
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
}

- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    if (!TSD) {
        TSD = (NSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(NSKeyValueObservingTSD));
        _CFSetTSD(NSKeyValueObservingTSDKey, TSD, NSKeyValueObservingTSDDestroy);
    }
    
    NSKeyValueObservingTSD backTSD = *(TSD);
    
    pthread_mutex_lock(&_NSKeyValueObserverRegistrationLock);
    _NSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    TSD->implicitObservanceRemovalInfo.context = context;
    TSD->implicitObservanceRemovalInfo.flag = YES;
    
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        NSKeyValueProperty *property = nil;
        if (objectClass) {
            property = NSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _removeObserver:observer forProperty:property];
    }
    _NSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_NSKeyValueObserverRegistrationLock);
    
    *(TSD) = backTSD;
}

@end
