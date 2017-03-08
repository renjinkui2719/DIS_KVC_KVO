//
//  NSKVOSetAndNotify.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKVOSetAndNotify.h"
#import "NSKeyValueContainerClass.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import <objc/runtime.h>
#import <pthread.h>

void _NSSetCharValueAndNotify(id object,SEL selector, char value) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    pthread_mutex_lock(&info->mutex);
    NSString *key = CFDictionaryGetValue(info->selMap, selector);
    key = [key copyWithZone:nil];
    pthread_mutex_unlock(&info->mutex);
    if(info->flag) {
        [object willChangeValueForKey:key];
        IMP imp = class_getMethodImplementation(info->originalClass, selector);
        ((void (*)(id ,SEL , char ))imp)(object, selector, value);
        [object didChangeValueForKey:key];
    }
    else {
        [object _changeValueForKey:key key:nil key:nil usingBlock:^{
            IMP imp = class_getMethodImplementation(info->originalClass, selector);
            ((void (*)(id ,SEL , char ))imp)(object, selector, value);
        }];
    }
    [key release];
}
