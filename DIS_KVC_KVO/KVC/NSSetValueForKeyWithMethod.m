//
//  NSSetValueForKeyWithMethod.m
//  KVOIMP
//
//  Created by JK on 2017/1/9.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSSetValueForKeyWithMethod.h"


#define __NSSetValueForKeyWithMethod(object, selector, value, key, method, valueType, valueGetSelectorName) do {\
    if (value) {\
        void (*imp)(id,SEL,valueType) = (void (*)(id,SEL,valueType))method_getImplementation(method);\
        imp(object, method_getName(method), [value valueGetSelectorName]);\
    }\
    else {\
        [object setNilValueForKey:key];\
    }\
}while(0)

void _NSSetUnsignedIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, unsigned int, unsignedIntValue);
}

void _NSSetBoolValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, BOOL, boolValue);
}

void _NSSetUnsignedCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, unsigned char, unsignedCharValue);
}

void _NSSetUnsignedLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, unsigned long long, unsignedLongLongValue);
}

void _NSSetUnsignedLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, unsigned long, unsignedLongValue);
}

void _NSSetCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, char, charValue);
}

void _NSSetDoubleValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, double, doubleValue);
}

void _NSSetFloatValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, float, floatValue);
}

void _NSSetIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, int, intValue);
}

void _NSSetLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, long, longValue);
}

void _NSSetLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, long long, longLongValue);
}

void _NSSetShortValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, short, shortValue);
}

void _NSSetPointValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, NSPoint, pointValue);
}

void _NSSetRangeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, NSRange, rangeValue);
}

void _NSSetRectValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, NSRect, rectValue);
}

void _NSSetSizeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __NSSetValueForKeyWithMethod(object, selector, value, key, method, NSSize, sizeValue);
}

void _NSSetValueWithMethod(id object, SEL selector,id value, NSString *key, __unused Method method) {
    if (value) {
        NSMethodSignature *signature = [object methodSignatureForSelector:selector];
        
        NSUInteger size = [signature frameLength];
        size += 15;
        size &= 0xFFFFFFF0;
        unsigned char arguments[size];
        
        [value getValue:arguments];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = object;
        [invocation setArgument:arguments atIndex:2];
        
        [invocation invoke];
    }
    else {
        [object setNilValueForKey:key];
    }
}
