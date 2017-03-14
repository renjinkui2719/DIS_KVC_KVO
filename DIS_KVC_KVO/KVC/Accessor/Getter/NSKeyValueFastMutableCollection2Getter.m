//
//  NSKeyValueFastMutableCollection2Getter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueFastMutableCollection2Getter.h"
#import "NSKeyValueMutatingCollectionMethodSet.h"
#import "NSKeyValueGetter.h"

@implementation NSKeyValueFastMutableCollection2Getter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass {
    if ((self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass])) {
        _baseGetter = [baseGetter retain];
        _mutatingMethods = [mutatingMethods retain];
    }
    return self;
}

- (void)dealloc {
    [_baseGetter release];
    [_mutatingMethods release];
    [super dealloc];
}

@end
