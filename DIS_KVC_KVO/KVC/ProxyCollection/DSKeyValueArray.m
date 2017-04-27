//
//  DSKeyValueArray.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueArray.h"
#import "DSKeyValueGetter.h"
#import "DSKeyValueNonmutatingArrayMethodSet.h"
#import <objc/message.h>

@implementation DSKeyValueArray

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    if ((self = [super init])) {
        _container = [container retain];
        _key = [getter.key copy];
        _methods = [[getter methods] retain];
    }
    return self;
}

+ (NSHashTable *)_proxyShare {
    static NSHashTable * proxyShare = nil;
    if(!proxyShare) {
        proxyShare = [_DSKeyValueProxyShareCreate() retain];
    }
    return proxyShare;
}

- (DSKeyValueProxyLocator)_proxyLocator {
    return (DSKeyValueProxyLocator){_container,_key};
}

- (void)_proxyNonGCFinalize {
    [_methods release];
    [_key release];
    [_container release];
    
    _methods = nil;
    _key = nil;
    _container = nil;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (NSUInteger)count {
    return ((NSUInteger (*)(id,Method))method_invoke)(_container, _methods.count);
}

- (id)objectAtIndex:(NSUInteger)index {
    if (_methods.objectAtIndex) {
        return ((id (*)(id,Method,NSUInteger))method_invoke)(_container, _methods.objectAtIndex, index);
    }
    else {
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:index];
        NSArray *objects = ((NSArray* (*)(id,Method,NSIndexSet *))method_invoke)(_container, _methods.objectsAtIndexes, indexes);
        [indexes release];
        return [objects objectAtIndex:0];
    }
}

- (NSArray<id> *)objectsAtIndexes:(NSIndexSet *)indexes {
    if (_methods.objectsAtIndexes) {
        return ((NSArray * (*)(id,Method,NSIndexSet *))method_invoke)(_container, _methods.objectsAtIndexes, indexes);
    }
    else {
        return [super objectsAtIndexes:indexes];
    }
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    if (_methods.getObjectsRange) {
        ((void (*)(id,Method,id *, NSRange))method_invoke)(_container, _methods.getObjectsRange, objects, range);
    }
    else {
        [super getObjects:objects range:range];
    }
}

- (void)dealloc {
    if (_DSKeyValueProxyDeallocate(self)) {
        [super dealloc];
    }
}

@end
