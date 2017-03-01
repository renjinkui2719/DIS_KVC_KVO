//
//  NSKeyValueMethodSetter.m
//  KVOIMP
//
//  Created by JK on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMethodSetter.h"
#import "NSSetValueForKeyWithMethod.h"

@implementation NSKeyValueMethodSetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key method:(Method)method {
    
    if(method_getNumberOfArguments(method) == 3) {
        SEL sel = method_getName(method);
        char *argType = method_copyArgumentType(method, 2);
        IMP imp = NULL;
        NSUInteger extraArgumentCount = 0;
        switch (*argType) {
            case '#': {
                imp = method_getImplementation(method);
                extraArgumentCount = 0;
            }
                break;
            case '@': {
                imp = method_getImplementation(method);
                extraArgumentCount = 0;
            }
                break;
            case 'B': {
                imp = (IMP)_NSSetBoolValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'C': {
                imp = (IMP)_NSSetUnsignedCharValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'I': {
                imp = (IMP)_NSSetUnsignedIntValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'Q': {
                imp = (IMP)_NSSetUnsignedLongLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'L': {
                imp = (IMP)_NSSetUnsignedLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'c': {
                imp = (IMP)_NSSetCharValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'd': {
                imp = (IMP)_NSSetDoubleValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'f': {
                imp = (IMP)_NSSetFloatValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'i': {
                imp = (IMP)_NSSetIntValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'l': {
                imp = (IMP)_NSSetLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'q': {
                imp = (IMP)_NSSetLongLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 's': {
                imp = (IMP)_NSSetShortValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case '{': {
                if (strcmp(argType, "{CGPoint=ff}") == 0) {
                    imp = (IMP)_NSSetPointValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSPoint=ff}") == 0) {
                    imp = (IMP)_NSSetPointValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSRange=II}") == 0) {
                    imp = (IMP)_NSSetRangeValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{CGRect={CGPoint=ff}{CGSize=ff}}") == 0) {
                    imp = (IMP)_NSSetRectValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSRect={_NSPoint=ff}{_NSSize=ff}}") == 0) {
                    imp = (IMP)_NSSetRectValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{CGSize=ff}") == 0) {
                    imp = (IMP)_NSSetSizeValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSSize=ff}") == 0) {
                    imp = (IMP)_NSSetSizeValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{CGSize=ff}") == 0) {
                    imp = (IMP)_NSSetSizeValueForKeyWithMethod;
                }
                else {
                    imp = (IMP)_NSSetValueWithMethod;
                }
                extraArgumentCount = 2;
            }
                break;
            default:
                break;
        }
        
        free(argType);
        
        if (imp) {
            void *arguments[3];
            arguments[0] = (__bridge void*)key;
            arguments[1] = (extraArgumentCount > 1 ? method : NULL);
            arguments[2] = NULL;
            if (self = [super initWithContainerClassID:containerClassID key:key implementation:imp selector:sel extraArguments:arguments count:extraArgumentCount]) {
                _method = method;
            }
            return self;
        }
    }
             
    return nil;
}

@end
