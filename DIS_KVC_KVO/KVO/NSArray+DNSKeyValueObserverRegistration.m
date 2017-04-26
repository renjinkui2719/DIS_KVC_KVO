//
//  NSArray+DNSKeyValueObserverRegistration.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/29.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSArray+DNSKeyValueObserverRegistration.h"
#import "DNSKeyValueObserverCommon.h"
#import "DNSKeyValuePropertyCreate.h"
#import "NSObject+DNSKeyValueObserverRegistration.h"
#import "NSObject+DNSKeyValueObservingPrivate.h"
#import <objc/runtime.h>
#import <pthread.h>

@implementation NSArray (DNSKeyValueObserverRegistration)

- (void)d_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> addObserver:forKeyPath:options:context:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)d_addObserver:(NSObject *)observer toObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    pthread_mutex_lock(&_DNSKeyValueObserverRegistrationLock);
    _DNSKeyValueObserverRegistrationLockOwner = pthread_self();
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        DNSKeyValueProperty *property = nil;
        if (objectClass) {
            property = DNSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _d_addObserver:observer forProperty:property options:options context:context];
    }
    _DNSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DNSKeyValueObserverRegistrationLock);
}

- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> removeObserver:forKeyPath:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> removeObserver:forKeyPath:context:] is not supported. Key path: %@", self.class, self, keyPath];
}

- (void)d_removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath {
    pthread_mutex_lock(&_DNSKeyValueObserverRegistrationLock);
    _DNSKeyValueObserverRegistrationLockOwner = pthread_self();
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        DNSKeyValueProperty *property = nil;
        if (objectClass) {
            property = DNSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _d_removeObserver:observer forProperty:property];
    }
    _DNSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DNSKeyValueObserverRegistrationLock);
}

- (void)d_removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    DNSKeyValueObservingTSD *TSD = _CFGetTSD(DNSKeyValueObservingTSDKey);
    if (!TSD) {
        TSD = (DNSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(DNSKeyValueObservingTSD));
        _CFSetTSD(DNSKeyValueObservingTSDKey, TSD, DNSKeyValueObservingTSDDestroy);
    }
    
    DNSKeyValueObservingTSD backTSD = *(TSD);
    
    pthread_mutex_lock(&_DNSKeyValueObserverRegistrationLock);
    _DNSKeyValueObserverRegistrationLockOwner = pthread_self();
    
    TSD->implicitObservanceRemovalInfo.context = context;
    TSD->implicitObservanceRemovalInfo.flag = YES;
    
    for(NSUInteger index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index]) {
        id object = [self objectAtIndex:index];
        Class objectClass = object_getClass(object);
        DNSKeyValueProperty *property = nil;
        if (objectClass) {
            property = DNSKeyValuePropertyForIsaAndKeyPath(objectClass, keyPath);
        }
        [object _removeObserver:observer forProperty:property];
    }
    _DNSKeyValueObserverRegistrationLockOwner = NULL;
    pthread_mutex_unlock(&_DNSKeyValueObserverRegistrationLock);
    
    *(TSD) = backTSD;
}

@end
