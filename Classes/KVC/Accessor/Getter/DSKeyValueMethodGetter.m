//
//  DSKeyValueMethodGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSKeyValueMethodGetter.h"
#import "DSGetValueWithMethod.h"


@implementation DSKeyValueMethodGetter
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key method:(Method)method {
    NSUInteger methodArgumentsCount = method_getNumberOfArguments(method);
    NSUInteger extraAtgumentCount = 1;
    if(methodArgumentsCount == 2) {
        char *returnType = method_copyReturnType(method);
        IMP imp = NULL;
        switch (returnType[0]) {
            case '#':
            case '@': {
                imp = method_getImplementation(method);
                extraAtgumentCount = 0;
            } break;
            case 'B': {
                imp = (IMP)_DSGetBoolValueWithMethod;
            } break;
            case 'C': {
                imp = (IMP)_DSGetUnsignedCharValueWithMethod;
            } break;
            case 'I': {
                imp = (IMP)_DSGetUnsignedIntValueWithMethod;
            } break;
            case 'Q': {
                imp = (IMP)_DSGetUnsignedLongLongValueWithMethod;
            } break;
            case 'L': {
                imp = (IMP)_DSGetUnsignedLongValueWithMethod;
            } break;
            case 'S': {
                imp = (IMP)_DSGetUnsignedShortValueWithMethod;
            } break;
            case 'c': {
                imp = (IMP)_DSGetCharValueWithMethod;
            } break;
            case 'd': {
                imp = (IMP)_DSGetDoubleValueWithMethod;
            } break;
            case 'f': {
                imp = (IMP)_DSGetFloatValueWithMethod;
            } break;
            case 'i': {
                imp = (IMP)_DSGetIntValueWithMethod;
            } break;
            case 'l': {
                imp = (IMP)_DSGetLongValueWithMethod;
            } break;
            case 'q': {
                imp = (IMP)_DSGetLongLongValueWithMethod;
            } break;
            case 's': {
                imp = (IMP)_DSGetShortValueWithMethod;
            } break;
            case '{': {
                if (strcmp(returnType, @encode(CGPoint)) == 0){
                    imp = (IMP)_DSGetPointValueWithMethod;
                }
#if TARGET_OS_OSX
                else if (strcmp(returnType, @encode(NSPoint)) == 0){
                    imp = (IMP)_DSGetPointValueWithMethod;
                }
#endif
                else if (strcmp(returnType, @encode(NSRange)) == 0){
                    imp = (IMP)_DSGetRangeValueWithMethod;
                }
                else if (strcmp(returnType, @encode(CGRect)) == 0){
                    imp = (IMP)_DSGetRectValueWithMethod;
                }
#if TARGET_OS_OSX
                else if (strcmp(returnType, @encode(NSRect)) == 0){
                    imp = (IMP)_DSGetRectValueWithMethod;
                }
#endif
                else if (strcmp(returnType, @encode(CGSize)) == 0){
                    imp = (IMP)_DSGetSizeValueWithMethod;
                }
#if TARGET_OS_OSX
                else if (strcmp(returnType, @encode(NSSize)) == 0){
                    imp = (IMP)_DSGetSizeValueWithMethod;
                }
#endif
                else {
                    imp = (IMP)_DSGetValueWithMethod;
                }
            } break;
        }
        
        free(returnType);
        if(imp) {
            void *arguments[3] = {0};
            if(extraAtgumentCount > 0) {
                arguments[0] = method;
            }
            return [super initWithContainerClassID:containerClassID key:key implementation:imp selector:method_getName(method) extraArguments:arguments count:extraAtgumentCount];
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
