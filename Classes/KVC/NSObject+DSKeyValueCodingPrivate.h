//
//  NSobject.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/5.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>

@class DSKeyValueGetter;
@class DSKeyValueSetter;

extern CFMutableSetRef DSKeyValueCachedGetters;
extern CFMutableSetRef DSKeyValueCachedSetters;

extern CFMutableSetRef DSKeyValueCachedMutableArrayGetters;
extern CFMutableSetRef DSKeyValueCachedMutableOrderedSetGetters;
extern CFMutableSetRef DSKeyValueCachedMutableSetGetters;
extern CFMutableSetRef DSKeyValueCachedPrimitiveSetters;
extern CFMutableSetRef DSKeyValueCachedPrimitiveGetters;

extern OSSpinLock DSKeyValueCachedAccessorSpinLock;

id _DSGetUsingKeyValueGetter(id object, DSKeyValueGetter *getter) ;
void _DSSetUsingKeyValueSetter(id object, DSKeyValueSetter *setter, id value);

struct objc_method * DSKeyValueMethodForPattern(Class class, const char *pattern,const char *param);
struct objc_ivar * DSKeyValueIvarForPattern(Class class, const char *pattern,const char *param);

DSKeyValueSetter * _DSKeyValueSetterForClassAndKey(Class containerClassID, NSString *key, Class class);
DSKeyValueGetter * _DSKeyValueGetterForClassAndKey(Class containerClassID, NSString *key, Class class);
DSKeyValueSetter * _DSKeyValuePrimitiveSetterForClassAndKey(Class containerClassID, NSString *key, Class class);
DSKeyValueGetter * _DSKeyValuePrimitiveGetterForClassAndKey(Class containerClassID, NSString *key, Class class);
DSKeyValueGetter * _DSKeyValueMutableSetGetterForClassAndKey(Class containerClassID, NSString *key, Class class);
DSKeyValueGetter * _DSKeyValueMutableOrderedSetGetterForIsaAndKey(Class containerClassID, NSString *key);
DSKeyValueGetter * _DSKeyValueMutableArrayGetterForIsaAndKey(Class containerClassID, NSString *key);
void _DSKeyValueInvalidateCachedMutatorsForIsaAndKey(Class isa, NSString *key);
void _DSKeyValueInvalidateAllCachesForContainerAndKey(Class containerClassID, NSString *key);

@interface NSObject (DSKeyValueCodingPrivate)
+ (DSKeyValueGetter *)_d_createValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (DSKeyValueGetter *)_d_createValuePrimitiveGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;

+ (DSKeyValueSetter *)_d_createValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (DSKeyValueSetter *)_d_createValuePrimitiveSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;


+ (DSKeyValueGetter *)_d_createMutableArrayValueGetterWithContainerClassID:(Class)containerClassID key:(NSString *)key;
+ (DSKeyValueGetter *)_d_createMutableOrderedSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (DSKeyValueGetter *)_d_createMutableSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
@end


