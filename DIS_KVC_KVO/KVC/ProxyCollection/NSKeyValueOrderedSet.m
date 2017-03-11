//
//  NSKeyValueOrderedSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueOrderedSet.h"
#import "NSKeyValueNonmutatingOrderedSetMethodSet.h"
#import "NSKeyValueGetter.h"
#import <objc/message.h>

@implementation NSKeyValueOrderedSet

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
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
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    }
    return proxyShare;
}

- (NSKeyValueProxyLocator)_proxyLocator {
    return (NSKeyValueProxyLocator){_container,_key};
}

- (void)_proxyNonGCFinalize {
    [_key release];
    [_container release];
    [_methods release];
    
    _key = nil;
    _container = nil;
    _methods = nil;
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (NSUInteger)count {
    return ((NSUInteger (*)(id,Method,...))method_invoke)(self.container, _methods.count);
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    if (_methods.getObjectsRange) {
        ((void (*)(id,Method,...))method_invoke)(self.container, _methods.getObjectsRange, objects, range);
    }
    else {
        [super getObjects:objects range:range];
    }
}

- (NSUInteger)indexOfObject:(id)object {
    return ((NSUInteger (*)(id,Method,...))method_invoke)(self.container, _methods.indexOfObject, object);
}

- (id)objectAtIndex:(NSUInteger)idx {
    if (_methods.objectAtIndex) {
         return ((id (*)(id,Method,...))method_invoke)(self.container, _methods.objectAtIndex, idx);
    }
    else {
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
        NSArray *objects = ((NSArray * (*)(id,Method,...))method_invoke)(self.container, _methods.objectsAtIndexes, indexes);
        [indexes release];
        return [objects objectAtIndex:0];
    }
}

- (NSArray<id> *)objectsAtIndexes:(NSIndexSet *)indexes {
    if (_methods.objectsAtIndexes) {
        return ((NSArray * (*)(id,Method,...))method_invoke)(self.container, _methods.objectsAtIndexes, indexes);
    }
    else {
        return [super objectsAtIndexes:indexes];
    }
}

- (void)dealloc {
    if(_NSKeyValueProxyDeallocate(self)) {
        [super dealloc];
    }
 }

@end
