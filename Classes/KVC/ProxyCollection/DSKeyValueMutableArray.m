//
//  DSKeyValueMutableArray.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableArray.h"
#import "DSKeyValueGetter.h"

@implementation DSKeyValueMutableArray
- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    if(self = [super init]) {
        _container =  [container retain];
        _key = getter.key.copy;
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
    _key = nil;
    
    [_container release];
    _container = nil;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    if(_DSKeyValueProxyDeallocate(self)) {
        [super dealloc];
    }
}

- (void)setArray:(NSArray *)otherArray {
    [self removeAllObjects];
    [self addObjectsFromArray:otherArray];
}


@end
