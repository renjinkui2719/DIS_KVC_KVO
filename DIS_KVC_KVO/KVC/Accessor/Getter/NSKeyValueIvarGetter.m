//
//  NSKeyValueIvarGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueIvarGetter.h"
#import "NSGetValueInIvar.h"
#import <objc/runtime.h>

@implementation NSKeyValueIvarGetter
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa ivar:(Ivar)ivar {
    const char *ivarEncoding = ivar_getTypeEncoding(ivar);
    IMP imp = NULL;
    switch (ivarEncoding[0]) {
        case '#':
        case '@': {
            objc_ivar_memory_management_t mngment = _class_getIvarMemoryManagement(containerIsa, ivar);
            if(mngment < objc_ivar_memoryWeak) {
                imp = (IMP)_NSGetObjectGetAssignValueInIvar;
            }
            else if (mngment == objc_ivar_memoryWeak) {
                imp = (IMP)_NSGetObjectGetWeakValueInIvar;
            }
            else if(mngment == objc_ivar_memoryUnretained) {
                imp = (IMP)_NSGetObjectGetAssignValueInIvar;
            }
            else {
                imp = (IMP)_NSGetObjectGetIvarValueInIvar;
            }
        }
            break;
        case 'C': {
            imp = (IMP)_NSGetUnsignedCharValueInIvar;
        }
            break;
        case 'B': {
            imp = (IMP)_NSGetBoolValueInIvar;
        }
            break;
        case 'I': {
            imp = (IMP)_NSGetUnsignedIntValueInIvar;
        }
            break;
        case 'L': {
            imp = (IMP)_NSGetUnsignedLongValueInIvar;
        }
            break;
        case 'Q': {
            imp = (IMP)_NSGetUnsignedLongLongValueInIvar;
        }
            break;
        case 'S': {
            imp = (IMP)_NSGetUnsignedShortValueInIvar;
        }
            break;
        case '{': {
            
            char* idx = index(ivarEncoding, '=');
            if (idx == NULL) {
                imp = (IMP)_NSGetValueInIvar;
            }
            else if (strncmp(ivarEncoding, "{CGPoint=ff}", idx - ivarEncoding) == 0){
                imp = (IMP)_NSGetPointValueInIvar;
            }
            else if (strncmp(ivarEncoding, "{_NSPoint=ff}", idx - ivarEncoding) == 0){
                imp = (IMP)_NSGetPointValueInIvar;
            }
            else if (strncmp(ivarEncoding, "{_NSRange=II}", idx - ivarEncoding) == 0){
                imp = (IMP)_NSGetRangeValueInIvar;
            }
            else if (strncmp(ivarEncoding, "{CGRect={CGPoint=ff}{CGSize=ff}}", idx - ivarEncoding) == 0){
                imp = (IMP)_NSGetRectValueInIvar;
            }
            else if (strncmp(ivarEncoding, "{_NSRect={_NSPoint=ff}{_NSSize=ff}}", idx - ivarEncoding) == 0){
                imp = (IMP)_NSGetRectValueInIvar;
            }else if (strncmp(ivarEncoding, "{CGSize=ff}", idx - ivarEncoding) == 0){
                imp = (IMP)_NSGetSizeValueInIvar;
            }
            else if (strncmp(ivarEncoding, "{_NSSize=ff}", idx - ivarEncoding) == 0){
                imp = (IMP)_NSGetSizeValueInIvar;
            }
            else {
                imp = (IMP)_NSGetValueInIvar;
            }
        }
            break;
        case 'c': {
            imp = (IMP)_NSGetCharValueInIvar;
        }
            break;
        case 'd': {
            imp = (IMP)_NSGetDoubleValueInIvar;
        }
            break;
        case 'f': {
            imp = (IMP)_NSGetFloatValueInIvar;
        }
            break;
        case 'i': {
            imp = (IMP)_NSGetIntValueInIvar;
        }
            break;
        case 'l': {
            imp = (IMP)_NSGetLongValueInIvar;
        }
            break;
        case 'q': {
            imp = (IMP)_NSGetLongLongValueInIvar;
        }
            break;
        case 's': {
            imp = (IMP)_NSGetShortValueInIvar;
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
