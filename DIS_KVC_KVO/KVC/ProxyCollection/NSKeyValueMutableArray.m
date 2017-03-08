//
//  NSKeyValueMutableArray.m
//  KV
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableArray.h"
#import "NSKeyValueGetter.h"

@implementation NSKeyValueMutableArray
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

- (void)setArray:(NSArray *)otherArray {
    [self removeAllObjects];
    [self addObjectsFromArray:otherArray];
}


@end
