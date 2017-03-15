//
//  NSobject.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/5.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSobject+NSKeyValueCodingPrivate.h"
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
#import "NSKeyValueSlowMutableArray.h"
#import "NSKeyValueIvarMutableArray.h"
#import "NSKeyValueFastMutableArray.h"
#import "NSKeyValueMutatingArrayMethodSet.h"
#import "NSKeyValueNotifyingMutableArray.h"
#import "NSKeyValueFastMutableOrderedSet.h"
#import "NSKeyValueIvarMutableOrderedSet.h"
#import "NSKeyValueSlowMutableOrderedSet.h"
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
#import <os/lock.h>
#import <objc/runtime.h>

CFMutableSetRef NSKeyValueCachedMutableArrayGetters = NULL;
CFMutableSetRef NSKeyValueCachedMutableOrderedSetGetters = NULL;
CFMutableSetRef NSKeyValueCachedMutableSetGetters = NULL;
CFMutableSetRef NSKeyValueCachedPrimitiveSetters = NULL;
CFMutableSetRef NSKeyValueCachedPrimitiveGetters = NULL;



extern OSSpinLock NSKeyValueCachedAccessorSpinLock;
extern BOOL __UsePedanticKVCNilKeyBehavior_throwOnNil;
extern dispatch_once_t pedanticKVCKeyOnce;

extern void NSKeyValueObservingAssertRegistrationLockNotHeld();

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
    size_t paramLen = strlen(param);
    size_t patternLen = strlen(pattern);
    char selName[patternLen + paramLen * 2 + 1];
    snprintf(selName, (patternLen + paramLen * 2 + 1), pattern,param,param);
    return class_getInstanceMethod(class, sel_registerName(selName));
}

Ivar NSKeyValueIvarForPattern(Class class, const char *pattern,const char *param) {
    size_t paramLen = strlen(param);
    size_t patternLen = strlen(pattern);
    char ivarName[paramLen + patternLen + 1];
    snprintf(ivarName, paramLen + patternLen + 1, pattern,param);
    return class_getInstanceVariable(class, ivarName);
}


NSKeyValueSetter * _NSKeyValueSetterForClassAndKey(Class containerClassID, NSString *key, Class class){
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!NSKeyValueCachedSetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedSetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueSetter *setter =  CFSetGetValue(NSKeyValueCachedSetters, finder);
    if (!setter) {
        setter = [class _createValueSetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedSetters, setter);
        [setter release];
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return setter;
}

NSKeyValueGetter * _NSKeyValueGetterForClassAndKey(Class containerClassID, NSString *key, Class class){
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!NSKeyValueCachedGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedGetters, finder);
    if (!getter) {
        getter = [class _createValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return getter;
}

NSKeyValueSetter * _NSKeyValuePrimitiveSetterForClassAndKey(Class containerClassID, NSString *key, Class class) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!NSKeyValueCachedPrimitiveSetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedPrimitiveSetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueSetter *setter =  CFSetGetValue(NSKeyValueCachedPrimitiveSetters, finder);
    if (!setter) {
        setter = [class _createValuePrimitiveSetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedPrimitiveSetters, setter);
        [setter release];
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return setter;
}

NSKeyValueGetter * _NSKeyValuePrimitiveGetterForClassAndKey(Class containerClassID, NSString *key, Class class) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!NSKeyValueCachedPrimitiveGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedPrimitiveGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedPrimitiveGetters, finder);
    if (!getter) {
        getter = [class _createValuePrimitiveGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedPrimitiveGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return getter;
}


NSKeyValueGetter * _NSKeyValueMutableSetGetterForClassAndKey(Class containerClassID, NSString *key, Class class) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!NSKeyValueCachedMutableSetGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedMutableSetGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedMutableSetGetters, finder);
    if (!getter) {
        getter = [class _createMutableSetValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedMutableSetGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return getter;
}

NSKeyValueGetter * _NSKeyValueMutableOrderedSetGetterForIsaAndKey(Class containerClassID, NSString *key) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!NSKeyValueCachedMutableOrderedSetGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedMutableOrderedSetGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedMutableOrderedSetGetters, finder);
    if (!getter) {
        getter = [containerClassID _createMutableOrderedSetValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedMutableOrderedSetGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return getter;
}

NSKeyValueGetter * _NSKeyValueMutableArrayGetterForIsaAndKey(Class containerClassID, NSString *key) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if(!NSKeyValueCachedMutableArrayGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedMutableArrayGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedMutableArrayGetters, finder);
    if (!getter) {
        getter = [containerClassID _createMutableArrayValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedMutableArrayGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return getter;
}

void _NSKeyValueInvalidateCachedMutatorsForIsaAndKey(Class isa, NSString *key) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    NSUInteger hashValue = 0;
    if(key) {
        hashValue = CFHash(key);
    }
    hashValue ^= (NSUInteger)isa;
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = isa;
    finder.key = key;
    finder.hashValue = hashValue;
    
    if(NSKeyValueCachedSetters) {
        id find = CFSetGetValue(NSKeyValueCachedSetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedSetters, find);
        }
    }
    if(NSKeyValueCachedMutableArrayGetters) {
        id find = CFSetGetValue(NSKeyValueCachedMutableArrayGetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedMutableArrayGetters, find);
        }
    }
    if(NSKeyValueCachedMutableOrderedSetGetters) {
        id find = CFSetGetValue(NSKeyValueCachedMutableOrderedSetGetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedMutableOrderedSetGetters, find);
        }
    }
    if(NSKeyValueCachedMutableSetGetters) {
        id find = CFSetGetValue(NSKeyValueCachedMutableSetGetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedMutableSetGetters, find);
        }
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
}


void _NSKeyValueInvalidateAllCachesForContainerAndKey(Class containerClassID, NSString *key) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    NSUInteger hashValue = 0;
    if(key) {
        hashValue = CFHash(key);
    }
    hashValue ^= (NSUInteger)containerClassID;
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = hashValue;
    
    CFMutableSetRef accessorCaches[] = {
        NSKeyValueCachedGetters,
        NSKeyValueCachedSetters,
        NSKeyValueCachedMutableArrayGetters,
        NSKeyValueCachedMutableOrderedSetGetters,
        NSKeyValueCachedMutableSetGetters,
        NSKeyValueCachedPrimitiveGetters,
        NSKeyValueCachedPrimitiveSetters
    };
    
    for (NSUInteger i = 0; i < sizeof(accessorCaches)/sizeof(accessorCaches[0]); ++i) {
        if (accessorCaches[i]) {
            CFSetRemoveValue(accessorCaches[i], finder);
        }
    }
    
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
}

@implementation NSObject (NSKeyValueCodingPrivate)

+ (NSKeyValueGetter *)_createValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    NSKeyValueGetter * getter = nil;
    
    NSUInteger keyLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCStrUpFirst[keyLen + 1];
    [key getCString:keyCStrUpFirst maxLength:keyLen + 1 encoding:NSUTF8StringEncoding];
    if (key.length) {
        keyCStrUpFirst[0] = toupper(keyCStrUpFirst[0]);
    }
    char keyCStr[keyLen + 16];
    [key getCString:keyCStr maxLength:keyLen + 1 encoding:NSUTF8StringEncoding];
    
    Method getMethod = NULL;
    if((getMethod = NSKeyValueMethodForPattern(self,"get%s",keyCStrUpFirst)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"%s",keyCStr)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"is%s",keyCStrUpFirst)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"_get%s",keyCStrUpFirst)) ||
       (getMethod = NSKeyValueMethodForPattern(self,"_%s",keyCStr))) {
        getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:containerClassID key:key method:getMethod];
    }
    else {
        Method ountOf_Method = NSKeyValueMethodForPattern(self, "countOf%", keyCStrUpFirst);
        Method ObjectIn_AtIndexMethod = NSKeyValueMethodForPattern(self, "objectIn%sAtIndex:", keyCStrUpFirst);
        Method _AtIndexesMethod = NSKeyValueMethodForPattern(self, "%sAtIndexes:", keyCStr);
        Method IndexIn_OfObjectMethod = NSKeyValueMethodForPattern(self, "indexIn%sOfObject:", keyCStrUpFirst);
        
        Method enumeratorOf_Method = NSKeyValueMethodForPattern(self, "enumeratorOf%s", keyCStrUpFirst);
        Method memberOf_Method = NSKeyValueMethodForPattern(self, "memberOf%s:", keyCStrUpFirst);
        
        if(ountOf_Method && IndexIn_OfObjectMethod && (ObjectIn_AtIndexMethod || _AtIndexesMethod)) {
            NSKeyValueNonmutatingOrderedSetMethodSet *methodSet = [[NSKeyValueNonmutatingOrderedSetMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.objectAtIndex =  ObjectIn_AtIndexMethod;
            methodSet.indexOfObject =  IndexIn_OfObjectMethod;
            methodSet.objectsAtIndexes =  _AtIndexesMethod;
            methodSet.getObjectsRange =  NSKeyValueMethodForPattern(self, "get%s:range:", keyCStrUpFirst);
            getter = [[NSKeyValueCollectionGetter alloc] initWithContainerClassID:containerClassID key:key  methods:methodSet proxyClass:NSKeyValueOrderedSet.self];
            [methodSet release];
        }
        else if(ountOf_Method && (ObjectIn_AtIndexMethod || _AtIndexesMethod)){
            NSKeyValueNonmutatingArrayMethodSet *methodSet = [[NSKeyValueNonmutatingArrayMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.objectAtIndex =  ObjectIn_AtIndexMethod;
            methodSet.objectsAtIndexes =  _AtIndexesMethod;
            methodSet.getObjectsRange =  NSKeyValueMethodForPattern(self, "get%s:range:", keyCStrUpFirst);
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
            if((ivar = NSKeyValueIvarForPattern(self, "_%s", keyCStr)) ||
               (ivar = NSKeyValueIvarForPattern(self, "_is%s", keyCStrUpFirst)) ||
               (ivar = NSKeyValueIvarForPattern(self, "%s", keyCStr)) ||
               (ivar = NSKeyValueIvarForPattern(self, "is%s", keyCStrUpFirst))
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


+ (NSKeyValueGetter *)_createMutableArrayValueGetterWithContainerClassID:(Class)containerClassID key:(NSString *)key {
    if(_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(self, key)) {
        Class originalClass = _NSKVONotifyingOriginalClassForIsa(self);
        if(!NSKeyValueCachedMutableArrayGetters) {
            CFSetCallBacks callbacks = {0};
            callbacks.version = kCFTypeSetCallBacks.version;
            callbacks.retain = kCFTypeSetCallBacks.retain;
            callbacks.release = kCFTypeSetCallBacks.release;
            callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
            callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
            callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
            NSKeyValueCachedMutableArrayGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        NSUInteger hashValue = 0;
        if(key) {
            hashValue = CFHash((CFTypeRef)key);
        }
        hashValue ^= (NSUInteger)originalClass;
        
        NSKeyValueGetter *finder = [NSKeyValueGetter new];
        finder.containerClassID = originalClass;
        finder.key = key;
        finder.hashValue = hashValue;
        
        NSKeyValueGetter *getter = CFSetGetValue(NSKeyValueCachedMutableArrayGetters, finder);
        if(!getter) {
            getter = [originalClass _createMutableArrayValueGetterWithContainerClassID:originalClass key:key];
            CFSetAddValue(NSKeyValueCachedMutableArrayGetters, getter);
            [getter release];
        }
        
        return [[NSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key mutableCollectionGetter:getter proxyClass:NSKeyValueNotifyingMutableArray.self];
    }
    else {
        NSUInteger keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char keyCStr[keyLength + 1];
        [key getCString:keyCStr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
        if(key.length) {
            keyCStr[0] = toupper(keyCStr[0]);
        }
        if(!NSKeyValueCachedGetters) {
            CFSetCallBacks callbacks = {0};
            callbacks.version = kCFTypeSetCallBacks.version;
            callbacks.retain = kCFTypeSetCallBacks.retain;
            callbacks.release = kCFTypeSetCallBacks.release;
            callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
            callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
            callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
            NSKeyValueCachedGetters = CFSetCreateMutable(NULL,0,&callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue = CFHash(key);
        }
        hashValue ^= (NSUInteger)self;
        
        NSKeyValueGetter *finder = [NSKeyValueGetter new];
        finder.containerClassID = self;
        finder.key = key;
        finder.hashValue = hashValue;
        
        NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedGetters,finder);
        if(!getter) {
            getter = [self _createValueGetterWithContainerClassID:self key:key];
            CFSetAddValue(NSKeyValueCachedGetters, getter);
            [getter release];
        }
        
        Method insertObjectAtIndexMethod = NSKeyValueMethodForPattern(self,"insertObject:in%sAtIndex:", keyCStr);
        Method insertObjectsAtIndexesMethod = NSKeyValueMethodForPattern(self,"insert%s:atIndexes:", keyCStr);
        Method removeObjectAtIndexMethod = NSKeyValueMethodForPattern(self,"removeObjectFrom%sAtIndex:", keyCStr);
        Method removeObjectsAtIndexesMethod = NSKeyValueMethodForPattern(self,"remove%sAtIndexes:", keyCStr);
        
        if((!insertObjectAtIndexMethod && !insertObjectsAtIndexesMethod) || (!removeObjectAtIndexMethod && !removeObjectsAtIndexesMethod)) {
            if(!NSKeyValueCachedSetters) {
                CFSetCallBacks callbacks = {0};
                callbacks.version = kCFTypeSetCallBacks.version;
                callbacks.retain = kCFTypeSetCallBacks.retain;
                callbacks.release = kCFTypeSetCallBacks.release;
                callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
                callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
                callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
                NSKeyValueCachedSetters = CFSetCreateMutable(NULL,0,&callbacks);
            }
            NSKeyValueSetter *finder = [NSKeyValueSetter new];
            finder.containerClassID = self.class;
            finder.key = key;
            finder.hashValue = CFHash((CFTypeRef)key) ^ (NSUInteger)(self);
            NSKeyValueSetter *setter =  CFSetGetValue(NSKeyValueCachedSetters, finder);
            if (!setter) {
                setter = [self.class _createValueSetterWithContainerClassID:self.class key:key];
                CFSetAddValue(NSKeyValueCachedSetters, setter);
                [setter release];
            }
            if([setter isKindOfClass:NSKeyValueIvarSetter.self]) {
                return [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:((NSKeyValueIvarSetter *)setter).ivar proxyClass:NSKeyValueIvarMutableArray.self];
            }
            else {
                return [[NSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter baseSetter:setter containerIsa:self proxyClass:NSKeyValueSlowMutableArray.self];
            }
        }
        else {
            NSKeyValueMutatingArrayMethodSet *methodSet = [[NSKeyValueMutatingArrayMethodSet alloc] init];
            methodSet.insertObjectAtIndex = insertObjectAtIndexMethod;
            methodSet.insertObjectsAtIndexes = insertObjectsAtIndexesMethod;
            methodSet.removeObjectAtIndex = removeObjectAtIndexMethod;
            methodSet.removeObjectsAtIndexes = removeObjectsAtIndexesMethod;
            methodSet.replaceObjectAtIndex = NSKeyValueMethodForPattern(self,"replaceObjectIn%sAtIndex:withObject:", keyCStr);
            methodSet.replaceObjectsAtIndexes = NSKeyValueMethodForPattern(self,"replace%sAtIndexes:with%s:", keyCStr);
            
            if([getter isKindOfClass:NSKeyValueCollectionGetter.self]) {
                NSKeyValueFastMutableCollection1Getter * collection1Getter = [[NSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:containerClassID key:key nonmutatingMethods:((NSKeyValueCollectionGetter *)getter).methods mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableArray1.self];
                [methodSet release];
                return collection1Getter;
            }
            else {
                NSKeyValueFastMutableCollection2Getter *collection2Getter = [[NSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableArray2.self];
                [methodSet release];
                return collection2Getter;
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
                NSKeyValueFastMutableCollection1Getter *collectionGetter = [[NSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:containerClassID key:key nonmutatingMethods:[(NSKeyValueCollectionGetter *)getter methods] mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableOrderedSet1.self];
                [methodSet release];
                return collectionGetter;
            }
            else {
                NSKeyValueFastMutableCollection2Getter *collectionGetter = [[NSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter mutatingMethods:methodSet proxyClass:NSKeyValueFastMutableOrderedSet2.self];
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
                NSKeyValueIvarMutableCollectionGetter *collectionGetter = [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:[(NSKeyValueIvarSetter *)setter ivar] proxyClass:NSKeyValueIvarMutableOrderedSet.self];
                return collectionGetter;
            }
            else {
                NSKeyValueSlowMutableCollectionGetter *collectionGetter = [[NSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter baseSetter:setter containerIsa:self proxyClass:NSKeyValueSlowMutableOrderedSet.self];
                return collectionGetter;
            }
            
        }
    }
}

@end


