//
//  NSKeyValueCodingCommon.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/**
 Get a string of pattern: "*** -[ClassName selector]". 
 
 It is usually used as a prefix for an exception description. e.g "*** -[User setValue:forKey:]: attempt to set a value for a nil key"
 
 @param object An object that throws an exception.
 @param selector Selector that throws an exception.
 */
extern NSString * _NSMethodExceptionProem(id object,SEL selector);

/**
 Release the buff allocated by NSAllocateObjectArray
 */
extern int NSFreeObjectArray(void *ptr);

/**
 Allocate and return a buff that can hold count objects
 */
extern void* NSAllocateObjectArray(NSUInteger count);

/**
 Get the address of ivar
 */
static inline void *object_getIvarAddress(id object, Ivar ivar) {
    return (void *)((uint8_t *)object + ivar_getOffset(ivar));
}

/**
 Get value of ivar directly, the value is assumed to be an object
 */
static inline id object_getIvarDirectly(id object, Ivar ivar) {
    return *(id *)object_getIvarAddress(object, ivar);
}

/**
 Set value of ivar directly, the value is assumed to be an object
 */
static inline void object_setIvarDirectly(id object, Ivar ivar, id value) {
    *(id *)object_getIvarAddress(object, ivar) = value;
}

extern id   objc_retain(id obj);
extern void objc_release(id obj);
extern id   objc_autorelease(id obj);
extern void objc_storeStrong(id *location, id obj);
extern id   objc_storeWeak(id *location, id newObj);

CF_EXPORT CFStringEncoding __CFDefaultEightBitStringEncoding;
CF_EXPORT CFStringEncoding __CFStringComputeEightBitStringEncoding(void);

