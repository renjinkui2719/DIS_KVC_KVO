//
//  DSSetValueForKeyWithMethod.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/9.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSSetValueForKeyWithMethod.h"

#define __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, valueType, valueGetSelectorName) do {\
    if (value) {\
        void (*imp)(id,SEL,valueType) = (void (*)(id,SEL,valueType))method_getImplementation(method);\
        imp(object, method_getName(method), [value valueGetSelectorName]);\
    }\
    else {\
        [object setNilValueForKey:key];\
    }\
}while(0)

void _DSSetUnsignedIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, unsigned int, unsignedIntValue);
}

void _DSSetBoolValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, BOOL, boolValue);
}

void _DSSetUnsignedCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, unsigned char, unsignedCharValue);
}

void _DSSetUnsignedLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, unsigned long long, unsignedLongLongValue);
}

void _DSSetUnsignedLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, unsigned long, unsignedLongValue);
}

void _DSSetCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, char, charValue);
}

void _DSSetDoubleValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, double, doubleValue);
}

void _DSSetFloatValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, float, floatValue);
}

void _DSSetIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, int, intValue);
}

void _DSSetLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, long, longValue);
}

void _DSSetLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, long long, longLongValue);
}

void _DSSetShortValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, short, shortValue);
}

void _DSSetRangeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, NSRange, rangeValue);
}

#if TARGET_OS_IPHONE
void _DSSetPointValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, CGPoint, CGPointValue);
}

void _DSSetRectValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, CGRect, CGRectValue);
}

void _DSSetSizeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, CGSize, CGSizeValue);
}
#else
void _DSSetPointValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, NSPoint, pointValue);
}

void _DSSetRectValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, NSRect, rectValue);
}

void _DSSetSizeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method) {
    __DSSetPrimitiveValueForKeyWithMethod(object, selector, value, key, method, NSSize, sizeValue);
}
#endif

void _DSSetValueWithMethod(id object, SEL selector,id value, NSString *key, __unused Method method) {
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
