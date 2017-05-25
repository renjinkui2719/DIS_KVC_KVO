//
//  DSKeyValueSlowSetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/9.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSlowSetter.h"
#import "NSObject+DSKeyValueCoding.h"

@implementation DSKeyValueSlowSetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa {
    Method setValueForKeyMethod = class_getInstanceMethod(containerIsa, @selector(d_setValue:forKey:));
    void *arguments[3] = {NULL};
    arguments[0] = key;
    self = [super initWithContainerClassID:containerClassID key:key implementation:method_getImplementation(setValueForKeyMethod) selector:@selector(d_valueForKey:) extraArguments:arguments count:1];
    return self;
}

@end
