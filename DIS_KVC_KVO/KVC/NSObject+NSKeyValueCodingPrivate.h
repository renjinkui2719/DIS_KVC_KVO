//
//  NSobject.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/5.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueGetter;
@class NSKeyValueSetter;

extern CFMutableSetRef NSKeyValueCachedGetters;
extern CFMutableSetRef NSKeyValueCachedSetters;

extern CFMutableSetRef NSKeyValueCachedMutableArrayGetters;
extern CFMutableSetRef NSKeyValueCachedMutableOrderedSetGetters;
extern CFMutableSetRef NSKeyValueCachedMutableSetGetters;
extern CFMutableSetRef NSKeyValueCachedPrimitiveSetters;
extern CFMutableSetRef NSKeyValueCachedPrimitiveGetters;

id _NSGetUsingKeyValueGetter(id object, NSKeyValueGetter *getter) ;
void _NSSetUsingKeyValueSetter(id object, NSKeyValueSetter *setter, id value);

struct objc_method * NSKeyValueMethodForPattern(Class class, const char *pattern,const char *param);
struct objc_ivar * NSKeyValueIvarForPattern(Class class, const char *pattern,const char *param);

NSKeyValueSetter * _NSKeyValueSetterForClassAndKey(Class containerClassID, NSString *key, Class class);
NSKeyValueGetter * _NSKeyValueGetterForClassAndKey(Class containerClassID, NSString *key, Class class);
NSKeyValueSetter * _NSKeyValuePrimitiveSetterForClassAndKey(Class containerClassID, NSString *key, Class class);
NSKeyValueGetter * _NSKeyValuePrimitiveGetterForClassAndKey(Class containerClassID, NSString *key, Class class);
NSKeyValueGetter * _NSKeyValueMutableSetGetterForClassAndKey(Class containerClassID, NSString *key, Class class);
NSKeyValueGetter * _NSKeyValueMutableOrderedSetGetterForIsaAndKey(Class containerClassID, NSString *key);
NSKeyValueGetter * _NSKeyValueMutableArrayGetterForIsaAndKey(Class containerClassID, NSString *key);
void _NSKeyValueInvalidateCachedMutatorsForIsaAndKey(Class isa, NSString *key);
void _NSKeyValueInvalidateAllCachesForContainerAndKey(Class containerClassID, NSString *key);

@interface NSObject (NSKeyValueCodingPrivate)
+ (NSKeyValueGetter *)_createValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (NSKeyValueGetter *)_createValuePrimitiveGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;

+ (NSKeyValueSetter *)_createValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (NSKeyValueSetter *)_createValuePrimitiveSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;


+ (NSKeyValueGetter *)_createMutableArrayValueGetterWithContainerClassID:(Class)containerClassID key:(NSString *)key;
+ (NSKeyValueGetter *)_createMutableOrderedSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (NSKeyValueGetter *)_createMutableSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
@end


