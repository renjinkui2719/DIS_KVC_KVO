//
//  NSSetValueForKeyInIvar.m
//  KVOIMP
//
//  Created by JK on 2017/1/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSSetValueForKeyInIvar.h"

#define AddressAtObjectOffset(object, offset) (((unsigned char *)((__bridge void *)object)) + offset)

#define __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, valueType, valueGetSelectorName) do {\
    if (value) {\
        ptrdiff_t offset =  ivar_getOffset(ivar);\
        *((valueType *)AddressAtObjectOffset(object, offset)) = [value valueGetSelectorName];\
    }\
    else {\
        [object setNilValueForKey:key];\
    }\
}while(0)

void _NSSetCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, char, charValue);
}

void _NSSetDoubleValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, double, doubleValue);
}

void _NSSetFloatValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, float, floatValue);
}

void _NSSetIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, int, intValue);
}

void _NSSetLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, long, longValue);
}

void _NSSetLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, long long, longLongValue);
}

void _NSSetShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, short, shortValue);
}

void _NSSetUnsignedLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, unsigned long long, unsignedLongLongValue);
}

void _NSSetUnsignedLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, unsigned long, unsignedLongValue);
}

void _NSSetBoolValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, BOOL, boolValue);
}

void _NSSetUnsignedCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, unsigned char, unsignedCharValue);
}

void _NSSetUnsignedIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, unsigned int, unsignedIntValue);
}

void _NSSetUnsignedShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, unsigned short, unsignedShortValue);
}

void _NSSetPointValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, NSPoint, pointValue);
}

void _NSSetRangeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, NSRange, rangeValue);
}

void _NSSetRectValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, NSRect, rectValue);
}

void _NSSetSizeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    __NSSetIntValueForKeyInIvar(object, selector, value, key, ivar, NSSize, sizeValue);
}

void _NSSetValueInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    if (key) {
        ptrdiff_t offset =  ivar_getOffset(ivar);
        [value getValue:AddressAtObjectOffset(object, offset)];
    }
    else {
        [object setNilValueForKey:key];
    }
}

void _NSSetObjectSetIvarValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    object_setIvar(object, ivar, value);
}

void _NSSetObjectSetManualValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    extern id objc_retain(id obj);
    extern id objc_autorelease(id obj);
    ptrdiff_t offset = ivar_getOffset(ivr);
    objc_autorelease( *((id *)AddressAtObjectOffset(object, offset)))
    objc_retain(value);
    *((id *)AddressAtObjectOffset(object, offset)) = value;
}

void _NSSetObjectSetStrongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    ptrdiff_t offset = ivar_getOffset(ivar);
    extern void objc_storeStrong(id *location, id obj)
    objc_storeStrong((id *)AddressAtObjectOffset(object, offset), value);
}

void _NSSetObjectSetWeakValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    ptrdiff_t offset = ivar_getOffset(ivar);
    objc_storeWeak((id *)AddressAtObjectOffset(object, offset), value);
}

void _NSSetObjectSetAssignValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) {
    ptrdiff_t offset = ivar_getOffset(ivar);
    *((id *)AddressAtObjectOffset(object, offset)) = value;
}
