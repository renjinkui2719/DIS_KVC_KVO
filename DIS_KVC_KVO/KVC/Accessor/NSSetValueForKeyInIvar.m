//
//  NSSetValueForKeyInIvar.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSSetValueForKeyInIvar.h"
#import "NSKeyValueCodingCommon.h"

void _NSSetCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(char *)object_getIvarAddress(object, ivar) = [value charValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetDoubleValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(double *)object_getIvarAddress(object, ivar) = [value doubleValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetFloatValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(float *)object_getIvarAddress(object, ivar) = [value floatValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(int *)object_getIvarAddress(object, ivar) = [value intValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(long *)object_getIvarAddress(object, ivar) = [value longValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(long long *)object_getIvarAddress(object, ivar) = [value longLongValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(short *)object_getIvarAddress(object, ivar) = [value shortValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetUnsignedLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(unsigned long long *)object_getIvarAddress(object, ivar) = [value unsignedLongLongValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetUnsignedLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(unsigned long *)object_getIvarAddress(object, ivar) = [value unsignedLongValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetBoolValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(BOOL *)object_getIvarAddress(object, ivar) = [value boolValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetUnsignedCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(unsigned char *)object_getIvarAddress(object, ivar) = [value unsignedCharValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetUnsignedIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(unsigned int *)object_getIvarAddress(object, ivar) = [value unsignedIntValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetUnsignedShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(unsigned short *)object_getIvarAddress(object, ivar) = [value unsignedShortValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetPointValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(NSPoint *)object_getIvarAddress(object, ivar) = [value pointValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetRangeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(NSRange *)object_getIvarAddress(object, ivar) = [value rangeValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetRectValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(char *)object_getIvarAddress(object, ivar) = [value charValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetSizeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value)
        *(NSSize *)object_getIvarAddress(object, ivar) = [value sizeValue];
    else
        [object setNilValueForKey:key];
}

void _NSSetValueInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (key) {
        [value getValue:object_getIvarAddress(object, ivar)];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _NSSetObjectSetIvarValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    object_setIvar(object, ivar, value);
}

void _NSSetObjectSetManualValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    objc_autorelease(*(id *)object_getIvarAddress(object, ivar));
    objc_retain(value);
    *(id *)object_getIvarAddress(object, ivar) = value;
}

void _NSSetObjectSetStrongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    objc_storeStrong((id *)object_getIvarAddress(object, ivar), value);
}

void _NSSetObjectSetWeakValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    objc_storeWeak((id *)object_getIvarAddress(object, ivar), value);
}

void _NSSetObjectSetAssignValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    *(id *)object_getIvarAddress(object, ivar) = value;
}
