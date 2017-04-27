//
//  DSKeyValueFastMutableCollection1Getter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueFastMutableCollection1Getter.h"
#import "DSKeyValueNonmutatingCollectionMethodSet.h"
#import "DSKeyValueMutatingCollectionMethodSet.h"

@implementation DSKeyValueFastMutableCollection1Getter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key nonmutatingMethods:(DSKeyValueNonmutatingCollectionMethodSet *)nonmutatingMethods mutatingMethods:(DSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass {
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
