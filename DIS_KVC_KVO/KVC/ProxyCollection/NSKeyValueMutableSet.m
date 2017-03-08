//
//  NSKeyValueMutableSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableSet.h"
#import "NSKeyValueGetter.h"



@implementation NSKeyValueMutableSet

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if(self = [super init]) {
        _container =  [container retain];
        _key = getter.key.copy;
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
    _key = nil;
    
    [_container release];
    _container = nil;
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    if(_NSKeyValueProxyDeallocate(self)) {
        [super dealloc];
    }
}

@end
