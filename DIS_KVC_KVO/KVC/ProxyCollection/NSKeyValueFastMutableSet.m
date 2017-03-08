//
//  NSKeyValueFastMutableSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueFastMutableSet.h"
#import "NSKeyValueMutatingSetMethodSet.h"
#import "NSKeyValueNonmutatingSetMethodSet.h"
#import "NSObject+NSKeyValueCodingPrivate.h"
#import <objc/message.h>

@implementation NSKeyValueFastMutableSet

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _mutatingMethods = [[getter mutatingMethods] retain];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    [_mutatingMethods release];
    [super _proxyNonGCFinalize];
}

- (void)setSet:(NSSet *)otherSet {
    if(_mutatingMethods.setSet) {
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.setSet, otherSet);
    }
    else {
        [super setSet:otherSet];
    }
}

- (void)addObject:(id)object {
    if(_mutatingMethods.addObject) {
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.addObject, object);
    }
    else {
        NSSet* objSet = [[NSSet alloc] initWithObjects:&object count:1];
        ((void (*)(id,Method,id))method_invoke)(self.container, _mutatingMethods.unionSet, objSet);
        [objSet release];
    }
}


- (void)addObjectsFromArray:(NSArray *)array {
    if(_mutatingMethods.unionSet) {
        NSSet* objSet = [[NSSet alloc] initWithArray:array];
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.unionSet, objSet);
        [objSet release];
    }
    else {
        [super addObjectsFromArray:array];
    }
}

- (void)intersectSet:(NSSet *)otherSet {
    if(_mutatingMethods.intersectSet) {
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.intersectSet, otherSet);
    }
    else {
        [super intersectSet:otherSet];
    }
}

- (void)minusSet:(NSSet *)otherSet {
    if(_mutatingMethods.minusSet) {
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.minusSet, otherSet);
    }
    else {
        [super minusSet:otherSet];
    }
}

- (void)removeAllObjects {
    if(_mutatingMethods.setSet) {
        NSSet* objSet = [[NSSet alloc] init];
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.setSet, objSet);
        [objSet release];
    }
    else {
        [super removeAllObjects];
    }
}

- (void)removeObject:(id)object {
    if(_mutatingMethods.removeObject) {
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.removeObject, object);
    }
    else {
        NSSet* objSet = [[NSSet alloc] initWithObjects:&object count:1];
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.minusSet, objSet);
        [objSet release];
    }
}

- (void)unionSet:(NSSet *)otherSet {
    if(_mutatingMethods.unionSet) {
        ((void (*)(id,Method,id))method_invoke)(self.container,_mutatingMethods.unionSet, otherSet);
    }
    else {
        [super unionSet:otherSet];
    }
}

@end



@implementation NSKeyValueFastMutableSet1

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _nonmutatingMethods = [[getter nonmutatingMethods] retain];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    [_nonmutatingMethods release];
    [super _proxyNonGCFinalize];
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool = {0};
    return  &proxyPool;
}

- (NSUInteger)count {
    return ((NSUInteger (*)(id,Method))method_invoke)(self.container,_nonmutatingMethods.count);
}

- (id)member:(id)object {
    return ((id (*)(id,Method, id))method_invoke)(self.container,_nonmutatingMethods.member, object);
}

- (NSEnumerator *)objectEnumerator {
    return ((id (*)(id,Method))method_invoke)(self.container,_nonmutatingMethods.enumerator);
}

@end

@implementation NSKeyValueFastMutableSet2

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _valueGetter = [[getter baseGetter] retain];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    [_valueGetter release];
    [super _proxyNonGCFinalize];
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool = {0};
    return  &proxyPool;
}

- (NSSet *)_nonNilSetValueWithSelector:(SEL)selector {
    id setValue = _NSGetUsingKeyValueGetter(self.container, _valueGetter);
    if(!setValue) {
        [NSException raise:NSInternalInconsistencyException format:@"%@: value for key %@ of object %p is nil", _NSMethodExceptionProem(self,selector), self.key, self.container];
    }
    return setValue;
}

- (NSUInteger)count {
    return [self _nonNilSetValueWithSelector:_cmd].count;
}

- (id)member:(id)object {
    return [[self _nonNilSetValueWithSelector:_cmd] member:object];
}


- (NSEnumerator *)objectEnumerator {
    return [self _nonNilSetValueWithSelector:_cmd].objectEnumerator;
}


@end
