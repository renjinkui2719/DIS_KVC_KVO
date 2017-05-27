//
//  DSKeyValueNotifyingMutableSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueNotifyingMutableSet.h"
#import "DSKeyValueProxyGetter.h"
#import "DSKeyValueProxyShareKey.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueObserverNotification.h"

@implementation DSKeyValueNotifyingMutableSet

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _mutableSet = [_DSGetProxyValueWithGetterNoLock(self.container, [getter mutableCollectionGetter]) retain];
    }
    return self;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

+ (NSHashTable *)_proxyShare {
    static NSHashTable * proxyShare = nil;
    if(!proxyShare) {
        proxyShare = [_DSKeyValueProxyShareCreate() retain];
    }
    return proxyShare;
}

- (void)_proxyNonGCFinalize {
    [_mutableSet release];
    [super _proxyNonGCFinalize];
}

- (NSUInteger)count {
    return _mutableSet.count;
}

- (id)member:(id)object {
    return [_mutableSet member:object];
}

- (NSEnumerator<id> *)objectEnumerator {
    return _mutableSet.objectEnumerator;
}

- (void)addObject:(id)object {
    NSSet *objSet = [[NSSet alloc] initWithObjects:&object count:1];
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objSet];
    
    [_mutableSet addObject:object];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objSet];
    
    [objSet release];
}

- (void)addObjectsFromArray:(NSArray *)array {
    NSSet *objSet = [[NSSet alloc] initWithArray:array];
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objSet];
    
    [_mutableSet addObjectsFromArray:array];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objSet];
    [objSet release];
}


- (void)intersectSet:(NSSet *)otherSet {
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:otherSet];
    
    [_mutableSet intersectSet:otherSet];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:otherSet];
}

- (void)minusSet:(NSSet *)otherSet {
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueMinusSetMutation usingObjects:otherSet];
    
    [_mutableSet minusSet:otherSet];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueMinusSetMutation usingObjects:otherSet];
}

- (void)removeAllObjects {
    NSSet *objSet = [NSSet set];
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:objSet];
    
    [_mutableSet removeAllObjects];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:objSet];
    
}

- (void)removeObject:(id)object {
    NSSet *objSet = [[NSSet alloc] initWithObjects:&object count:1];
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objSet];
    
    [_mutableSet removeObject:object];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objSet];
    [objSet release];

}

- (void)setSet:(NSSet *)otherSet {
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueSetSetMutation usingObjects:otherSet];
    
    [_mutableSet setSet:otherSet];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueSetSetMutation usingObjects:otherSet];
}

- (void)unionSet:(NSSet *)otherSet {
    [self.container d_willChangeValueForKey:self.key withSetMutation:NSKeyValueUnionSetMutation usingObjects:otherSet];
    
    [_mutableSet unionSet:otherSet];
    
    [self.container d_didChangeValueForKey:self.key withSetMutation:NSKeyValueUnionSetMutation usingObjects:otherSet];
}

@end
