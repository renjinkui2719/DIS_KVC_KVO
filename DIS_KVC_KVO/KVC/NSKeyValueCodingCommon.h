//
//  NSKeyValueCodingCommon.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern NSString * _NSMethodExceptionProem(id,SEL);

static inline void *object_getIvarAddress(id object, Ivar ivar) {
    return (void *)((uint8_t *)object + ivar_getOffset(ivar));
}

static inline id object_getIvarDirectly(id object, Ivar ivar) {
    return *(id *)object_getIvarAddress(object, ivar);
}

static inline void object_setIvarDirectly(id object, Ivar ivar, id value) {
    *(id *)object_getIvarAddress(object, ivar) = value;
}
