//
//  DSKeyValueProxyCaching.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyCaching.h"
#import "DSKeyValueProxyShareKey.h"
#import "DSKeyValueProxyGetter.h"
#import "DSKeyValueCodingCommon.h"

OSSpinLock DSKeyValueProxySpinLock = OS_SPINLOCK_INIT;

NSUInteger DSKeyValueProxyHash(const void *item, NSUInteger (* _Nullable size)(const void *item)) {
    DSKeyValueProxyLocator locator =  [(id)item _proxyLocator];
    return (NSUInteger)locator.container ^ locator.key.hash;
}

BOOL DSKeyValueProxyIsEqual(const void *item1, const void*item2, NSUInteger (* _Nullable size)(const void *item)) {
    DSKeyValueProxyLocator locator1 =  [(id)item1 _proxyLocator];
    DSKeyValueProxyLocator locator2 =  [(id)item2 _proxyLocator];
    if (locator1.container == locator2.container) {
        if (locator1.key == locator2.key || [locator1.key isEqual:locator2.key]) {
            return YES;
        }
    }
    return NO;
}

NSHashTable * _DSKeyValueProxyShareCreate() {
    NSPointerFunctions *pointerFunctions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
    pointerFunctions.hashFunction = DSKeyValueProxyHash;
    pointerFunctions.isEqualFunction = DSKeyValueProxyIsEqual;
    NSHashTable *ht = [[NSHashTable alloc] initWithPointerFunctions:pointerFunctions capacity:0];
    [pointerFunctions release];
    return ht;
}

BOOL _DSKeyValueProxyDeallocate(id object) {
    OSSpinLockLock(&DSKeyValueProxySpinLock);
    if(NSExtraRefCount(object) == 0) {
        [[[object class] _proxyShare] removeObject:object];
        OSSpinLockUnlock(&DSKeyValueProxySpinLock);
        
        [object _proxyNonGCFinalize];
        
        OSSpinLockLock(&DSKeyValueProxySpinLock);
        
        DSKeyValueProxyNonGCPoolPointer *pointer = [[object class] _proxyNonGCPoolPointer];
#if 0
        if(pointer->p1 <= 3) {
            *(pointer + pointer->p1*4 + 4) = object;
            pointer->p1 ++;
            OSSpinLockUnlock(&DSKeyValueProxySpinLock);
            return NO;
        }
#endif
        OSSpinLockUnlock(&DSKeyValueProxySpinLock);
        return YES;
    }
    OSSpinLockUnlock(&DSKeyValueProxySpinLock);
    return NO;
}


