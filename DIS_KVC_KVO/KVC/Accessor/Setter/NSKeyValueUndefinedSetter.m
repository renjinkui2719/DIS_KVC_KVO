//
//  NSKeyValueUndefinedSetter.m
//  KV
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueUndefinedSetter.h"

@implementation NSKeyValueUndefinedSetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa {
    if(_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(containerIsa, key)) {
        void *arguments[3] = {0};
        arguments[0] = key;
        arguments[1] = method_getImplementation(class_getInstanceMethod(containerIsa, @selector(setValue:forUndefinedKey:)));
        return [super initWithContainerClassID:containerClassID key:key implementation:_NSSetValueAndNotifyForUndefinedKey selector:@selector(setValue:forUndefinedKey:) extraArguments:arguments count:2];
    }
    else {
        void *arguments[3] = {0};
        arguments[0] = key;
        return [super initWithContainerClassID:containerClassID key:key implementation:method_getImplementation(class_getInstanceMethod(containerIsa, @selector(setValue:forUndefinedKey:))) selector:@selector(setValue:forUndefinedKey:) extraArguments:arguments count:1];
    }
}

@end
