//
//  NSKeyValueMethodGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMethodGetter.h"
#import "NSGetValueWithMethod.h"

@implementation NSKeyValueMethodGetter
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key method:(Method)method {
    NSUInteger argumentsCount = method_getNumberOfArguments(method);
    if(argumentsCount == 2) {
        char *returnType = method_copyReturnType(method);
        IMP imp = NULL;
        NSUInteger augumentCount = 1;
        switch (returnType[0]) {
            case '#':
            case '@': {
                imp = method_getImplementation(method);
                augumentCount = 0;
            } break;
            case 'B': {
                imp = (IMP)_NSGetBoolValueWithMethod;
            } break;
            case 'C': {
                imp = (IMP)_NSGetUnsignedCharValueWithMethod;
            } break;
            case 'I': {
                imp = (IMP)_NSGetUnsignedIntValueWithMethod;
            } break;
            case 'Q': {
                imp = (IMP)_NSGetUnsignedLongLongValueWithMethod;
            } break;
            case 'L': {
                imp = (IMP)_NSGetUnsignedLongValueWithMethod;
            } break;
            case 'S': {
                imp = (IMP)_NSGetUnsignedShortValueWithMethod;
            } break;
            case 'c': {
                imp = (IMP)_NSGetCharValueWithMethod;
            } break;
            case 'd': {
                imp = (IMP)_NSGetDoubleValueWithMethod;
            } break;
            case 'f': {
                imp = (IMP)_NSGetFloatValueWithMethod;
            } break;
            case 'i': {
                imp = (IMP)_NSGetIntValueWithMethod;
            } break;
            case 'l': {
                imp = (IMP)_NSGetLongValueWithMethod;
            } break;
            case 'q': {
                imp = (IMP)_NSGetLongLongValueWithMethod;
            } break;
            case 's': {
                imp = (IMP)_NSGetShortValueWithMethod;
            } break;
            case '{': {
                if (strcmp(returnType, "{CGPoint=ff}") == 0){
                    imp = (IMP)_NSGetPointValueWithMethod;
                }
                else if (strcmp(returnType, "{_NSPoint=ff}") == 0){
                    imp = (IMP)_NSGetPointValueWithMethod;
                }
                else if (strcmp(returnType, "{_NSRange=II}") == 0){
                    imp = (IMP)_NSGetRangeValueWithMethod;
                }
                else if (strcmp(returnType, "{CGRect={CGPoint=ff}{CGSize=ff}}") == 0){
                    imp = (IMP)_NSGetRectValueWithMethod;
                }
                else if (strcmp(returnType, "{_NSRect={_NSPoint=ff}{_NSSize=ff}}") == 0){
                    imp = (IMP)_NSGetRectValueWithMethod;
                }else if (strcmp(returnType, "{CGSize=ff}") == 0){
                    imp = (IMP)_NSGetSizeValueWithMethod;
                }
                else if (strcmp(returnType, "{_NSSize=ff}") == 0){
                    imp = (IMP)_NSGetSizeValueWithMethod;
                }
                else {
                    imp = (IMP)_NSGetValueWithMethod;
                }
            } break;
        }
        
        free(returnType);
        if(imp) {
            void *arguments[3] = {0};
            if(argumentsCount > 0) {
                arguments[0] = method;
            }
            return [super initWithContainerClassID:containerClassID key:key implementation:imp selector:method_getName(method) extraArguments:arguments count:argumentsCount];
        }
        else {
            [self release];
            return nil;
        }
    }
    else {
        [self release];
        return nil;
    }
}
@end
