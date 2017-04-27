//
//  NSobject.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/5.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+ (DSKeyValueGetter *)_createValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (DSKeyValueGetter *)_createValuePrimitiveGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;

+ (DSKeyValueSetter *)_createValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (DSKeyValueSetter *)_createValuePrimitiveSetterWithContainerClassID:(id)containerClassID key:(NSString *)key;


+ (DSKeyValueGetter *)_createMutableArrayValueGetterWithContainerClassID:(Class)containerClassID key:(NSString *)key;
+ (DSKeyValueGetter *)_createMutableOrderedSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
+ (DSKeyValueGetter *)_createMutableSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key;
@end


