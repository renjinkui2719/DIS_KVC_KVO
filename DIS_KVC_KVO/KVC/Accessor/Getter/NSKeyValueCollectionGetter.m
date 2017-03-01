//
//  NSKeyValueCollectionGetter.m
//  KVOIMP
//
//  Created by JK on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueCollectionGetter.h"

@implementation NSKeyValueCollectionGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key methods:(NSKeyValueNonmutatingCollectionMethodSet *)methods proxyClass:(Class)proxyClass {
    if (self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass]) {
        _methods = methods;
    }
    return  self;
}



@end
