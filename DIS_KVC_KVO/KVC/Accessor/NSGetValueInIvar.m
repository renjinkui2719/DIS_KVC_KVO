//
//  NSGetValueInIvar.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSGetValueInIvar.h"
#import "NSKeyValueCodingCommon.h"

NSNumber * _NSGetUnsignedCharValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned char value = *(unsigned char *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedChar:value] autorelease];
}

NSNumber * _NSGetCharValueInIvar(id object, SEL selector, Ivar ivar) {
    char value = *(char *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithChar:value] autorelease];
}

NSNumber * _NSGetBoolValueInIvar(id object, SEL selector, Ivar ivar) {
    BOOL value = *(BOOL *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithBool:value] autorelease];
}

NSNumber * _NSGetDoubleValueInIvar(id object, SEL selector, Ivar ivar) {
    double value = *(double *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithDouble:value] autorelease];
}

NSNumber * _NSGetFloatValueInIvar(id object, SEL selector, Ivar ivar) {
    float value = *(float *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithFloat:value] autorelease];
}

NSNumber * _NSGetIntValueInIvar(id object, SEL selector, Ivar ivar) {
    int value = *(int *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithInt:value] autorelease];
}

NSNumber * _NSGetUnsignedIntValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned int value = *(unsigned int *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedInt:value] autorelease];
}

NSNumber * _NSGetLongValueInIvar(id object, SEL selector, Ivar ivar) {
    long value = *(long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedChar:value] autorelease];
}

NSNumber * _NSGetUnsignedLongValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned long value = *(unsigned long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedLong:value] autorelease];
}

NSNumber * _NSGetLongLongValueInIvar(id object, SEL selector, Ivar ivar) {
    long long value = *(long long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithLongLong:value] autorelease];
}

NSNumber * _NSGetUnsignedLongLongValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned long long value = *(unsigned long long *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedLongLong:value] autorelease];
}

NSNumber * _NSGetShortValueInIvar(id object, SEL selector, Ivar ivar) {
    short value = *(short *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithShort:value] autorelease];
}

NSNumber * _NSGetUnsignedShortValueInIvar(id object, SEL selector, Ivar ivar) {
    unsigned short value = *(unsigned short *)object_getIvarAddress(object, ivar);
    return [[[NSNumber alloc] initWithUnsignedShort:value] autorelease];
}

NSValue * _NSGetPointValueInIvar(id object, SEL selector, Ivar ivar) {
    NSPoint value = *(NSPoint *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithPoint:value];
}

NSValue * _NSGetRangeValueInIvar(id object, SEL selector, Ivar ivar) {
    NSRange value = *(NSRange *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithRange:value];
}

NSValue * _NSGetRectValueInIvar(id object, SEL selector, Ivar ivar) {
    NSRect value = *(NSRect *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithRect:value];
}

NSValue * _NSGetSizeValueInIvar(id object, SEL selector, Ivar ivar) {
    NSSize value = *(NSSize *)object_getIvarAddress(object, ivar);
    return [NSValue valueWithSize:value];
}

NSValue * _NSGetValueInIvar(id object, SEL selector, Ivar ivar) {
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

id _NSGetObjectGetWeakValueInIvar(id object, SEL selector, Ivar ivar) {
    return objc_loadWeak((id *)object_getIvarAddress(object, ivar));
}

id _NSGetObjectGetAssignValueInIvar(id object, SEL selector, Ivar ivar) {
    return *(id *)object_getIvarAddress(object, ivar);
}

id _NSGetObjectGetIvarValueInIvar(id object, SEL selector, Ivar ivar) {
    return object_getIvar(object, ivar);
}


