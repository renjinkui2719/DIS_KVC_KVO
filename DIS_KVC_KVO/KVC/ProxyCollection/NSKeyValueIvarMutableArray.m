//
//  NSKeyValueIvarMutableArray.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueIvarMutableArray.h"
#import "NSKeyValueGetter.h"

@implementation NSKeyValueIvarMutableArray

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if ((self = [super _proxyInitWithContainer:container getter:getter])) {
        _ivar = [getter ivar];
    }
    return self;
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (id)_nonNilMutableArrayValueWithSelector:(SEL)selector {
    object_getIvar(<#id obj#>, <#Ivar ivar#>)
}

@end
