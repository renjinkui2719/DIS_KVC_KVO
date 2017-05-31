//
//  DSKeyValueSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSet.h"
#import "DSKeyValueNonmutatingSetMethodSet.h"
#import "DSKeyValueGetter.h"
#import <objc/message.h>

@implementation DSKeyValueSet
- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
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
    return ((NSInteger (*)(id,Method))method_invoke)(self.container, _methods.count);
}

- (id)member:(id)object {
    return ((id (*)(id,Method,id))method_invoke)(self.container, _methods.member,object);
}

- (NSEnumerator<id> *)objectEnumerator {
    return ((NSEnumerator<id> * (*)(id,Method))method_invoke)(self.container, _methods.enumerator);
}

- (void)dealloc {
    if(_DSKeyValueProxyDeallocate(self)) {
        [super dealloc];
    }
}

@end
