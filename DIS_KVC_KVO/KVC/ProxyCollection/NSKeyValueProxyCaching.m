//
//  NSKeyValueProxyCaching.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyCaching.h"
#import "NSKeyValueProxyShareKey.h"
#import "NSKeyValueProxyGetter.h"


extern OSSpinLock NSKeyValueProxySpinLock;

NSHashTable * _NSKeyValueProxyShareCreate() {
    NSPointerFunctions *pointerFunctions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
    pointerFunctions.hashFunction = NSKeyValueProxyHash;
    pointerFunctions.isEqualFunction = NSKeyValueProxyIsEqual;
    NSHashTable *ht = [[NSHashTable alloc] initWithPointerFunctions:pointerFunctions capacity:0];
    [pointerFunctions release];
    return ht;
}

BOOL _NSKeyValueProxyDeallocate(id object) {
    OSSpinLockLock(&NSKeyValueProxySpinLock);
    if(NSExtraRefCount(object) == 0) {
        [[[object class] _proxyShare] removeObject:object];
        OSSpinLockUnlock(&NSKeyValueProxySpinLock);
        
        [object _proxyNonGCFinalize];
        
        OSSpinLockLock(&NSKeyValueProxySpinLock);
        
        NSKeyValueProxyNonGCPoolPointer *pointer = [[object class] _proxyNonGCPoolPointer];
        if(pointer->p1 <= 3) {
            *(pointer + pointer->p1*4 + 4) = object;
            pointer->p1 ++;
            OSSpinLockUnlock(&NSKeyValueProxySpinLock);
            return NO;
        }
        OSSpinLockUnlock(&NSKeyValueProxySpinLock);
        return YES;
    }
    OSSpinLockUnlock(&NSKeyValueProxySpinLock);
    return NO;
}


id _NSGetProxyValueWithGetterNoLock(id container, NSKeyValueProxyGetter *getter) {
    NSHashTable *proxyShare = [[getter proxyClass] _proxyShare];
    static NSKeyValueProxyShareKey *proxyShareKey = nil;
    if(!proxyShareKey) {
        proxyShareKey = [[NSKeyValueProxyShareKey alloc] init];
    }
    proxyShareKey.container = container;
    proxyShareKey.key = getter.key;
    id member = [proxyShare member:proxyShareKey];
    if(member) {
        [member retain];
    }
    else {
        member = [[[getter proxyClass] alloc] _proxyInitWithContainer:container getter:getter];
        [proxyShare addObject:member];
    }
    return [member autorelease];
}

