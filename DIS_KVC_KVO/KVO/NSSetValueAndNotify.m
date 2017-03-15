//
//  NSKVOSetAndNotify.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSSetValueAndNotify.h"
#import "NSKeyValueContainerClass.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <pthread.h>

#define __NSSetValueAndNotify(object, selector, value) do {\
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));\
\
    pthread_mutex_lock(&info->mutex);\
\
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);\
    key = [key copyWithZone:nil];\
\
    pthread_mutex_unlock(&info->mutex);\
\
    if(info->flag) {\
        [object willChangeValueForKey:key];\
        \
        IMP imp = class_getMethodImplementation(info->originalClass, selector);\
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);\
        \
        [object didChangeValueForKey:key];\
    }\
    else {\
        [object _changeValueForKey:key key:nil key:nil usingBlock:^{\
            IMP imp = class_getMethodImplementation(info->originalClass, selector);\
            ((void (*)(id ,SEL , ... ))imp)(object, selector, value);\
        }];\
    }\
\
    [key release];\
}while(0)

void _NSSetCharValueAndNotify(id object,SEL selector, char value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetDoubleValueAndNotify(id object,SEL selector, double value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetFloatValueAndNotify(id object,SEL selector, float value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetIntValueAndNotify(id object,SEL selector, int value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetLongValueAndNotify(id object,SEL selector, long value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetLongLongValueAndNotify(id object,SEL selector, long long value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetShortValueAndNotify(id object,SEL selector, short value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetUnsignedShortValueAndNotify(id object,SEL selector, unsigned short value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetPointValueAndNotify(id object,SEL selector, NSPoint value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetRangeValueAndNotify(id object,SEL selector, NSRange value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetRectValueAndNotify(id object,SEL selector, NSRect value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetSizeValueAndNotify(id object,SEL selector, NSSize value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetBoolValueAndNotify(id object,SEL selector, BOOL value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetUnsignedCharValueAndNotify(id object,SEL selector, unsigned char value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetUnsignedIntValueAndNotify(id object,SEL selector, unsigned int value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetUnsignedLongValueAndNotify(id object,SEL selector, unsigned long value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetUnsignedLongLongValueAndNotify(id object,SEL selector, unsigned long long value) {
    __NSSetValueAndNotify(object, selector, value);
}

void _NSSetObjectValueAndNotify(id object,SEL selector, id value) {
    __NSSetValueAndNotify(object, selector, value);
}

void NSKVOInsertObjectAtIndexAndNotify(id object,SEL selector, id value, NSUInteger idx) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    
    [object willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    Method insertMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, insertMethod, value, idx);
    
    [object didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    [indexes release];
    [key release];
}

void NSKVOInsertObjectsAtIndexesAndNotify(id object,SEL selector, id values, NSIndexSet *indexes) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    IMP imp = class_getMethodImplementation(info->originalClass, selector);
    ((void (*)(id,SEL,...))imp)(object, selector, values, indexes);
    
    [object didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    [key release];
}

void NSKVORemoveObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    
    [object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    Method removeMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, removeMethod, idx);
    
    [object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    [indexes release];
    [key release];
}

void NSKVORemoveObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    IMP imp = class_getMethodImplementation(info->originalClass, selector);
    ((void (*)(id,SEL,...))imp)(object, selector, indexes);
    
    [object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    [key release];
}

void NSKVOReplaceObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx, id value) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [object willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    Method replaceMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, replaceMethod, idx, value);
    
    [object didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    [indexes release];
    [key release];
}

void NSKVOReplaceObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes, id values) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    Method replaceMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, replaceMethod, indexes, values);
    
    [object didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    [key release];
}

void NSKVOAddObjectAndNotify(id object, SEL selector, id value) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSSet *values = [[NSSet alloc] initWithObjects:&value count:1];
    [object willChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    
    Method addMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, addMethod, value);
    
    [object didChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    
    [values release];
    [key release];
}

void NSKVORemoveObjectAndNotify(id object, SEL selector, id value) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSSet *values = [[NSSet alloc] initWithObjects:&value count:1];
    [object willChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    
    Method removeMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, removeMethod, value);
    
    [object didChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    
    [values release];
    [key release];
}


void NSKVOIntersectSetAndNotify(id object, SEL selector, id values) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object willChangeValueForKey:key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:values];
    
    Method intersectMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, intersectMethod, values);
    
    [object didChangeValueForKey:key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:values];
    
    [key release];
}

void NSKVOMinusSetAndNotify(id object, SEL selector, id values) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object willChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    
    Method minusMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, minusMethod, values);
    
    [object didChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    
    [key release];
}

void NSKVOUnionSetAndNotify(id object, SEL selector, id values) {
    NSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object willChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    
    Method unionMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, unionMethod, values);
    
    [object didChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    
    [key release];
}
