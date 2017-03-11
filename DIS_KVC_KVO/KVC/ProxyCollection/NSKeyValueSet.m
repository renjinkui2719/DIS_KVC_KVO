//
//  NSKeyValueSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueSet.h"
#import "NSKeyValueNonmutatingSetMethodSet.h"
#import "NSKeyValueGetter.h"
#import <objc/message.h>

@implementation NSKeyValueSet
- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if(self = [super init]) {
        _container =  [container retain];
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
    return ((NSInteger (*)(id,Method,...))method_invoke)(self.container, _methods.count);
}

- (id)member:(id)object {
    return ((id (*)(id,Method,...))method_invoke)(self.container, _methods.member,object);
}

- (NSEnumerator<id> *)objectEnumerator {
    return ((NSEnumerator<id> * (*)(id,Method,...))method_invoke)(self.container, _methods.enumerator);
}

- (void)dealloc {
    if(_NSKeyValueProxyDeallocate(self)) {
        [super dealloc];
    }
}

@end
