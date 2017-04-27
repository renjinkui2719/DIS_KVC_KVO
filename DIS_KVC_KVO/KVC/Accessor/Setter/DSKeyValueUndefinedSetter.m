//
//  DSKeyValueUndefinedSetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueUndefinedSetter.h"
#import "DSKeyValueContainerClass.h"

void _DSSetValueAndNotifyForUndefinedKey(id object, SEL selctor, id value, NSString *key, IMP imp) {
    [object willChangeValueForKey:key];
    
    ((void (*)(id,SEL,id,NSString *))imp)(object, selctor, value, key);
    
    [object didChangeValueForKey:key];
}

@implementation DSKeyValueUndefinedSetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa {
    if(_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(containerIsa, key)) {
        void *arguments[3] = {0};
        arguments[0] = key;
        arguments[1] = method_getImplementation(class_getInstanceMethod(containerIsa, @selector(setValue:forUndefinedKey:)));
        return [super initWithContainerClassID:containerClassID key:key implementation:(IMP)_DSSetValueAndNotifyForUndefinedKey selector:@selector(setValue:forUndefinedKey:) extraArguments:arguments count:2];
    }
    else {
        void *arguments[3] = {0};
        arguments[0] = key;
        return [super initWithContainerClassID:containerClassID key:key implementation:method_getImplementation(class_getInstanceMethod(containerIsa, @selector(setValue:forUndefinedKey:))) selector:@selector(setValue:forUndefinedKey:) extraArguments:arguments count:1];
    }
}

@end
