//
//  DSKeyValueOrderedSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueOrderedSet.h"
#import "DSKeyValueNonmutatingOrderedSetMethodSet.h"
#import "DSKeyValueGetter.h"
#import <objc/message.h>

@implementation DSKeyValueOrderedSet

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    if ((self = [super init])) {
        _container = [container retain];
        _key = getter.key.copy;
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
    [_key release];
    [_container release];
    [_methods release];
    
    _key = nil;
    _container = nil;
    _methods = nil;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (NSUInteger)count {
    return ((NSUInteger (*)(id,Method))method_invoke)(self.container, _methods.count);
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    if (_methods.getObjectsRange) {
        ((void (*)(id,Method,id *,NSRange))method_invoke)(self.container, _methods.getObjectsRange, objects, range);
    }
    else {
        [super getObjects:objects range:range];
    }
}

- (NSUInteger)indexOfObject:(id)object {
    return ((NSUInteger (*)(id,Method,id))method_invoke)(self.container, _methods.indexOfObject, object);
}

- (id)objectAtIndex:(NSUInteger)idx {
    if (_methods.objectAtIndex) {
         return ((id (*)(id,Method,NSUInteger))method_invoke)(self.container, _methods.objectAtIndex, idx);
    }
    else {
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
        NSArray *objects = ((NSArray * (*)(id,Method,NSIndexSet *))method_invoke)(self.container, _methods.objectsAtIndexes, indexes);
        [indexes release];
        return [objects objectAtIndex:0];
    }
}

- (NSArray<id> *)objectsAtIndexes:(NSIndexSet *)indexes {
    if (_methods.objectsAtIndexes) {
        return ((NSArray * (*)(id,Method,NSIndexSet *))method_invoke)(self.container, _methods.objectsAtIndexes, indexes);
    }
    else {
        return [super objectsAtIndexes:indexes];
    }
}

- (void)dealloc {
    if(_DSKeyValueProxyDeallocate(self)) {
        [super dealloc];
    }
 }

@end
