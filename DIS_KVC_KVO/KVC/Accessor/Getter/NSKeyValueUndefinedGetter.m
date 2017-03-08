//
//  NSKeyValueUndefinedGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueUndefinedGetter.h"
#import <objc/runtime.h>

@implementation NSKeyValueUndefinedGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa {
    void *arguments[3] = {0};
    arguments[0] = key;
    return [super initWithContainerClassID:containerClassID key:key implementation:method_getImplementation(class_getInstanceMethod(containerIsa,@selector(valueForUndefinedKey:))) selector:@selector(valueForUndefinedKey:) extraArguments:arguments count:1];
}

@end
