//
//  NSObject+NSKeyValueObserverRegistration.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueProperty;

extern pthread_mutex_t _NSKeyValueObserverRegistrationLock;
extern pthread_t _NSKeyValueObserverRegistrationLockOwner;
void NSKeyValueObserverRegistrationLockUnlock();
void NSKeyValueObserverRegistrationLockLock();

@interface NSObject (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context NS_AVAILABLE(10_7, 5_0);
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

- (void)_addObserver:(id)observer forProperty:(NSKeyValueProperty *)property options:(int)options context:(void *)context;
- (void)_removeObserver:(id)observer forProperty:(NSKeyValueProperty *)property;
@end


