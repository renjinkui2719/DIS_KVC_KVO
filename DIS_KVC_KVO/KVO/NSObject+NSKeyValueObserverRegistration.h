//
//  NSObject+NSKeyValueObserverRegistration.h
//  KV
//
//  Created by renjinkui on 2017/1/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context NS_AVAILABLE(10_7, 5_0);
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

void NSKeyValueObserverRegistrationLockUnlock();
void NSKeyValueObserverRegistrationLockLock();
