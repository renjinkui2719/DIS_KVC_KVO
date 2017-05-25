//
//  DSKeyValueIvarGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSKeyValueIvarGetter.h"
#import "DSGetValueInIvar.h"
#import <objc/runtime.h>

@implementation DSKeyValueIvarGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa ivar:(Ivar)ivar {
    const char *ivarEncoding = ivar_getTypeEncoding(ivar);
    IMP imp = NULL;
    switch (ivarEncoding[0]) {
        case '#':
        case '@': {
            objc_ivar_memory_management_t mngment = objc_ivar_memoryUnknown;//_class_getIvarMemoryManagement(containerIsa, ivar);
            if(mngment < objc_ivar_memoryWeak) {
                imp = (IMP)_DSGetObjectGetAssignValueInIvar;
            }
            else if (mngment == objc_ivar_memoryWeak) {
                imp = (IMP)_DSGetObjectGetWeakValueInIvar;
            }
            else if(mngment == objc_ivar_memoryUnretained) {
                imp = (IMP)_DSGetObjectGetAssignValueInIvar;
            }
            else {
                imp = (IMP)_DSGetObjectGetIvarValueInIvar;
            }
        }
            break;
        case 'C': {
            imp = (IMP)_DSGetUnsignedCharValueInIvar;
        }
            break;
        case 'B': {
            imp = (IMP)_DSGetBoolValueInIvar;
        }
            break;
        case 'I': {
            imp = (IMP)_DSGetUnsignedIntValueInIvar;
        }
            break;
        case 'L': {
            imp = (IMP)_DSGetUnsignedLongValueInIvar;
        }
            break;
        case 'Q': {
            imp = (IMP)_DSGetUnsignedLongLongValueInIvar;
        }
            break;
        case 'S': {
            imp = (IMP)_DSGetUnsignedShortValueInIvar;
        }
            break;
        case '{': {
            
            char* idx = index(ivarEncoding, '=');
            if (idx == NULL) {
                imp = (IMP)_DSGetValueInIvar;
            }
            else if (strncmp(ivarEncoding, @encode(CGPoint), idx - ivarEncoding) == 0){
                imp = (IMP)_DSGetPointValueInIvar;
            }
#if TARGET_OS_OSX
            else if (strncmp(ivarEncoding, @encode(NSPoint), idx - ivarEncoding) == 0){
                imp = (IMP)_DSGetPointValueInIvar;
            }
#endif
            else if (strncmp(ivarEncoding, @encode(NSRange), idx - ivarEncoding) == 0){
                imp = (IMP)_DSGetRangeValueInIvar;
            }
            else if (strncmp(ivarEncoding, @encode(CGRect), idx - ivarEncoding) == 0){
                imp = (IMP)_DSGetRectValueInIvar;
            }
#if TARGET_OS_OSX
            else if (strncmp(ivarEncoding, @encode(NSRect), idx - ivarEncoding) == 0){
                imp = (IMP)_DSGetRectValueInIvar;
            }
#endif
            else if (strncmp(ivarEncoding, @encode(CGSize), idx - ivarEncoding) == 0){
                imp = (IMP)_DSGetSizeValueInIvar;
            }
#if TARGET_OS_OSX
            else if (strncmp(ivarEncoding, @encode(NSSize), idx - ivarEncoding) == 0){
                imp = (IMP)_DSGetSizeValueInIvar;
            }
#endif
            else {
                imp = (IMP)_DSGetValueInIvar;
            }
        }
            break;
        case 'c': {
            imp = (IMP)_DSGetCharValueInIvar;
        }
            break;
        case 'd': {
            imp = (IMP)_DSGetDoubleValueInIvar;
        }
            break;
        case 'f': {
            imp = (IMP)_DSGetFloatValueInIvar;
        }
            break;
        case 'i': {
            imp = (IMP)_DSGetIntValueInIvar;
        }
            break;
        case 'l': {
            imp = (IMP)_DSGetLongValueInIvar;
        }
            break;
        case 'q': {
            imp = (IMP)_DSGetLongLongValueInIvar;
        }
            break;
        case 's': {
            imp = (IMP)_DSGetShortValueInIvar;
        }
            break;
    }
    
    if(imp) {
        void *arguments[3] = {0};
        arguments[0] = ivar;
        return [super initWithContainerClassID:containerClassID key:key implementation:imp selector:NULL extraArguments:arguments count:1];
    }
    else {
        [self release];
        return nil;
    }
    
}

@end
