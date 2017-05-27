//
//  DSKeyValueCodingCommon.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <pthread.h>
#import <libkern/OSAtomic.h>
#import "Log.h"

extern NSString * _NSMethodExceptionProem(id object,SEL selector);

extern int NSFreeObjectArray(void *ptr);

extern void* NSAllocateObjectArray(NSUInteger count);

extern id   objc_retain(id obj);
extern void objc_release(id obj);
extern id   objc_autorelease(id obj);
extern void objc_storeStrong(id *location, id obj);
extern id   objc_storeWeak(id *location, id newObj);

CF_EXPORT CFStringEncoding __CFDefaultEightBitStringEncoding;
CF_EXPORT CFStringEncoding __CFStringComputeEightBitStringEncoding(void);

extern NSString *const NSUnknownKeyException;
extern NSString *const NSTargetObjectUserInfoKey;
extern NSString *const NSUnknownUserInfoKey;


static inline void *object_getIvarAddress(id object, Ivar ivar) {
    return (void *)((uint8_t *)object + ivar_getOffset(ivar));
}

static inline id object_getIvarDirectly(id object, Ivar ivar) {
    return *(id *)object_getIvarAddress(object, ivar);
}

static inline void object_setIvarDirectly(id object, Ivar ivar, id value) {
    *(id *)object_getIvarAddress(object, ivar) = value;
}
