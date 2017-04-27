//
//  DSKeyValueIvarMutableCollectionGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueIvarMutableCollectionGetter.h"

@implementation DSKeyValueIvarMutableCollectionGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa ivar:(struct objc_ivar *)ivar proxyClass:(Class)proxyClass {
    if ((self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass])) {
        _ivar = ivar;
    }
    return  self;
}

@end
