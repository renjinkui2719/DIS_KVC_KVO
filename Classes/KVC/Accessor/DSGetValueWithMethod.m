//
//  DSGetValueWithMethod.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSGetValueWithMethod.h"
#import <objc/runtime.h>

NSNumber * _DSGetBoolValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithBool: ((BOOL (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetCharValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithChar: ((char (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetUnsignedCharValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedChar: ((unsigned char (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetShortValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithShort: ((short (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetUnsignedShortValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedShort: ((unsigned short (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetIntValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithInt: ((int (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetUnsignedIntValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedInt: ((unsigned int (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithLong: ((long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetUnsignedLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedLong: ((unsigned long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetLongLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithLongLong: ((long long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetUnsignedLongLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedLongLong: ((unsigned long long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetDoubleValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithDouble: ((double (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _DSGetFloatValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithFloat: ((float (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

id  _DSGetVoidValueWithMethod(id object, SEL selctor, Method method) {
    ((void (*)(id,SEL))method_getImplementation(method))(object, method_getName(method));
    return nil;
}

NSValue * _DSGetRangeValueWithMethod(id object, SEL selctor, Method method) {
    return [NSValue valueWithRange:((NSRange (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
}

NSValue * _DSGetRectValueWithMethod(id object, SEL selctor, Method method) {
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGRect:((CGRect (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
#else
    return [NSValue valueWithRect:((NSRect (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
#endif
}

NSValue * _DSGetSizeValueWithMethod(id object, SEL selctor, Method method) {
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGSize:((CGSize (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
#else
    return [NSValue valueWithSize:((NSSize (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
#endif
}

NSValue * _DSGetPointValueWithMethod(id object, SEL selctor, Method method) {
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGPoint:((CGPoint (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
#else
    return [NSValue valueWithPoint:((NSPoint (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
#endif
}

NSValue *  _DSGetValueWithMethod(id object, SEL selctor, Method method) {
    NSMethodSignature *signature = [object methodSignatureForSelector:selctor];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = object;
    invocation.selector = selctor;
    [invocation invoke];
    
    NSUInteger returnLength = [signature methodReturnLength];
    unsigned char returnBuff[returnLength];
    [invocation getReturnValue:returnBuff];
    
    return [NSValue valueWithBytes:returnBuff objCType:[signature methodReturnType]];
}
