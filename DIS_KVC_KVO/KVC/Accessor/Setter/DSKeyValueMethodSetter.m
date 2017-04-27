//
//  DSKeyValueMethodSetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMethodSetter.h"
#import "DSSetValueForKeyWithMethod.h"

@implementation DSKeyValueMethodSetter

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
                imp = (IMP)_DSSetBoolValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'C': {
                imp = (IMP)_DSSetUnsignedCharValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'I': {
                imp = (IMP)_DSSetUnsignedIntValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'Q': {
                imp = (IMP)_DSSetUnsignedLongLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'L': {
                imp = (IMP)_DSSetUnsignedLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'c': {
                imp = (IMP)_DSSetCharValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'd': {
                imp = (IMP)_DSSetDoubleValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'f': {
                imp = (IMP)_DSSetFloatValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'i': {
                imp = (IMP)_DSSetIntValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'l': {
                imp = (IMP)_DSSetLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 'q': {
                imp = (IMP)_DSSetLongLongValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case 's': {
                imp = (IMP)_DSSetShortValueForKeyWithMethod;
                extraArgumentCount = 2;
            }
                break;
            case '{': {
                if (strcmp(argType, "{CGPoint=ff}") == 0) {
                    imp = (IMP)_DSSetPointValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSPoint=ff}") == 0) {
                    imp = (IMP)_DSSetPointValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSRange=II}") == 0) {
                    imp = (IMP)_DSSetRangeValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{CGRect={CGPoint=ff}{CGSize=ff}}") == 0) {
                    imp = (IMP)_DSSetRectValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSRect={_NSPoint=ff}{_NSSize=ff}}") == 0) {
                    imp = (IMP)_DSSetRectValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{CGSize=ff}") == 0) {
                    imp = (IMP)_DSSetSizeValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{_NSSize=ff}") == 0) {
                    imp = (IMP)_DSSetSizeValueForKeyWithMethod;
                }
                else if (strcmp(argType, "{CGSize=ff}") == 0) {
                    imp = (IMP)_DSSetSizeValueForKeyWithMethod;
                }
                else {
                    imp = (IMP)_DSSetValueWithMethod;
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
            arguments[0] = key;
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
