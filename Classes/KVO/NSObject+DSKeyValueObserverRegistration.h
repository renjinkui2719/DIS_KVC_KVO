//
//  NSObject+DSKeyValueObserverRegistration.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

extern pthread_mutex_t _DSKeyValueObserverRegistrationLock;
extern pthread_t _DSKeyValueObserverRegistrationLockOwner;
extern BOOL _DSKeyValueObserverRegistrationEnableLockingAssertions;

void DSKeyValueObserverRegistrationLockUnlock();
void DSKeyValueObserverRegistrationLockLock();
void DSKeyValueObservingAssertRegistrationLockNotHeld();

@class DSKeyValueProperty;

@interface NSObject (DSKeyValueObserverRegistration)

- (void)d_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

- (void)_d_addObserver:(id)observer forProperty:(DSKeyValueProperty *)property options:(int)options context:(void *)context;
- (void)_d_removeObserver:(id)observer forProperty:(DSKeyValueProperty *)property;
@end


