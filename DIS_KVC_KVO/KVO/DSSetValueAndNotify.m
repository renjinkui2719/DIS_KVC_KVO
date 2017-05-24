//
//  DSKVOSetAndNotify.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSSetValueAndNotify.h"
#import "DSKeyValueContainerClass.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueObserverNotification.h"
#import "DSKeyValueObserverCommon.h"

static inline void __DSSetPrimitiveValueAndNotify(id object,SEL selector, void (^setWithImpBlock)(IMP imp)) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    if(info->overrideWillOrDidChange) {
        [object d_willChangeValueForKey:key];
        
        IMP imp = class_getMethodImplementation(info->originalClass, selector);
        setWithImpBlock(imp);
        
        [object d_didChangeValueForKey:key];
    }
    else {
        [object _d_changeValueForKey:key key:nil key:nil usingBlock:^{
            IMP imp = class_getMethodImplementation(info->originalClass, selector);
            setWithImpBlock(imp);
        }];
    }
    
    [key release];
}


void _DSSetCharValueAndNotify(id object,SEL selector, char value) {
    LOG_KVO(@"set Char value and notify with %c, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));

    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
}

void _DSSetDoubleValueAndNotify(id object,SEL selector, double value) {
    LOG_KVO(@"set Double value and notify with %f, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));

    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
}

void _DSSetFloatValueAndNotify(id object,SEL selector, float value) {
    LOG_KVO(@"set Float value and notify with %f, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));

    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
}

void _DSSetIntValueAndNotify(id object,SEL selector, int value) {
    LOG_KVO(@"set Int value and notify with %d, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));

    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
}

void _DSSetLongValueAndNotify(id object,SEL selector, long value) {
    LOG_KVO(@"set Long value and notify with %ld, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));

    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
}

void _DSSetLongLongValueAndNotify(id object,SEL selector, long long value) {
    LOG_KVO(@"set LongLong value and notify with %lld, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
}

void _DSSetShortValueAndNotify(id object,SEL selector, short value) {
    LOG_KVO(@"set Short value and notify with %d, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetUnsignedShortValueAndNotify(id object,SEL selector, unsigned short value) {
    LOG_KVO(@"set UnsignedShort value and notify with %u, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetPointValueAndNotify(id object,SEL selector, NSPoint value) {
    LOG_KVO(@"set Point value and notify with %@, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetRangeValueAndNotify(id object,SEL selector, NSRange value) {
    LOG_KVO(@"set Range value and notify with %@, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetRectValueAndNotify(id object,SEL selector, NSRect value) {
    LOG_KVO(@"set Rect value and notify with %@, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetSizeValueAndNotify(id object,SEL selector, NSSize value) {
    LOG_KVO(@"set Size value and notify with %@, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetBoolValueAndNotify(id object,SEL selector, BOOL value) {
    LOG_KVO(@"set Bool value and notify with %s, of object: %@, selector: %s", value ? "YES" : "NO", simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetUnsignedCharValueAndNotify(id object,SEL selector, unsigned char value) {
    LOG_KVO(@"set UnsignedChar value and notify with %u, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetUnsignedIntValueAndNotify(id object,SEL selector, unsigned int value) {
    LOG_KVO(@"set UnsignedInt value and notify with %u, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetUnsignedLongValueAndNotify(id object,SEL selector, unsigned long value) {
    LOG_KVO(@"set UnsignedLong value and notify with %lu, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetUnsignedLongLongValueAndNotify(id object,SEL selector, unsigned long long value) {
    LOG_KVO(@"set UnsignedLongLong value and notify with %llu, of object: %@, selector: %s", value, simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void _DSSetObjectValueAndNotify(id object,SEL selector, id value) {
    LOG_KVO(@"set Object value and notify with %@, of object: %@, selector: %s", simple_desc(value), simple_desc(object),sel_getName(selector));
#if !SetPrimitiveValue_NiceBreakPoint
    __DSSetPrimitiveValueAndNotify(object, selector, value);
#else
    __DSSetPrimitiveValueAndNotify(object, selector, ^(IMP imp) {
        ((void (*)(id ,SEL , ... ))imp)(object, selector, value);
    });
#endif
}

void DSKVOInsertObjectAtIndexAndNotify(id object,SEL selector, id value, NSUInteger idx) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    
    [object d_willChange:DSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    Method insertMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, insertMethod, value, idx);
    
    [object d_didChange:DSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    [indexes release];
    [key release];
}

void DSKVOInsertObjectsAtIndexesAndNotify(id object,SEL selector, id values, NSIndexSet *indexes) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object d_willChange:DSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    IMP imp = class_getMethodImplementation(info->originalClass, selector);
    ((void (*)(id,SEL,...))imp)(object, selector, values, indexes);
    
    [object d_didChange:DSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
    
    [key release];
}

void DSKVORemoveObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    
    [object d_willChange:DSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    Method removeMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, removeMethod, idx);
    
    [object d_didChange:DSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    [indexes release];
    [key release];
}

void DSKVORemoveObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object d_willChange:DSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    IMP imp = class_getMethodImplementation(info->originalClass, selector);
    ((void (*)(id,SEL,...))imp)(object, selector, indexes);
    
    [object d_didChange:DSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
    
    [key release];
}

void DSKVOReplaceObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx, id value) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [object d_willChange:DSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    Method replaceMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, replaceMethod, idx, value);
    
    [object d_didChange:DSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    [indexes release];
    [key release];
}

void DSKVOReplaceObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes, id values) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object d_willChange:DSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    Method replaceMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, replaceMethod, indexes, values);
    
    [object d_didChange:DSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
    
    [key release];
}

void DSKVOAddObjectAndNotify(id object, SEL selector, id value) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSSet *values = [[NSSet alloc] initWithObjects:&value count:1];
    [object d_willChangeValueForKey:key withSetMutation:DSKeyValueUnionSetMutation usingObjects:values];
    
    Method addMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, addMethod, value);
    
    [object d_didChangeValueForKey:key withSetMutation:DSKeyValueUnionSetMutation usingObjects:values];
    
    [values release];
    [key release];
}

void DSKVORemoveObjectAndNotify(id object, SEL selector, id value) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    NSSet *values = [[NSSet alloc] initWithObjects:&value count:1];
    [object d_willChangeValueForKey:key withSetMutation:DSKeyValueMinusSetMutation usingObjects:values];
    
    Method removeMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, removeMethod, value);
    
    [object d_didChangeValueForKey:key withSetMutation:DSKeyValueMinusSetMutation usingObjects:values];
    
    [values release];
    [key release];
}


void DSKVOIntersectSetAndNotify(id object, SEL selector, id values) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object d_willChangeValueForKey:key withSetMutation:DSKeyValueIntersectSetMutation usingObjects:values];
    
    Method intersectMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, intersectMethod, values);
    
    [object d_didChangeValueForKey:key withSetMutation:DSKeyValueIntersectSetMutation usingObjects:values];
    
    [key release];
}

void DSKVOMinusSetAndNotify(id object, SEL selector, id values) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object d_willChangeValueForKey:key withSetMutation:DSKeyValueMinusSetMutation usingObjects:values];
    
    Method minusMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, minusMethod, values);
    
    [object d_didChangeValueForKey:key withSetMutation:DSKeyValueMinusSetMutation usingObjects:values];
    
    [key release];
}

void DSKVOUnionSetAndNotify(id object, SEL selector, id values) {
    DSKeyValueNotifyingInfo *info = object_getIndexedIvars(object_getClass(object));
    
    pthread_mutex_lock(&info->mutex);
    
    NSString *key = CFDictionaryGetValue(info->selKeyMap, selector);
    key = [key copyWithZone:nil];
    
    pthread_mutex_unlock(&info->mutex);
    
    [object d_willChangeValueForKey:key withSetMutation:DSKeyValueUnionSetMutation usingObjects:values];
    
    Method unionMethod = class_getInstanceMethod(info->originalClass, selector);
    ((void (*)(id,Method,...))method_invoke)(object, unionMethod, values);
    
    [object d_didChangeValueForKey:key withSetMutation:DSKeyValueUnionSetMutation usingObjects:values];
    
    [key release];
}
