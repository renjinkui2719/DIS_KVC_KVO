//
//  NSKeyValueNotifyingMutableCollectionGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueNotifyingMutableCollectionGetter.h"
#import "NSKeyValueProxyGetter.h"

@implementation NSKeyValueNotifyingMutableCollectionGetter

- (id)initWithContainerClassID:(id)containerClassID key:(id)key mutableCollectionGetter:(id)mutableCollectionGetter proxyClass:(Class)proxyClass {
    if ((self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass])) {
        _mutableCollectionGetter = [mutableCollectionGetter retain];
    }
    return self;
}

- (void)dealloc {
    [_mutableCollectionGetter release];
    [super dealloc];
}

@end
