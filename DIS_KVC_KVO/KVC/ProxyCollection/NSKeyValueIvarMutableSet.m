//
//  NSKeyValueIvarMutableSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueIvarMutableSet.h"
#import "NSKeyValueNilSetEnumerator.h"
#import <objc/runtime.h>

@implementation NSKeyValueIvarMutableSet

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _ivar = [getter ivar];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    _ivar = NULL;
    [super _proxyNonGCFinalize];
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool = {0};
    return  &proxyPool;
}

- (NSUInteger)count {
    return [(id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) count];
}

- (id)member:(id)object {
    return [(id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) member:object];
}

- (NSEnumerator *)objectEnumerator {
    id objOfIvar = (id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar));
    if(objOfIvar) {
        return [objOfIvar objectEnumerator];
    }
    else {
        return [[[NSKeyValueNilSetEnumerator alloc] init] autorelease];
    }
}

- (void)addObject:(id)object {
    id objOfIvar = (id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar));
    if(objOfIvar) {
        [objOfIvar addObject:object];
    }
    else {
        *(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) = [[NSMutableSet alloc] initWithObjects:&object count:1];
    }
}

- (void)addObjectsFromArray:(NSArray *)array {
    id objOfIvar = (id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar));
    if(objOfIvar) {
        [objOfIvar addObjectsFromArray:array];
    }
    else {
        *(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) = [[NSMutableSet alloc] initWithArray:array];
    }
}

- (void)intersectSet:(NSSet *)otherSet {
    [(id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) intersectSet:otherSet];
}

- (void)minusSet:(NSSet *)otherSet {
    [(id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) minusSet:otherSet];
}

- (void)removeAllObjects {
    [(id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) removeAllObjects];
}

- (void)removeObject:(id)object {
    [(id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) removeObject: object];
}

- (void)setSet:(NSSet *)otherSet {
    id objOfIvar = (id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar));
    if(objOfIvar) {
        [objOfIvar setSet:otherSet];
    }
    else {
        *(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) = [otherSet mutableCopy];
    }
}

- (void)unionSet:(NSSet *)otherSet {
    id objOfIvar = (id)(id *)((uint8 *)self.container + ivar_getOffset(_ivar));
    if(objOfIvar) {
        [objOfIvar unionSet:otherSet];
    }
    else {
        *(id *)((uint8 *)self.container + ivar_getOffset(_ivar)) = [otherSet mutableCopy];
    }
}

@end
