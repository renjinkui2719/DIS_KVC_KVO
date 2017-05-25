//
//  DSSetValueForKeyInIvar.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSSetValueForKeyInIvar.h"
#import "DSKeyValueCodingCommon.h"

void _DSSetCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(char *)object_getIvarAddress(object, ivar) = [value charValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetDoubleValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(double *)object_getIvarAddress(object, ivar) = [value doubleValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetFloatValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(float *)object_getIvarAddress(object, ivar) = [value floatValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(int *)object_getIvarAddress(object, ivar) = [value intValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(long *)object_getIvarAddress(object, ivar) = [value longValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(long long *)object_getIvarAddress(object, ivar) = [value longLongValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(short *)object_getIvarAddress(object, ivar) = [value shortValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetUnsignedLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(unsigned long long *)object_getIvarAddress(object, ivar) = [value unsignedLongLongValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetUnsignedLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(unsigned long *)object_getIvarAddress(object, ivar) = [value unsignedLongValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetBoolValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(BOOL *)object_getIvarAddress(object, ivar) = [value boolValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetUnsignedCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(unsigned char *)object_getIvarAddress(object, ivar) = [value unsignedCharValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetUnsignedIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(unsigned int *)object_getIvarAddress(object, ivar) = [value unsignedIntValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetUnsignedShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(unsigned short *)object_getIvarAddress(object, ivar) = [value unsignedShortValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetPointValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
#if TARGET_OS_IPHONE
        *(CGPoint *)object_getIvarAddress(object, ivar) = [value CGPointValue];
#else
        *(NSPoint *)object_getIvarAddress(object, ivar) = [value pointValue];
#endif
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetRangeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
        *(NSRange *)object_getIvarAddress(object, ivar) = [value rangeValue];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetRectValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
#if TARGET_OS_IPHONE
        *(CGRect *)object_getIvarAddress(object, ivar) = [value CGRectValue];
#else
        *(NSRect *)object_getIvarAddress(object, ivar) = [value rectValue];
#endif
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetSizeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (value) {
#if TARGET_OS_IPHONE
        *(CGSize *)object_getIvarAddress(object, ivar) = [value CGSizeValue];
#else
        *(NSSize *)object_getIvarAddress(object, ivar) = [value sizeValue];
#endif
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetValueInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (key) {
        [value getValue:object_getIvarAddress(object, ivar)];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _DSSetObjectSetIvarValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    object_setIvar(object, ivar, value);
}

void _DSSetObjectSetManualValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    objc_autorelease(*(id *)object_getIvarAddress(object, ivar));
    objc_retain(value);
    *(id *)object_getIvarAddress(object, ivar) = value;
}

void _DSSetObjectSetStrongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    objc_storeStrong((id *)object_getIvarAddress(object, ivar), value);
}

void _DSSetObjectSetWeakValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    objc_storeWeak((id *)object_getIvarAddress(object, ivar), value);
}

void _DSSetObjectSetAssignValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    *(id *)object_getIvarAddress(object, ivar) = value;
}
