//
//  NSKeyValueFastMutableCollection1Getter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueFastMutableCollection1Getter.h"
#import "NSKeyValueNonmutatingCollectionMethodSet.h"
#import "NSKeyValueMutatingCollectionMethodSet.h"

@implementation NSKeyValueFastMutableCollection1Getter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key nonmutatingMethods:(NSKeyValueNonmutatingCollectionMethodSet *)nonmutatingMethods mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass {
    if ((self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass])) {
        _nonmutatingMethods = [nonmutatingMethods retain];
        _mutatingMethods = [mutatingMethods retain];
    }
    return self;
}

- (void)dealloc {
    [_mutatingMethods release];
    [_nonmutatingMethods release];
    [super dealloc];
}

@end
