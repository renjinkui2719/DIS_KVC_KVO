//
//  DSGetValueInIvar.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSGetValueInIvar.h"
#import "DSKeyValueCodingCommon.h"

NSNumber * _DSGetUnsignedCharValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned char value = *(unsigned char *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedChar:value] autorelease];
}

NSNumber * _DSGetCharValueInIvar(id object, SEL selector, Ivar ivar) {
    char value = *(char *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithChar:value] autorelease];
}

NSNumber * _DSGetBoolValueInIvar(id object, SEL selector, Ivar ivar) {
    BOOL value = *(BOOL *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithBool:value] autorelease];
}

NSNumber * _DSGetDoubleValueInIvar(id object, SEL selector, Ivar ivar) {
    double value = *(double *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithDouble:value] autorelease];
}

NSNumber * _DSGetFloatValueInIvar(id object, SEL selector, Ivar ivar) {
    float value = *(float *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithFloat:value] autorelease];
}

NSNumber * _DSGetIntValueInIvar(id object, SEL selector, Ivar ivar) {
    int value = *(int *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithInt:value] autorelease];
}

NSNumber * _DSGetUnsignedIntValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned int value = *(unsigned int *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedInt:value] autorelease];
}

NSNumber * _DSGetLongValueInIvar(id object, SEL selector, Ivar ivar) {
    long value = *(long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedChar:value] autorelease];
}

NSNumber * _DSGetUnsignedLongValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned long value = *(unsigned long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedLong:value] autorelease];
}

NSNumber * _DSGetLongLongValueInIvar(id object, SEL selector, Ivar ivar) {
    long long value = *(long long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithLongLong:value] autorelease];
}

NSNumber * _DSGetUnsignedLongLongValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned long long value = *(unsigned long long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedLongLong:value] autorelease];
}

NSNumber * _DSGetShortValueInIvar(id object, SEL selector, Ivar ivar) {
    short value = *(short *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithShort:value] autorelease];
}

NSNumber * _DSGetUnsignedShortValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned short value = *(unsigned short *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedShort:value] autorelease];
}

NSValue * _DSGetPointValueInIvar(id object, SEL selector, Ivar ivar) {
#if TARGET_OS_IPHONE
    CGPoint value = *(CGPoint *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithCGPoint:value];
#else
    NSPoint value = *(NSPoint *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithPoint:value];
#endif
}

NSValue * _DSGetRangeValueInIvar(id object, SEL selector, Ivar ivar) {
    NSRange value = *(NSRange *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithRange:value];
}

NSValue * _DSGetRectValueInIvar(id object, SEL selector, Ivar ivar) {
#if TARGET_OS_IPHONE
    CGRect value = *(CGRect *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithCGRect:value];
#else
    NSRect value = *(NSRect *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithRect:value];
#endif
}

NSValue * _DSGetSizeValueInIvar(id object, SEL selector, Ivar ivar) {
#if TARGET_OS_IPHONE
    CGSize value = *(CGSize *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithCGSize:value];
#else
    NSSize value = *(NSSize *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithSize:value];
#endif
}

NSValue * _DSGetValueInIvar(id object, SEL selector, Ivar ivar) {
    const char *encoding = ivar_getTypeEncoding(ivar);
    size_t encodingLen = strlen(encoding);
    char objcType[encodingLen + 1];
    size_t objcTypeLen = 0;
    
    if(encodingLen) {
        BOOL quotationStart = NO;
        for(size_t i=0; i<encodingLen; ++i) {
            if(encoding[i] == '"') {
                quotationStart = !quotationStart;
            }
            else {
                if(!quotationStart) {
                    objcType[objcTypeLen++] = encoding[i];
                }
            }
        }
    }
    
    objcType[objcTypeLen] = '\0';
    
    return [NSValue valueWithBytes:object_getIvarAddress(object, ivar) objCType:objcType];
}

id _DSGetObjectGetWeakValueInIvar(id object, SEL selector, Ivar ivar) {
    return objc_loadWeak((id *)object_getIvarAddress(object, ivar));
}

id _DSGetObjectGetAssignValueInIvar(id object, SEL selector, Ivar ivar) {
    return *(id *)object_getIvarAddress(object, ivar);
}

id _DSGetObjectGetIvarValueInIvar(id object, SEL selector, Ivar ivar) {
    return object_getIvar(object, ivar);
}


