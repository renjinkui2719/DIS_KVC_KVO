//
//  NSGetValueWithMethod.m
//  KV
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSGetValueWithMethod.h"
#import <objc/runtime.h>

NSNumber * _NSGetBoolValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithBool: ((BOOL (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetCharValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithChar: ((char (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetUnsignedCharValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedChar: ((unsigned char (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetShortValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithShort: ((short (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetUnsignedShortValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedShort: ((unsigned short (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetIntValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithInt: ((int (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetUnsignedIntValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedInt: ((unsigned int (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithLong: ((long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetUnsignedLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedLong: ((unsigned long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetLongLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithLongLong: ((long long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetUnsignedLongLongValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithUnsignedLongLong: ((unsigned long long (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetDoubleValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithDouble: ((double (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

NSNumber * _NSGetFloatValueWithMethod(id object, SEL selctor, Method method) {
    return [[[NSNumber alloc] initWithFloat: ((float (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))] autorelease];
}

id  _NSGetVoidValueWithMethod(id object, SEL selctor, Method method) {
    ((void (*)(id,SEL))method_getImplementation(method))(object, method_getName(method));
    return nil;
}

NSValue * _NSGetRangeValueWithMethod(id object, SEL selctor, Method method) {
    return [NSValue valueWithRange:((NSRange (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
}

NSValue * _NSGetRectValueWithMethod(id object, SEL selctor, Method method) {
    return [NSValue valueWithRect:((NSRect (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
}

NSValue * _NSGetSizeValueWithMethod(id object, SEL selctor, Method method) {
    return [NSValue valueWithSize:((NSSize (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
}

NSValue * _NSGetPointValueWithMethod(id object, SEL selctor, Method method) {
    return [NSValue valueWithPoint:((NSPoint (*)(id,SEL))method_getImplementation(method))(object, method_getName(method))];
}

NSValue *  _NSGetValueWithMethod(id object, SEL selctor, Method method) {
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
