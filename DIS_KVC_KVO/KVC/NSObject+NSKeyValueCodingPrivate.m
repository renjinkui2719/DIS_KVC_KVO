//
//  NSobject.m
//  KVOIMP
//
//  Created by JK on 2017/1/5.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSobject+NSKeyValueCodingPrivate.h"
#import <objc/runtime.h>
#import "NSKeyValueCollectionGetter.h"
#import "NSKeyValueMethodGetter.h"
#import "NSKeyValueIvarGetter.h"
#import "NSKeyValueMethodSetter.h"
#import "NSKeyValueIvarSetter.h"
#import "NSKeyValueUndefinedSetter.h"
#import "NSKeyValueUndefinedGetter.h"
#import "NSKeyValueFastMutableCollection1Getter.h"
#import "NSKeyValueFastMutableCollection2Getter.h"
#import "NSKeyValueIvarMutableCollectionGetter.h"
#import "NSKeyValueSlowMutableCollectionGetter.h"
#import "NSKeyValueNotifyingMutableCollectionGetter.h"
#import "NSKeyValueSet.h"
#import "NSKeyValueArray.h"
#import "NSKeyValueOrderedSet.h"
#import "NSKeyValueNonmutatingArrayMethodSet.h"
#import "NSKeyValueNonmutatingSetMethodSet.h"
#import "NSKeyValueNonmutatingOrderedSetMethodSet.h"
#import "NSKeyValueMutatingSetMethodSet.h"
#import "NSKeyValueMutatingOrderedSetMethodSet.h"
#import "NSKeyValueNotifyingMutableSet.h"
#import "NSKeyValueNotifyingMutableOrderedSet.h"
#import "NSKeyValueFastMutableSet.h"
#import "NSKeyValueIvarMutableSet.h"
#import "NSKeyValueSlowMutableSet.h"
#import "NSKeyValueContainerClass.h"
#import <pthread.h>

CFMutableSetRef NSKeyValueCachedMutableOrderedSetGetters = NULL;
CFMutableSetRef NSKeyValueCachedMutableSetGetters = NULL;

extern CFMutableSetRef NSKeyValueCachedGetters;
extern CFMutableSetRef NSKeyValueCachedSetters;
extern OSSpinLock NSKeyValueCachedAccessorSpinLock;
extern BOOL __UsePedanticKVCNilKeyBehavior_throwOnNil;
extern dispatch_once_t pedanticKVCKeyOnce;

extern void NSKeyValueObservingAssertRegistrationLockNotHeld();

void NSKeyValueCacheAccessLock() {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
}

void NSKeyValueCacheAccessUnlock() {
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
}

id _NSGetUsingKeyValueGetter(id object, NSKeyValueGetter *getter) {
    NSKeyValueObservingAssertRegistrationLockNotHeld();
    switch (getter.extraArgumentCount) {
        case 0: {
            return ( (id (*)(id,SEL))getter.implementation )(object,getter.selector);
        }
            break;
        case 1: {
            return ( (id (*)(id,SEL,void*))getter.implementation )(object,getter.selector, getter.extraArgument1);
        }
            break;
        case 2: {
            return ( (id (*)(id,SEL,void*,void*))getter.implementation )(object,getter.selector, getter.extraArgument1, getter.extraArgument2);
        }
            break;
        case 3: {
            return ( (id (*)(id,SEL,void*,void*,void*))getter.implementation )(object,getter.selector, getter.extraArgument1, getter.extraArgument2, getter.extraArgument3);
        }
            break;
        default:
            break;
    }
    return nil;
}

void _NSSetUsingKeyValueSetter(id object, NSKeyValueSetter *setter, id value) {
    switch (setter.extraArgumentCount) {
        case 0: {
            ( (id (*)(id,SEL,id))setter.implementation )(object,setter.selector,value);
        }
            break;
        case 1: {
            ( (id (*)(id,SEL,id,void*))setter.implementation )(object,setter.selector, value, setter.extraArgument1);
        }
            break;
        case 2: {
            ( (id (*)(id,SEL,id,void*,void*))setter.implementation )(object,setter.selector, value, setter.extraArgument1, setter.extraArgument2);
        }
            break;
        case 3: {
            ( (id (*)(id,SEL,id,void*,void*,void*))setter.implementation )(object,setter.selector, value, setter.extraArgument1, setter.extraArgument2, setter.extraArgument3);
        }
            break;
        default:
            break;
    }
}

Method NSKeyValueMethodForPattern(Class class, const char *pattern,const char *param) {
    size_t param_len = strlen(param);
    size_t pattern_len = strlen(pattern);
    char sel_name[pattern_len + param_len * 2 + 1];
    snprintf(sel_name, (pattern_len + param_len * 2 + 1), pattern,param,param);
    return class_getInstanceMethod(class, sel_registerName(sel_name));
}

Ivar NSKeyValueIvarForPattern(Class class, const char *pattern,const char *param) {
    size_t param_len = strlen(param);
    size_t pattern_len = strlen(pattern);
    char var_name[param_len + pattern_len + 1];
    snprintf(var_name, param_len + pattern_len + 1, pattern,param);
    return class_getInstanceVariable(class, var_name);
}


BOOL _NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key) {
    IMP imp =  class_getMethodImplementation(isa, ISKVOASelector);
    if(imp == (IMP)NSKVOIsAutonotifying) {
        NSKeyValueNotifyingInfo *info = (NSKeyValueNotifyingInfo *)object_getIndexedIvars(isa);
        pthread_mutex_lock(&info->mutex);
        BOOL contains = CFSetContainsValue(info->keys, (CFTypeRef)key);
        pthread_mutex_unlock(&info->mutex);
        return contains;
    }
    return NO;
}


@class NSKeyValueNonmutatingOrderedSetMethodSet;

@implementation NSObject (NSKeyValueCodingPrivate)

+ (NSKeyValueGetter *)_createValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    NSKeyValueGetter * getter = nil;
    
    NSUInteger len = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char key_cstr_upfirst[len + 1];
    [key getCString:key_cstr_upfirst maxLength:len + 1 encoding:NSUTF8StringEncoding];
    if (key.length) {
        key_cstr_upfirst[0] = toupper(key_cstr_upfirst[0]);
    }
    char key_cstr[len + 16];
    [key getCString:key_cstr maxLength:len + 1 encoding:NSUTF8StringEncoding];
    
    Method getMethod = NULL;
    if((getMethod = NSKeyValueMethodForPattern(self,"get%s",key_cstr_upfirst)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"%s",key_cstr)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"is%s",key_cstr_upfirst)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"_get%s",key_cstr_upfirst)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"_%s",key_cstr))) {
        getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:containerClassID key:key method:getMethod];
    }
    else {
        Method ountOf_Method = NSKeyValueMethodForPattern(self, "countOf%", key_cstr_upfirst);
        Method ObjectIn_AtIndexMethod = NSKeyValueMethodForPattern(self, "objectIn%sAtIndex:", key_cstr_upfirst);
        Method _AtIndexesMethod = NSKeyValueMethodForPattern(self, "%sAtIndexes:", key_cstr);
        Method IndexIn_OfObjectMethod = NSKeyValueMethodForPattern(self, "indexIn%sOfObject:", key_cstr_upfirst);
        
        Method enumeratorOf_Method = NSKeyValueMethodForPattern(self, "enumeratorOf%s", key_cstr_upfirst);
        Method memberOf_Method = NSKeyValueMethodForPattern(self, "memberOf%s:", key_cstr_upfirst);
        
        if(ountOf_Method && IndexIn_OfObjectMethod && (ObjectIn_AtIndexMethod || _AtIndexesMethod)) {
            NSKeyValueNonmutatingOrderedSetMethodSet *methodSet = [[NSKeyValueNonmutatingOrderedSetMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.objectAtIndex =  ObjectIn_AtIndexMethod;
            methodSet.indexOfObject =  IndexIn_OfObjectMethod;
            methodSet.objectsAtIndexes =  _AtIndexesMethod;
            methodSet.getObjectsRange =  NSKeyValueMethodForPattern(self, "get%s:range:", key_cstr_upfirst);
            getter = [[NSKeyValueCollectionGetter alloc] initWithContainerClassID:containerClassID key:key  methods:methodSet proxyClass:NSKeyValueOrderedSet.self];
            [methodSet release];
        }
        else if(ountOf_Method && (ObjectIn_AtIndexMethod || _AtIndexesMethod)){
            NSKeyValueNonmutatingArrayMethodSet *methodSet = [[NSKeyValueNonmutatingArrayMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.objectAtIndex =  ObjectIn_AtIndexMethod;
            methodSet.objectsAtIndexes =  _AtIndexesMethod;
            methodSet.getObjectsRange =  NSKeyValueMethodForPattern(self, "get%s:range:", key_cstr_upfirst);
            getter = [[NSKeyValueCollectionGetter alloc] initWithContainerClassID:containerClassID key:key  methods:methodSet proxyClass:NSKeyValueArray.self];
            [methodSet release];
        }
        else if(ountOf_Method && enumeratorOf_Method && memberOf_Method){
            NSKeyValueNonmutatingSetMethodSet *methodSet = [[NSKeyValueNonmutatingSetMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.enumerator =  enumeratorOf_Method;
            methodSet.member =  memberOf_Method;
            getter = [[NSKeyValueCollectionGetter alloc] initWithContainerClassID:containerClassID key:key  methods:methodSet proxyClass:NSKeyValueSet.self];
            [methodSet release];
        }
        else if([self accessInstanceVariablesDirectly]) {
            Ivar ivar = NULL;
            if((ivar = NSKeyValueIvarForPattern(self, "_%s", key_cstr)) ||
               (ivar = NSKeyValueIvarForPattern(self, "_is%s", key_cstr_upfirst)) ||
               (ivar = NSKeyValueIvarForPattern(self, "%s", key_cstr)) ||
               (ivar = NSKeyValueIvarForPattern(self, "is%s", key_cstr_upfirst))
               ) {
                getter = [[NSKeyValueIvarGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
            }
        }
    }
    
    if(!getter) {
        getter = [self _createValuePrimitiveGetterWithContainerClassID:containerClassID key:key];
    }
    
    return getter;
}

+ (NSKeyValueGetter *)_createValuePrimitiveGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    NSKeyValueGetter *getter = nil;
    NSUInteger keyCstrLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCstrUpFirst[keyCstrLen + 1];
    
    [key getCString:keyCstrUpFirst maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    if(key.length) {
        keyCstrUpFirst[0] = toupper(keyCstrUpFirst[0]);
    }
    
    char keyCstr[keyCstrLen + 1];
    [key getCString:keyCstr maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    Method getMethod = NULL;
    if((getMethod = NSKeyValueMethodForPattern(self, "getPrimitive%s", keyCstrUpFirst)) ||
       (getMethod = NSKeyValueMethodForPattern(self, "primitive%s", keyCstrUpFirst))
       ) {
        getter =  [[NSKeyValueMethodGetter alloc] initWithContainerClassID:containerClassID key:key method:getMethod];
    }
    else if([self accessInstanceVariablesDirectly]) {
        Ivar ivar = NULL;
        if ((ivar = NSKeyValueIvarForPattern(self, "_%s", keyCstr)) ||
            (ivar = NSKeyValueIvarForPattern(self, "_is%s", keyCstrUpFirst)) ||
            (ivar = NSKeyValueIvarForPattern(self, "%s", keyCstr)) ||
            (ivar = NSKeyValueIvarForPattern(self, "is%s", keyCstrUpFirst))
            ) {
            getter = [[NSKeyValueIvarGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
        }
    }
    
    if(!getter) {
        getter = [self _createOtherValueGetterWithContainerClassID:containerClassID key:key];
    }
    
    return getter;
}


+ (id)_createOtherValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    return [[NSKeyValueUndefinedGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self];
}


+ (NSKeyValueSetter *)_createValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    
    NSKeyValueSetter *setter = nil;
    
    NSUInteger key_cstr_len = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char key_cstr_upfirst[key_cstr_len + 1];
    [key getCString:key_cstr_upfirst maxLength:key_cstr_len + 1 encoding:NSUTF8StringEncoding];
    if (key.length) {
        key_cstr_upfirst[0] = toupper(key_cstr_upfirst[0]);
    }
    char key_cstr[key_cstr_len + 1];
    [key getCString:key_cstr maxLength:key_cstr_len + 1 encoding:NSUTF8StringEncoding];
    Method method = NULL;
    if ((method = NSKeyValueMethodForPattern(self, "set%s:", key_cstr_upfirst)) ||
        (method = NSKeyValueMethodForPattern(self, "_set%s:", key_cstr_upfirst)) ||
        (method = NSKeyValueMethodForPattern(self, "setIs%s:", key_cstr_upfirst))
        ) {
        setter = [[NSKeyValueMethodSetter alloc] initWithContainerClassID:containerClassID key:key method:method];
    }
    else if ([self accessInstanceVariablesDirectly]) {
        Ivar ivar = NULL;
        if ((ivar = NSKeyValueIvarForPattern(self, "_%s", key_cstr)) ||
            (ivar = NSKeyValueIvarForPattern(self, "_is%s", key_cstr_upfirst)) ||
            (ivar = NSKeyValueIvarForPattern(self, "%s", key_cstr)) ||
            (ivar = NSKeyValueIvarForPattern(self, "is%s", key_cstr_upfirst))
            ) {
            setter = [[NSKeyValueIvarSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
        }
    }
    
    if (!setter) {
        setter = [self _createValuePrimitiveSetterWithContainerClassID:containerClassID key:key];
    }
    
    return setter;
}

+ (NSKeyValueSetter *)_createValuePrimitiveSetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    NSKeyValueSetter *setter = nil;
    NSUInteger keyCstrLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCstrUpFirst[keyCstrLen + 1];
    
    [key getCString:keyCstrUpFirst maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    if(key.length) {
        keyCstrUpFirst[0] = toupper(keyCstrUpFirst[0]);
    }
    
    char keyCstr[keyCstrLen + 1];
    [key getCString:keyCstr maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    Method method = NSKeyValueMethodForPattern(self,"setPrimitive%s:",keyCstrUpFirst);
    if(method) {
        setter = [[NSKeyValueMethodSetter alloc] initWithContainerClassID:containerClassID key:key method:method];
    }
    else {
        if([self accessInstanceVariablesDirectly]) {
            Ivar ivar = NULL;
            if ((ivar = NSKeyValueIvarForPattern(self, "_%s", keyCstr)) ||
                (ivar = NSKeyValueIvarForPattern(self, "_is%s", keyCstrUpFirst)) ||
                (ivar = NSKeyValueIvarForPattern(self, "%s", keyCstr)) ||
                (ivar = NSKeyValueIvarForPattern(self, "is%s", keyCstrUpFirst))
                ) {
                setter = [[NSKeyValueIvarSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
            }
        }
    }
    
    if(!setter) {
        setter = [self _createOtherValueSetterWithContainerClassID:containerClassID key:key];
    }
    
    return setter;
}

+ (NSKeyValueSetter *)_createOtherValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    return [[NSKeyValueUndefinedSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self];
}




+ (NSKeyValueGetter *)_createMutableSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    if(_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(self,key)) {
        Class originClass = _NSKVONotifyingOriginalClassForIsa(self);
        if(!NSKeyValueCachedMutableSetGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)NSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)NSKeyValueAccessorHash
            };
            NSKeyValueCachedMutableSetGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }

        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)originClass;
        
        NSKeyValueAccessor *finder = [NSKeyValueAccessor new];
        finder.containerClassID = originClass;
        finder.key = key;
        finder.hashValue = hashValue;
        
        NSKeyValueGetter *getter = CFSetGetValue(NSKeyValueCachedMutableSetGetters, finder);
        if(!getter) {
            getter = [originClass _createMutableSetValueGetterWithContainerClassID:originClass key:key];
            CFSetAddValue(NSKeyValueCachedMutableSetGetters, getter);
            [getter release];
        }
        return [[NSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key mutableCollectionGetter:getter proxyClass:NSKeyValueNotifyingMutableSet.self];
    }
    else {
        //loc_203A1
        NSUInteger keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char kCstr[keyLength + 1];
        [key getCString:kCstr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
        if(key.length) {
            kCstr[0] = toupper(kCstr[0]);
        }
        
        if(!NSKeyValueCachedGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)NSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)NSKeyValueAccessorHash
            };
            NSKeyValueCachedGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)self;
        
        NSKeyValueAccessor *finder = [NSKeyValueAccessor new];
        finder.containerClassID = self;
        finder.key = key;
        finder.hashValue = hashValue;
        
        NSKeyValueGetter *getter = CFSetGetValue(NSKeyValueCachedGetters, finder);
        if(!getter) {
            getter = [self _createValueGetterWithContainerClassID:self key:key];
            CFSetAddValue(NSKeyValueCachedGetters, getter);
            [getter release];
        }
        
        Method add_ObjectMethod = NSKeyValueMethodForPattern(self, "add%sObject:", kCstr);
        Method remove_Method = NSKeyValueMethodForPattern(self, "remove%s:", kCstr);
        Method remove_ObjectMethod = NSKeyValueMethodForPattern(self, "remove%sObject:", kCstr);
        Method add_Method = NSKeyValueMethodForPattern(self, "add%s:", kCstr);
        
        if((add_ObjectMethod || add_Method) && (remove_Method || remove_ObjectMethod)) {
            NSKeyValueMutatingSetMethodSet *methodSet = [[NSKeyValueMutatingSetMethodSet alloc] init];
            methodSet.addObject = add_ObjectMethod;
            methodSet.intersectSet = NSKeyValueMethodForPattern(self, "intersect%s:", kCstr);
            methodSet.minusSet = remove_Method;
            methodSet.removeObject = remove_ObjectMethod;
            methodSet.setSet = NSKeyValueMethodForPattern(self, "set%s:", kCstr);
            methodSet.unionSet = add_Method;
            
            if([getter isKindOfClass:NSKeyValueCollectionGetter.self]) {
                NSKeyValueFastMutableCollection1Getter *collectionGetter = [[NSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:containerClassID key:key nonmutatingMethods:[(NSKeyValueCollectionGetter *)getter methods] mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableSet1.self];
                [methodSet release];
                return collectionGetter;
            }
            else {
                NSKeyValueFastMutableCollection2Getter *collectionGetter = [[NSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableSet2.self];
                [methodSet release];
                return collectionGetter;
            }
        }
        else {
            if(!NSKeyValueCachedSetters) {
                CFSetCallBacks callbacks = {
                    kCFTypeSetCallBacks.version,
                    kCFTypeSetCallBacks.retain,
                    kCFTypeSetCallBacks.release,
                    kCFTypeSetCallBacks.copyDescription,
                    (CFSetEqualCallBack)NSKeyValueAccessorIsEqual,
                    (CFSetHashCallBack)NSKeyValueAccessorHash
                };
                NSKeyValueCachedSetters = CFSetCreateMutable(NULL, 0, &callbacks);
            }
            
            NSUInteger hashValue = 0;
            if(key) {
                hashValue  = CFHash(key);
            }
            hashValue ^= (NSUInteger)self;
            
            NSKeyValueAccessor *finder = [NSKeyValueAccessor new];
            finder.containerClassID = self;
            finder.key = key;
            finder.hashValue = hashValue;
            
            NSKeyValueSetter *setter = CFSetGetValue(NSKeyValueCachedSetters, finder);
            if(!setter) {
                setter = [self _createValueSetterWithContainerClassID:self key:key];
                CFSetAddValue(NSKeyValueCachedSetters, setter);
                [setter release];
            }
            
            if([setter isKindOfClass:NSKeyValueIvarSetter.self]) {
                NSKeyValueIvarMutableCollectionGetter *collectionGetter = [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:[(NSKeyValueIvarSetter *)setter ivar] proxyClass:NSKeyValueIvarMutableSet.self];
                return collectionGetter;
            }
            else {
                NSKeyValueSlowMutableCollectionGetter *collectionGetter = [[NSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter baseSetter:setter containerIsa:self proxyClass:NSKeyValueSlowMutableSet.self];
                return collectionGetter;
            }

        }
    }
}


+ (NSKeyValueGetter *)_createMutableOrderedSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    if(_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(self,key)) {
        Class originClass = _NSKVONotifyingOriginalClassForIsa(self);
        if(!NSKeyValueCachedMutableOrderedSetGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)NSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)NSKeyValueAccessorHash
            };
            NSKeyValueCachedMutableOrderedSetGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)originClass;
        
        NSKeyValueAccessor *finder = [NSKeyValueAccessor new];
        finder.containerClassID = originClass;
        finder.key = key;
        finder.hashValue = hashValue;
        
        NSKeyValueGetter *getter = CFSetGetValue(NSKeyValueCachedMutableOrderedSetGetters, finder);
        if(!getter) {
            getter = [originClass _createMutableOrderedValueGetterWithContainerClassID:originClass key:key];
            CFSetAddValue(NSKeyValueCachedMutableOrderedSetGetters, getter);
            [getter release];
        }
        return [[NSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key mutableCollectionGetter:getter proxyClass:NSKeyValueNotifyingMutableOrderedSet.self];
    }
    else {
        //loc_203A1
        NSUInteger keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char kCstr[keyLength + 1];
        [key getCString:kCstr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
        if(key.length) {
            kCstr[0] = toupper(kCstr[0]);
        }
        
        if(!NSKeyValueCachedGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)NSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)NSKeyValueAccessorHash
            };
            NSKeyValueCachedGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)self;
        
        NSKeyValueAccessor *finder = [NSKeyValueAccessor new];
        finder.containerClassID = self;
        finder.key = key;
        finder.hashValue = hashValue;
        
        NSKeyValueGetter *getter = CFSetGetValue(NSKeyValueCachedGetters, finder);
        if(!getter) {
            getter = [self _createValueGetterWithContainerClassID:self key:key];
            CFSetAddValue(NSKeyValueCachedGetters, getter);
            [getter release];
        }
        
        Method insertObject_InAtIndex_Method = NSKeyValueMethodForPattern(self, "insertObject:in%sAtIndex:", kCstr);
        Method insert_AtIndexes_Method = NSKeyValueMethodForPattern(self, "insert%s:atIndexes:", kCstr);
        Method removeObjectFrom_AtIndex_Method = NSKeyValueMethodForPattern(self, "removeObjectFrom%sAtIndex:", kCstr);
        Method removeAtIndexes_Method = NSKeyValueMethodForPattern(self, "remove%sAtIndexes:", kCstr);
        
        if((insertObject_InAtIndex_Method || insert_AtIndexes_Method) && (removeObjectFrom_AtIndex_Method || removeAtIndexes_Method)) {
            NSKeyValueMutatingOrderedSetMethodSet *methodSet = [[NSKeyValueMutatingOrderedSetMethodSet alloc] init];
            methodSet.insertObjectAtIndex = insertObject_InAtIndex_Method;
            methodSet.insertObjectsAtIndexes = insert_AtIndexes_Method;
            methodSet.removeObjectAtIndex = removeObjectFrom_AtIndex_Method;
            methodSet.removeObjectsAtIndexes = removeAtIndexes_Method;
            methodSet.replaceObjectAtIndex = NSKeyValueMethodForPattern(self, "replaceObjectIn%sAtIndex:withObject:", kCstr);
            methodSet.replaceObjectsAtIndexes = NSKeyValueMethodForPattern(self, "replace%sAtIndexes:with%s:", kCstr);;
            
            if([getter isKindOfClass:NSKeyValueCollectionGetter.self]) {
                NSKeyValueFastMutableCollection1Getter *collectionGetter = [[NSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:containerClassID key:key nonmutatingMethods:[(NSKeyValueCollectionGetter *)getter methods] mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableSet1.self];
                [methodSet release];
                return collectionGetter;
            }
            else {
                NSKeyValueFastMutableCollection2Getter *collectionGetter = [[NSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableSet2.self];
                [methodSet release];
                return collectionGetter;
            }
        }
        else {
            if(!NSKeyValueCachedSetters) {
                CFSetCallBacks callbacks = {
                    kCFTypeSetCallBacks.version,
                    kCFTypeSetCallBacks.retain,
                    kCFTypeSetCallBacks.release,
                    kCFTypeSetCallBacks.copyDescription,
                    (CFSetEqualCallBack)NSKeyValueAccessorIsEqual,
                    (CFSetHashCallBack)NSKeyValueAccessorHash
                };
                NSKeyValueCachedSetters = CFSetCreateMutable(NULL, 0, &callbacks);
            }
            
            NSUInteger hashValue = 0;
            if(key) {
                hashValue  = CFHash(key);
            }
            hashValue ^= (NSUInteger)self;
            
            NSKeyValueAccessor *finder = [NSKeyValueAccessor new];
            finder.containerClassID = self;
            finder.key = key;
            finder.hashValue = hashValue;
            
            NSKeyValueSetter *setter = CFSetGetValue(NSKeyValueCachedSetters, finder);
            if(!setter) {
                setter = [self _createValueSetterWithContainerClassID:self key:key];
                CFSetAddValue(NSKeyValueCachedSetters, setter);
                [setter release];
            }
            
            if([setter isKindOfClass:NSKeyValueIvarSetter.self]) {
                NSKeyValueIvarMutableCollectionGetter *collectionGetter = [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:[(NSKeyValueIvarSetter *)setter ivar] proxyClass:NSKeyValueIvarMutableSet.self];
                return collectionGetter;
            }
            else {
                NSKeyValueSlowMutableCollectionGetter *collectionGetter = [[NSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter baseSetter:setter containerIsa:self proxyClass:NSKeyValueSlowMutableSet.self];
                return collectionGetter;
            }
            
        }
    }
}

@end


