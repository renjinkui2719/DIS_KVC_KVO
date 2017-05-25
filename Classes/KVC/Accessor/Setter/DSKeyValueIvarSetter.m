//
//  DSKeyValueIvarSetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSKeyValueIvarSetter.h"
#import "DSSetValueForKeyInIvar.h"
#import "DSKeyValueContainerClass.h"
#import "NSObject+DSKeyValueObserverNotification.h"

void _DSSetValueAndNotifyForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar, IMP imp) {
    [object d_willChangeValueForKey:key];
    
    ((void (*)(id,SEL,id,NSString *, Ivar))imp)(object,NULL,value,key,ivar);
    
    [object d_didChangeValueForKey:key];
}

@implementation DSKeyValueIvarSetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa ivar:(Ivar)ivar {
    IMP imp = NULL;
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    switch (*typeEncoding) {
        case 'c': {
            imp = (IMP)_DSSetCharValueForKeyInIvar;
        }
            break;
        case 'd': {
            imp = (IMP)_DSSetDoubleValueForKeyInIvar;
        }
            break;
        case 'f': {
            imp = (IMP)_DSSetFloatValueForKeyInIvar;
        }
            break;
        case 'i': {
            imp = (IMP)_DSSetIntValueForKeyInIvar;
        }
            break;
        case 'l': {
            imp = (IMP)_DSSetLongValueForKeyInIvar;
        }
            break;
        case 'q': {
            imp = (IMP)_DSSetLongLongValueForKeyInIvar;
        }
            break;
        case 's': {
            imp = (IMP)_DSSetShortValueForKeyInIvar;
        }
            break;
        case 'Q': {
            imp = (IMP)_DSSetUnsignedLongLongValueForKeyInIvar;
        }
            break;
        case 'L': {
            imp = (IMP)_DSSetUnsignedLongValueForKeyInIvar;
        }
            break;
        case 'B': {
            imp = (IMP)_DSSetBoolValueForKeyInIvar;
        }
            break;
        case 'C': {
            imp = (IMP)_DSSetUnsignedCharValueForKeyInIvar;
        }
            break;
        case 'I': {
            imp = (IMP)_DSSetUnsignedIntValueForKeyInIvar;
        }
            break;
        case 'S': {
            imp = (IMP)_DSSetUnsignedShortValueForKeyInIvar;
        }
            break;
        case '#':
        case '@':{
            objc_ivar_memory_management_t mngMent = objc_ivar_memoryUnknown;//_class_getIvarMemoryManagement(containerIsa, ivar);
            if(mngMent > objc_ivar_memoryUnretained) {
                imp = (IMP)_DSSetObjectSetIvarValueForKeyInIvar;
            }
            else if (mngMent == objc_ivar_memoryStrong) {
                imp = (IMP)_DSSetObjectSetStrongValueForKeyInIvar;
            }
            else if (mngMent == objc_ivar_memoryWeak) {
                imp = (IMP)_DSSetObjectSetWeakValueForKeyInIvar;
            }
            else if (mngMent == objc_ivar_memoryUnretained) {
                imp = (IMP)_DSSetObjectSetAssignValueForKeyInIvar;
            }
            else {
                imp = (IMP)_DSSetObjectSetManualValueForKeyInIvar;
            }
        }
            break;
        case '{': {
            char* idx = index(typeEncoding, '=');
            if (idx == NULL) {
                imp = (IMP)_DSSetValueInIvar;
            }
            else if (strncmp(typeEncoding, @encode(CGPoint), idx - typeEncoding) == 0){
                imp = (IMP)_DSSetPointValueForKeyInIvar;
            }
#if TARGET_OS_OSX
            else if (strncmp(typeEncoding, @encode(NSPoint), idx - typeEncoding) == 0){
                imp = (IMP)_DSSetPointValueForKeyInIvar;
            }
#endif
            else if (strncmp(typeEncoding, @encode(NSRange), idx - typeEncoding) == 0){
                imp = (IMP)_DSSetRangeValueForKeyInIvar;
            }
            else if (strncmp(typeEncoding, @encode(CGRect), idx - typeEncoding) == 0){
                imp = (IMP)_DSSetRectValueForKeyInIvar;
            }
#if TARGET_OS_OSX
            else if (strncmp(typeEncoding, @encode(NSRect), idx - typeEncoding) == 0){
                imp = (IMP)_DSSetRectValueForKeyInIvar;
            }
#endif
            else if (strncmp(typeEncoding, @encode(CGSize), idx - typeEncoding) == 0){
                imp = (IMP)_DSSetSizeValueForKeyInIvar;
            }
#if TARGET_OS_OSX
            else if (strncmp(typeEncoding, @encode(NSSize), idx - typeEncoding) == 0){
                imp = (IMP)_DSSetSizeValueForKeyInIvar;
            }
#endif
            else {
                imp = (IMP)_DSSetValueInIvar;
            }
        }
            break;
        default:
            break;
    }
    
    if (imp) {
        SEL sel = NULL;
        void *extraArguments[3];
        NSUInteger argumentCount = 0;
        
        if (_DSKVONotifyingMutatorsShouldNotifyForIsaAndKey(containerIsa, key)) {
            sel = NULL;
            
            extraArguments[0] = key;
            extraArguments[1] = ivar;
            extraArguments[2] = imp;
            
            imp = (IMP)_DSSetValueAndNotifyForKeyInIvar;
            
            argumentCount = 3;
        }
        else {
            sel = NULL;
            
            extraArguments[0] = key;
            extraArguments[1] = ivar;
            extraArguments[2] = NULL;
            
            argumentCount = 2;
        }
        
        self = [super initWithContainerClassID:containerClassID key:key implementation:imp selector:sel extraArguments:extraArguments count:argumentCount];
        
        return self;
    }
    
    return nil;
}

- (struct objc_ivar *)ivar {
    return (struct objc_ivar *)self.extraArgument2;
}

@end
