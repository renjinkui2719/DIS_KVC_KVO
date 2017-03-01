//
//  NSKeyValueProxyGetter.m
//  KVOIMP
//
//  Created by JK on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyGetter.h"

id _NSGetProxyValueWithGetter(id object, SEL selector, NSKeyValueProxyGetter *getter) {
    return  nil;
}

@implementation NSKeyValueProxyGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key proxyClass:(Class)proxyClass {
    void *arguments[3] = {0};
    arguments[0] = self;
    if (self = [super initWithContainerClassID:containerClassID key:key implementation:(IMP)_NSGetProxyValueWithGetter selector:NULL extraArguments:arguments count:1]) {
        _proxyClass = proxyClass;
    }
    return  self;
}

@end
