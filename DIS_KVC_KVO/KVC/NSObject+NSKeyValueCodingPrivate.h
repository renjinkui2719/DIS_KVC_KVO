//
//  NSobject.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/5.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class NSKeyValueGetter;
@class NSKeyValueSetter;

extern CFMutableSetRef  NSKeyValueCachedMutableOrderedSetGetters;
extern CFMutableSetRef NSKeyValueCachedMutableSetGetters;

id _NSGetUsingKeyValueGetter(id object, NSKeyValueGetter *getter) ;
void _NSSetUsingKeyValueSetter(id object, NSKeyValueSetter *setter, id value);

void NSKeyValueCacheAccessLock();
void NSKeyValueCacheAccessUnlock();

Method NSKeyValueMethodForPattern(Class class, const char *pattern,const char *param);
Ivar NSKeyValueIvarForPattern(Class class, const char *pattern,const char *param);

BOOL _NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key);

@interface NSObject (NSKeyValueCodingPrivate)
+ (NSKeyValueGetter *)_createValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (NSKeyValueGetter *)_createValuePrimitiveGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;

+ (NSKeyValueSetter *)_createValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (NSKeyValueSetter *)_createValuePrimitiveSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;

+ (NSKeyValueGetter *)_createMutableOrderedSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (NSKeyValueGetter *)_createMutableSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
@end


