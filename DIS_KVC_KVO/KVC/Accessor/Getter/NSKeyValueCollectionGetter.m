//
//  NSKeyValueCollectionGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueCollectionGetter.h"
#import "NSKeyValueNonmutatingCollectionMethodSet.h"

@implementation NSKeyValueCollectionGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key methods:(NSKeyValueNonmutatingCollectionMethodSet *)methods proxyClass:(Class)proxyClass {
    if (self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass]) {
        _methods = [methods retain];
    }
    return  self;
}

- (void)dealloc {
    [_methods release];
    [super dealloc];
}

@end
