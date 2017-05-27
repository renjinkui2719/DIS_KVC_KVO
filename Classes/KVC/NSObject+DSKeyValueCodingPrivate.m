//
//  NSobject.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/5.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSobject+DSKeyValueCodingPrivate.h"
#import "DSKeyValueCollectionGetter.h"
#import "DSKeyValueMethodGetter.h"
#import "DSKeyValueIvarGetter.h"
#import "DSKeyValueMethodSetter.h"
#import "DSKeyValueIvarSetter.h"
#import "DSKeyValueUndefinedSetter.h"
#import "DSKeyValueUndefinedGetter.h"
#import "DSKeyValueFastMutableCollection1Getter.h"
#import "DSKeyValueFastMutableCollection2Getter.h"
#import "DSKeyValueIvarMutableCollectionGetter.h"
#import "DSKeyValueSlowMutableCollectionGetter.h"
#import "DSKeyValueNotifyingMutableCollectionGetter.h"
#import "DSKeyValueSet.h"
#import "DSKeyValueArray.h"
#import "DSKeyValueOrderedSet.h"
#import "DSKeyValueSlowMutableArray.h"
#import "DSKeyValueIvarMutableArray.h"
#import "DSKeyValueFastMutableArray.h"
#import "DSKeyValueMutatingArrayMethodSet.h"
#import "DSKeyValueNotifyingMutableArray.h"
#import "DSKeyValueFastMutableOrderedSet.h"
#import "DSKeyValueIvarMutableOrderedSet.h"
#import "DSKeyValueSlowMutableOrderedSet.h"
#import "DSKeyValueNonmutatingArrayMethodSet.h"
#import "DSKeyValueNonmutatingSetMethodSet.h"
#import "DSKeyValueNonmutatingOrderedSetMethodSet.h"
#import "DSKeyValueMutatingSetMethodSet.h"
#import "DSKeyValueMutatingOrderedSetMethodSet.h"
#import "DSKeyValueNotifyingMutableSet.h"
#import "DSKeyValueNotifyingMutableOrderedSet.h"
#import "DSKeyValueFastMutableSet.h"
#import "DSKeyValueIvarMutableSet.h"
#import "DSKeyValueSlowMutableSet.h"
#import "DSKeyValueContainerClass.h"
#import "DSKeyValueCodingCommon.h"


CFMutableSetRef DSKeyValueCachedGetters = NULL;
CFMutableSetRef DSKeyValueCachedSetters = NULL;

CFMutableSetRef DSKeyValueCachedMutableArrayGetters = NULL;
CFMutableSetRef DSKeyValueCachedMutableOrderedSetGetters = NULL;
CFMutableSetRef DSKeyValueCachedMutableSetGetters = NULL;

CFMutableSetRef DSKeyValueCachedPrimitiveSetters = NULL;
CFMutableSetRef DSKeyValueCachedPrimitiveGetters = NULL;

OSSpinLock DSKeyValueCachedAccessorSpinLock = OS_SPINLOCK_INIT;

extern void DSKeyValueObservingAssertRegistrationLockNotHeld();

id _DSGetUsingKeyValueGetter(id object, DSKeyValueGetter *getter) {
    DSKeyValueObservingAssertRegistrationLockNotHeld();
    
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

void _DSSetUsingKeyValueSetter(id object, DSKeyValueSetter *setter, id value) {
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

Method DSKeyValueMethodForPattern(Class class, const char *pattern,const char *param) {
    size_t paramLen = strlen(param);
    size_t patternLen = strlen(pattern);
    char selName[patternLen + paramLen * 2 + 1];
    snprintf(selName, (patternLen + paramLen * 2 + 1), pattern,param,param);
    return class_getInstanceMethod(class, sel_registerName(selName));
}

Ivar DSKeyValueIvarForPattern(Class class, const char *pattern,const char *param) {
    size_t paramLen = strlen(param);
    size_t patternLen = strlen(pattern);
    char ivarName[paramLen + patternLen + 1];
    snprintf(ivarName, paramLen + patternLen + 1, pattern,param);
    return class_getInstanceVariable(class, ivarName);
}


DSKeyValueSetter * _DSKeyValueSetterForClassAndKey(Class containerClassID, NSString *key, Class class){
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if (!DSKeyValueCachedSetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        DSKeyValueCachedSetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    DSKeyValueSetter *setter =  CFSetGetValue(DSKeyValueCachedSetters, finder);
    if (!setter) {
        setter = [class _d_createValueSetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(DSKeyValueCachedSetters, setter);
        [setter release];
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    return setter;
}

DSKeyValueGetter * _DSKeyValueGetterForClassAndKey(Class containerClassID, NSString *key, Class class){
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if (!DSKeyValueCachedGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        DSKeyValueCachedGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    DSKeyValueGetter *getter =  CFSetGetValue(DSKeyValueCachedGetters, finder);
    if (!getter) {
        getter = [class _d_createValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(DSKeyValueCachedGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    return getter;
}

DSKeyValueSetter * _DSKeyValuePrimitiveSetterForClassAndKey(Class containerClassID, NSString *key, Class class) {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if (!DSKeyValueCachedPrimitiveSetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        DSKeyValueCachedPrimitiveSetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    DSKeyValueSetter *setter =  CFSetGetValue(DSKeyValueCachedPrimitiveSetters, finder);
    if (!setter) {
        setter = [class _d_createValuePrimitiveSetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(DSKeyValueCachedPrimitiveSetters, setter);
        [setter release];
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    return setter;
}

DSKeyValueGetter * _DSKeyValuePrimitiveGetterForClassAndKey(Class containerClassID, NSString *key, Class class) {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if (!DSKeyValueCachedPrimitiveGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        DSKeyValueCachedPrimitiveGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    DSKeyValueGetter *getter =  CFSetGetValue(DSKeyValueCachedPrimitiveGetters, finder);
    if (!getter) {
        getter = [class _d_createValuePrimitiveGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(DSKeyValueCachedPrimitiveGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    return getter;
}

DSKeyValueGetter * _DSKeyValueMutableArrayGetterForIsaAndKey(Class containerClassID, NSString *key) {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if(!DSKeyValueCachedMutableArrayGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        DSKeyValueCachedMutableArrayGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    DSKeyValueGetter *getter =  CFSetGetValue(DSKeyValueCachedMutableArrayGetters, finder);
    if (!getter) {
        getter = [containerClassID _d_createMutableArrayValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(DSKeyValueCachedMutableArrayGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    return getter;
}


DSKeyValueGetter * _DSKeyValueMutableSetGetterForClassAndKey(Class containerClassID, NSString *key, Class class) {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if (!DSKeyValueCachedMutableSetGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        DSKeyValueCachedMutableSetGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    DSKeyValueGetter *getter =  CFSetGetValue(DSKeyValueCachedMutableSetGetters, finder);
    if (!getter) {
        getter = [class _d_createMutableSetValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(DSKeyValueCachedMutableSetGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    return getter;
}

DSKeyValueGetter * _DSKeyValueMutableOrderedSetGetterForIsaAndKey(Class containerClassID, NSString *key) {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if (!DSKeyValueCachedMutableOrderedSetGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        DSKeyValueCachedMutableOrderedSetGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash(key) : 0) ^ (NSUInteger)containerClassID;
    DSKeyValueGetter *getter =  CFSetGetValue(DSKeyValueCachedMutableOrderedSetGetters, finder);
    if (!getter) {
        getter = [containerClassID _d_createMutableOrderedSetValueGetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(DSKeyValueCachedMutableOrderedSetGetters, getter);
        [getter release];
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    return getter;
}

void _DSKeyValueInvalidateCachedMutatorsForIsaAndKey(Class isa, NSString *key) {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    NSUInteger hashValue = 0;
    if(key) {
        hashValue = CFHash(key);
    }
    hashValue ^= (NSUInteger)isa;
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = isa;
    finder.key = key;
    finder.hashValue = hashValue;
    
    if(DSKeyValueCachedSetters) {
        id find = CFSetGetValue(DSKeyValueCachedSetters, finder);
        if(find) {
            CFSetRemoveValue(DSKeyValueCachedSetters, find);
        }
    }
    if(DSKeyValueCachedMutableArrayGetters) {
        id find = CFSetGetValue(DSKeyValueCachedMutableArrayGetters, finder);
        if(find) {
            CFSetRemoveValue(DSKeyValueCachedMutableArrayGetters, find);
        }
    }
    if(DSKeyValueCachedMutableOrderedSetGetters) {
        id find = CFSetGetValue(DSKeyValueCachedMutableOrderedSetGetters, finder);
        if(find) {
            CFSetRemoveValue(DSKeyValueCachedMutableOrderedSetGetters, find);
        }
    }
    if(DSKeyValueCachedMutableSetGetters) {
        id find = CFSetGetValue(DSKeyValueCachedMutableSetGetters, finder);
        if(find) {
            CFSetRemoveValue(DSKeyValueCachedMutableSetGetters, find);
        }
    }
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
}


void _DSKeyValueInvalidateAllCachesForContainerAndKey(Class containerClassID, NSString *key) {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    NSUInteger hashValue = 0;
    if(key) {
        hashValue = CFHash(key);
    }
    hashValue ^= (NSUInteger)containerClassID;
    
    DSKeyValueSetter *finder = [DSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = hashValue;
    
    CFMutableSetRef accessorCaches[] = {
        DSKeyValueCachedGetters,
        DSKeyValueCachedSetters,
        DSKeyValueCachedMutableArrayGetters,
        DSKeyValueCachedMutableOrderedSetGetters,
        DSKeyValueCachedMutableSetGetters,
        DSKeyValueCachedPrimitiveGetters,
        DSKeyValueCachedPrimitiveSetters
    };
    
    for (NSUInteger i = 0; i < sizeof(accessorCaches)/sizeof(accessorCaches[0]); ++i) {
        if (accessorCaches[i]) {
            CFSetRemoveValue(accessorCaches[i], finder);
        }
    }
    
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
}



@implementation NSObject (DSKeyValueCodingPrivate)

+ (DSKeyValueGetter *)_d_createValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    DSKeyValueGetter * getter = nil;
    
    NSUInteger keyLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCStrUpFirst[keyLen + 1];
    [key getCString:keyCStrUpFirst maxLength:keyLen + 1 encoding:NSUTF8StringEncoding];
    if (key.length) {
        keyCStrUpFirst[0] = toupper(keyCStrUpFirst[0]);
    }
    char keyCStr[keyLen + 16];
    [key getCString:keyCStr maxLength:keyLen + 1 encoding:NSUTF8StringEncoding];
    
    Method getMethod = NULL;
    if((getMethod = DSKeyValueMethodForPattern(self,"get%s",keyCStrUpFirst)) ||
       (getMethod = DSKeyValueMethodForPattern(self,"%s",keyCStr)) ||
       (getMethod = DSKeyValueMethodForPattern(self,"is%s",keyCStrUpFirst)) ||
       (getMethod = DSKeyValueMethodForPattern(self,"_get%s",keyCStrUpFirst)) ||
       (getMethod = DSKeyValueMethodForPattern(self,"_%s",keyCStr))) {
        getter = [[DSKeyValueMethodGetter alloc] initWithContainerClassID:containerClassID key:key method:getMethod];
    }
    else {
        Method ountOf_Method = DSKeyValueMethodForPattern(self, "countOf%", keyCStrUpFirst);
        Method ObjectIn_AtIndexMethod = DSKeyValueMethodForPattern(self, "objectIn%sAtIndex:", keyCStrUpFirst);
        Method _AtIndexesMethod = DSKeyValueMethodForPattern(self, "%sAtIndexes:", keyCStr);
        Method IndexIn_OfObjectMethod = DSKeyValueMethodForPattern(self, "indexIn%sOfObject:", keyCStrUpFirst);
        
        Method enumeratorOf_Method = DSKeyValueMethodForPattern(self, "enumeratorOf%s", keyCStrUpFirst);
        Method memberOf_Method = DSKeyValueMethodForPattern(self, "memberOf%s:", keyCStrUpFirst);
        
        if(ountOf_Method && IndexIn_OfObjectMethod && (ObjectIn_AtIndexMethod || _AtIndexesMethod)) {
            DSKeyValueNonmutatingOrderedSetMethodSet *methodSet = [[DSKeyValueNonmutatingOrderedSetMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.objectAtIndex =  ObjectIn_AtIndexMethod;
            methodSet.indexOfObject =  IndexIn_OfObjectMethod;
            methodSet.objectsAtIndexes =  _AtIndexesMethod;
            methodSet.getObjectsRange =  DSKeyValueMethodForPattern(self, "get%s:range:", keyCStrUpFirst);
            getter = [[DSKeyValueCollectionGetter alloc] initWithContainerClassID:containerClassID key:key  methods:methodSet proxyClass:DSKeyValueOrderedSet.self];
            [methodSet release];
        }
        else if(ountOf_Method && (ObjectIn_AtIndexMethod || _AtIndexesMethod)){
            DSKeyValueNonmutatingArrayMethodSet *methodSet = [[DSKeyValueNonmutatingArrayMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.objectAtIndex =  ObjectIn_AtIndexMethod;
            methodSet.objectsAtIndexes =  _AtIndexesMethod;
            methodSet.getObjectsRange =  DSKeyValueMethodForPattern(self, "get%s:range:", keyCStrUpFirst);
            getter = [[DSKeyValueCollectionGetter alloc] initWithContainerClassID:containerClassID key:key  methods:methodSet proxyClass:DSKeyValueArray.self];
            [methodSet release];
        }
        else if(ountOf_Method && enumeratorOf_Method && memberOf_Method){
            DSKeyValueNonmutatingSetMethodSet *methodSet = [[DSKeyValueNonmutatingSetMethodSet alloc] init];
            methodSet.count =  ountOf_Method;
            methodSet.enumerator =  enumeratorOf_Method;
            methodSet.member =  memberOf_Method;
            getter = [[DSKeyValueCollectionGetter alloc] initWithContainerClassID:containerClassID key:key  methods:methodSet proxyClass:DSKeyValueSet.self];
            [methodSet release];
        }
        else if([self accessInstanceVariablesDirectly]) {
            Ivar ivar = NULL;
            if((ivar = DSKeyValueIvarForPattern(self, "_%s", keyCStr)) ||
               (ivar = DSKeyValueIvarForPattern(self, "_is%s", keyCStrUpFirst)) ||
               (ivar = DSKeyValueIvarForPattern(self, "%s", keyCStr)) ||
               (ivar = DSKeyValueIvarForPattern(self, "is%s", keyCStrUpFirst))
               ) {
                getter = [[DSKeyValueIvarGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
            }
        }
    }
    
    if(!getter) {
        getter = [self _d_createValuePrimitiveGetterWithContainerClassID:containerClassID key:key];
    }
    
    return getter;
}

+ (DSKeyValueGetter *)_d_createValuePrimitiveGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    DSKeyValueGetter *getter = nil;
    NSUInteger keyCstrLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCstrUpFirst[keyCstrLen + 1];
    
    [key getCString:keyCstrUpFirst maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    if(key.length) {
        keyCstrUpFirst[0] = toupper(keyCstrUpFirst[0]);
    }
    
    char keyCstr[keyCstrLen + 1];
    [key getCString:keyCstr maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    Method getMethod = NULL;
    if((getMethod = DSKeyValueMethodForPattern(self, "getPrimitive%s", keyCstrUpFirst)) ||
       (getMethod = DSKeyValueMethodForPattern(self, "primitive%s", keyCstrUpFirst))
       ) {
        getter =  [[DSKeyValueMethodGetter alloc] initWithContainerClassID:containerClassID key:key method:getMethod];
    }
    else if([self accessInstanceVariablesDirectly]) {
        Ivar ivar = NULL;
        if ((ivar = DSKeyValueIvarForPattern(self, "_%s", keyCstr)) ||
            (ivar = DSKeyValueIvarForPattern(self, "_is%s", keyCstrUpFirst)) ||
            (ivar = DSKeyValueIvarForPattern(self, "%s", keyCstr)) ||
            (ivar = DSKeyValueIvarForPattern(self, "is%s", keyCstrUpFirst))
            ) {
            getter = [[DSKeyValueIvarGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
        }
    }
    
    if(!getter) {
        getter = [self _d_createOtherValueGetterWithContainerClassID:containerClassID key:key];
    }
    
    return getter;
}


+ (id)_d_createOtherValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    return [[DSKeyValueUndefinedGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self];
}


+ (DSKeyValueSetter *)_d_createValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    DSKeyValueSetter *setter = nil;
    
    NSUInteger key_cstr_len = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    char key_cstr_upfirst[key_cstr_len + 1];
    [key getCString:key_cstr_upfirst maxLength:key_cstr_len + 1 encoding:NSUTF8StringEncoding];
    if (key.length) {
        key_cstr_upfirst[0] = toupper(key_cstr_upfirst[0]);
    }
    
    char key_cstr[key_cstr_len + 1];
    [key getCString:key_cstr maxLength:key_cstr_len + 1 encoding:NSUTF8StringEncoding];
    
    Method method = NULL;
    if ((method = DSKeyValueMethodForPattern(self, "set%s:", key_cstr_upfirst)) ||
        (method = DSKeyValueMethodForPattern(self, "_set%s:", key_cstr_upfirst)) ||
        (method = DSKeyValueMethodForPattern(self, "setIs%s:", key_cstr_upfirst))
        ) {
        setter = [[DSKeyValueMethodSetter alloc] initWithContainerClassID:containerClassID key:key method:method];
    }
    else if ([self accessInstanceVariablesDirectly]) {
        Ivar ivar = NULL;
        if ((ivar = DSKeyValueIvarForPattern(self, "_%s", key_cstr)) ||
            (ivar = DSKeyValueIvarForPattern(self, "_is%s", key_cstr_upfirst)) ||
            (ivar = DSKeyValueIvarForPattern(self, "%s", key_cstr)) ||
            (ivar = DSKeyValueIvarForPattern(self, "is%s", key_cstr_upfirst))
            ) {
            setter = [[DSKeyValueIvarSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
        }
    }
    
    if (!setter) {
        setter = [self _d_createValuePrimitiveSetterWithContainerClassID:containerClassID key:key];
    }
    
    return setter;
}

+ (DSKeyValueSetter *)_d_createValuePrimitiveSetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    DSKeyValueSetter *setter = nil;
    NSUInteger keyCstrLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCstrUpFirst[keyCstrLen + 1];
    
    [key getCString:keyCstrUpFirst maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    if(key.length) {
        keyCstrUpFirst[0] = toupper(keyCstrUpFirst[0]);
    }
    
    char keyCstr[keyCstrLen + 1];
    [key getCString:keyCstr maxLength:keyCstrLen + 1 encoding:NSUTF8StringEncoding];
    
    Method method = DSKeyValueMethodForPattern(self,"setPrimitive%s:",keyCstrUpFirst);
    if(method) {
        setter = [[DSKeyValueMethodSetter alloc] initWithContainerClassID:containerClassID key:key method:method];
    }
    else {
        if([self accessInstanceVariablesDirectly]) {
            Ivar ivar = NULL;
            if ((ivar = DSKeyValueIvarForPattern(self, "_%s", keyCstr)) ||
                (ivar = DSKeyValueIvarForPattern(self, "_is%s", keyCstrUpFirst)) ||
                (ivar = DSKeyValueIvarForPattern(self, "%s", keyCstr)) ||
                (ivar = DSKeyValueIvarForPattern(self, "is%s", keyCstrUpFirst))
                ) {
                setter = [[DSKeyValueIvarSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:ivar];
            }
        }
    }
    
    if(!setter) {
        setter = [self _d_createOtherValueSetterWithContainerClassID:containerClassID key:key];
    }
    
    return setter;
}

+ (DSKeyValueSetter *)_d_createOtherValueSetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    return [[DSKeyValueUndefinedSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self];
}


+ (DSKeyValueGetter *)_d_createMutableArrayValueGetterWithContainerClassID:(Class)containerClassID key:(NSString *)key {
    if(_DSKVONotifyingMutatorsShouldNotifyForIsaAndKey(self, key)) {
        Class originalClass = _DSKVONotifyingOriginalClassForIsa(self);
        if(!DSKeyValueCachedMutableArrayGetters) {
            CFSetCallBacks callbacks = {0};
            callbacks.version = kCFTypeSetCallBacks.version;
            callbacks.retain = kCFTypeSetCallBacks.retain;
            callbacks.release = kCFTypeSetCallBacks.release;
            callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
            callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
            callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
            DSKeyValueCachedMutableArrayGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        NSUInteger hashValue = 0;
        if(key) {
            hashValue = CFHash((CFTypeRef)key);
        }
        hashValue ^= (NSUInteger)originalClass;
        
        DSKeyValueGetter *finder = [DSKeyValueGetter new];
        finder.containerClassID = originalClass;
        finder.key = key;
        finder.hashValue = hashValue;
        
        DSKeyValueGetter *mutableArrayGetter = CFSetGetValue(DSKeyValueCachedMutableArrayGetters, finder);
        if(!mutableArrayGetter) {
            mutableArrayGetter = [originalClass _d_createMutableArrayValueGetterWithContainerClassID:originalClass key:key];
            CFSetAddValue(DSKeyValueCachedMutableArrayGetters, mutableArrayGetter);
            [mutableArrayGetter release];
        }
        
        return [[DSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key mutableCollectionGetter:mutableArrayGetter proxyClass:DSKeyValueNotifyingMutableArray.self];
    }
    else {
        NSUInteger keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char keyCStr[keyLength + 1];
        [key getCString:keyCStr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
        if(key.length) {
            keyCStr[0] = toupper(keyCStr[0]);
        }
        if(!DSKeyValueCachedGetters) {
            CFSetCallBacks callbacks = {0};
            callbacks.version = kCFTypeSetCallBacks.version;
            callbacks.retain = kCFTypeSetCallBacks.retain;
            callbacks.release = kCFTypeSetCallBacks.release;
            callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
            callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
            callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
            DSKeyValueCachedGetters = CFSetCreateMutable(NULL,0,&callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue = CFHash(key);
        }
        hashValue ^= (NSUInteger)self;
        
        DSKeyValueGetter *finder = [DSKeyValueGetter new];
        finder.containerClassID = self;
        finder.key = key;
        finder.hashValue = hashValue;
        
        DSKeyValueGetter *baseGetter =  CFSetGetValue(DSKeyValueCachedGetters,finder);
        if(!baseGetter) {
            baseGetter = [self _d_createValueGetterWithContainerClassID:self key:key];
            CFSetAddValue(DSKeyValueCachedGetters, baseGetter);
            [baseGetter release];
        }
        
        Method insertObjectAtIndexMethod = DSKeyValueMethodForPattern(self,"insertObject:in%sAtIndex:", keyCStr);
        Method insertObjectsAtIndexesMethod = DSKeyValueMethodForPattern(self,"insert%s:atIndexes:", keyCStr);
        Method removeObjectAtIndexMethod = DSKeyValueMethodForPattern(self,"removeObjectFrom%sAtIndex:", keyCStr);
        Method removeObjectsAtIndexesMethod = DSKeyValueMethodForPattern(self,"remove%sAtIndexes:", keyCStr);
        
        if((!insertObjectAtIndexMethod && !insertObjectsAtIndexesMethod) || (!removeObjectAtIndexMethod && !removeObjectsAtIndexesMethod)) {
            if(!DSKeyValueCachedSetters) {
                CFSetCallBacks callbacks = {0};
                callbacks.version = kCFTypeSetCallBacks.version;
                callbacks.retain = kCFTypeSetCallBacks.retain;
                callbacks.release = kCFTypeSetCallBacks.release;
                callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
                callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
                callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
                DSKeyValueCachedSetters = CFSetCreateMutable(NULL,0,&callbacks);
            }
            DSKeyValueSetter *finder = [DSKeyValueSetter new];
            finder.containerClassID = self;
            finder.key = key;
            finder.hashValue = CFHash((CFTypeRef)key) ^ (NSUInteger)(self);
            DSKeyValueSetter *baseSetter =  CFSetGetValue(DSKeyValueCachedSetters, finder);
            if (!baseSetter) {
                baseSetter = [self _d_createValueSetterWithContainerClassID:self key:key];
                CFSetAddValue(DSKeyValueCachedSetters, baseSetter);
                [baseSetter release];
            }
            if([baseSetter isKindOfClass:DSKeyValueIvarSetter.self]) {
                return [[DSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:((DSKeyValueIvarSetter *)baseSetter).ivar proxyClass:DSKeyValueIvarMutableArray.self];
            }
            else {
                return [[DSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key baseGetter:baseGetter baseSetter:baseSetter containerIsa:self proxyClass:DSKeyValueSlowMutableArray.self];
            }
        }
        else {
            DSKeyValueMutatingArrayMethodSet *methodSet = [[DSKeyValueMutatingArrayMethodSet alloc] init];
            methodSet.insertObjectAtIndex = insertObjectAtIndexMethod;
            methodSet.insertObjectsAtIndexes = insertObjectsAtIndexesMethod;
            methodSet.removeObjectAtIndex = removeObjectAtIndexMethod;
            methodSet.removeObjectsAtIndexes = removeObjectsAtIndexesMethod;
            methodSet.replaceObjectAtIndex = DSKeyValueMethodForPattern(self,"replaceObjectIn%sAtIndex:withObject:", keyCStr);
            methodSet.replaceObjectsAtIndexes = DSKeyValueMethodForPattern(self,"replace%sAtIndexes:with%s:", keyCStr);
            
            if([baseGetter isKindOfClass:DSKeyValueCollectionGetter.self]) {
                DSKeyValueFastMutableCollection1Getter * collection1Getter = [[DSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:containerClassID key:key nonmutatingMethods:((DSKeyValueCollectionGetter *)baseGetter).methods mutatingMethods:methodSet proxyClass:DSKeyValueFastMutableArray1.self];
                [methodSet release];
                return collection1Getter;
            }
            else {
                DSKeyValueFastMutableCollection2Getter *collection2Getter = [[DSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:containerClassID key:key baseGetter:baseGetter mutatingMethods:methodSet proxyClass:DSKeyValueFastMutableArray2.self];
                [methodSet release];
                return collection2Getter;
            }
        }
    }
}

+ (DSKeyValueGetter *)_d_createMutableSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    if(_DSKVONotifyingMutatorsShouldNotifyForIsaAndKey(self,key)) {
        Class originClass = _DSKVONotifyingOriginalClassForIsa(self);
        if(!DSKeyValueCachedMutableSetGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)DSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)DSKeyValueAccessorHash
            };
            DSKeyValueCachedMutableSetGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }

        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)originClass;
        
        DSKeyValueAccessor *finder = [DSKeyValueAccessor new];
        finder.containerClassID = originClass;
        finder.key = key;
        finder.hashValue = hashValue;
        
        DSKeyValueGetter *mutableSetGetter = CFSetGetValue(DSKeyValueCachedMutableSetGetters, finder);
        if(!mutableSetGetter) {
            mutableSetGetter = [originClass _d_createMutableSetValueGetterWithContainerClassID:originClass key:key];
            CFSetAddValue(DSKeyValueCachedMutableSetGetters, mutableSetGetter);
            [mutableSetGetter release];
        }
        return [[DSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key mutableCollectionGetter:mutableSetGetter proxyClass:DSKeyValueNotifyingMutableSet.self];
    }
    else {
        //loc_203A1
        NSUInteger keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char keyCStr[keyLength + 1];
        [key getCString:keyCStr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
        if(key.length) {
            keyCStr[0] = toupper(keyCStr[0]);
        }
        
        if(!DSKeyValueCachedGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)DSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)DSKeyValueAccessorHash
            };
            DSKeyValueCachedGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)self;
        
        DSKeyValueAccessor *finder = [DSKeyValueAccessor new];
        finder.containerClassID = self;
        finder.key = key;
        finder.hashValue = hashValue;
        
        DSKeyValueGetter *getter = CFSetGetValue(DSKeyValueCachedGetters, finder);
        if(!getter) {
            getter = [self _d_createValueGetterWithContainerClassID:self key:key];
            CFSetAddValue(DSKeyValueCachedGetters, getter);
            [getter release];
        }
        
        Method add_ObjectMethod = DSKeyValueMethodForPattern(self, "add%sObject:", keyCStr);
        Method add_Method = DSKeyValueMethodForPattern(self, "add%s:", keyCStr);
        Method remove_Method = DSKeyValueMethodForPattern(self, "remove%s:", keyCStr);
        Method remove_ObjectMethod = DSKeyValueMethodForPattern(self, "remove%sObject:", keyCStr);
        
        if((add_ObjectMethod || add_Method) && (remove_Method || remove_ObjectMethod)) {
            DSKeyValueMutatingSetMethodSet *methodSet = [[DSKeyValueMutatingSetMethodSet alloc] init];
            methodSet.addObject = add_ObjectMethod;
            methodSet.intersectSet = DSKeyValueMethodForPattern(self, "intersect%s:", keyCStr);
            methodSet.minusSet = remove_Method;
            methodSet.removeObject = remove_ObjectMethod;
            methodSet.setSet = DSKeyValueMethodForPattern(self, "set%s:", keyCStr);
            methodSet.unionSet = add_Method;
            
            if([getter isKindOfClass:DSKeyValueCollectionGetter.self]) {
                DSKeyValueFastMutableCollection1Getter *collectionGetter = [[DSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:containerClassID key:key nonmutatingMethods:[(DSKeyValueCollectionGetter *)getter methods] mutatingMethods:methodSet proxyClass:DSKeyValueFastMutableSet1.self];
                [methodSet release];
                return collectionGetter;
            }
            else {
                DSKeyValueFastMutableCollection2Getter *collectionGetter = [[DSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter mutatingMethods:methodSet proxyClass:DSKeyValueFastMutableSet2.self];
                [methodSet release];
                return collectionGetter;
            }
        }
        else {
            if(!DSKeyValueCachedSetters) {
                CFSetCallBacks callbacks = {
                    kCFTypeSetCallBacks.version,
                    kCFTypeSetCallBacks.retain,
                    kCFTypeSetCallBacks.release,
                    kCFTypeSetCallBacks.copyDescription,
                    (CFSetEqualCallBack)DSKeyValueAccessorIsEqual,
                    (CFSetHashCallBack)DSKeyValueAccessorHash
                };
                DSKeyValueCachedSetters = CFSetCreateMutable(NULL, 0, &callbacks);
            }
            
            NSUInteger hashValue = 0;
            if(key) {
                hashValue  = CFHash(key);
            }
            hashValue ^= (NSUInteger)self;
            
            DSKeyValueAccessor *finder = [DSKeyValueAccessor new];
            finder.containerClassID = self;
            finder.key = key;
            finder.hashValue = hashValue;
            
            DSKeyValueSetter *setter = CFSetGetValue(DSKeyValueCachedSetters, finder);
            if(!setter) {
                setter = [self _d_createValueSetterWithContainerClassID:self key:key];
                CFSetAddValue(DSKeyValueCachedSetters, setter);
                [setter release];
            }
            
            if([setter isKindOfClass:DSKeyValueIvarSetter.self]) {
                DSKeyValueIvarMutableCollectionGetter *collectionGetter = [[DSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:[(DSKeyValueIvarSetter *)setter ivar] proxyClass:DSKeyValueIvarMutableSet.self];
                return collectionGetter;
            }
            else {
                DSKeyValueSlowMutableCollectionGetter *collectionGetter = [[DSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter baseSetter:setter containerIsa:self proxyClass:DSKeyValueSlowMutableSet.self];
                return collectionGetter;
            }

        }
    }
}


+ (DSKeyValueGetter *)_d_createMutableOrderedSetValueGetterWithContainerClassID:(id)containerClassID key:(NSString *)key {
    if(_DSKVONotifyingMutatorsShouldNotifyForIsaAndKey(self,key)) {
        Class originClass = _DSKVONotifyingOriginalClassForIsa(self);
        if(!DSKeyValueCachedMutableOrderedSetGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)DSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)DSKeyValueAccessorHash
            };
            DSKeyValueCachedMutableOrderedSetGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)originClass;
        
        DSKeyValueAccessor *finder = [DSKeyValueAccessor new];
        finder.containerClassID = originClass;
        finder.key = key;
        finder.hashValue = hashValue;
        
        DSKeyValueGetter *mutableOrderedSetGetter = CFSetGetValue(DSKeyValueCachedMutableOrderedSetGetters, finder);
        if(!mutableOrderedSetGetter) {
            mutableOrderedSetGetter = [originClass _d_createMutableOrderedSetValueGetterWithContainerClassID:originClass key:key];
            CFSetAddValue(DSKeyValueCachedMutableOrderedSetGetters, mutableOrderedSetGetter);
            [mutableOrderedSetGetter release];
        }
        return [[DSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key mutableCollectionGetter:mutableOrderedSetGetter proxyClass:DSKeyValueNotifyingMutableOrderedSet.self];
    }
    else {
        //loc_203A1
        NSUInteger keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char kCstr[keyLength + 1];
        [key getCString:kCstr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
        if(key.length) {
            kCstr[0] = toupper(kCstr[0]);
        }
        
        if(!DSKeyValueCachedGetters) {
            CFSetCallBacks callbacks = {
                kCFTypeSetCallBacks.version,
                kCFTypeSetCallBacks.retain,
                kCFTypeSetCallBacks.release,
                kCFTypeSetCallBacks.copyDescription,
                (CFSetEqualCallBack)DSKeyValueAccessorIsEqual,
                (CFSetHashCallBack)DSKeyValueAccessorHash
            };
            DSKeyValueCachedGetters = CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        NSUInteger hashValue = 0;
        if(key) {
            hashValue  = CFHash(key);
        }
        hashValue ^= (NSUInteger)self;
        
        DSKeyValueAccessor *finder = [DSKeyValueAccessor new];
        finder.containerClassID = self;
        finder.key = key;
        finder.hashValue = hashValue;
        
        DSKeyValueGetter *getter = CFSetGetValue(DSKeyValueCachedGetters, finder);
        if(!getter) {
            getter = [self _d_createValueGetterWithContainerClassID:self key:key];
            CFSetAddValue(DSKeyValueCachedGetters, getter);
            [getter release];
        }
        
        Method insertObject_InAtIndex_Method = DSKeyValueMethodForPattern(self, "insertObject:in%sAtIndex:", kCstr);
        Method insert_AtIndexes_Method = DSKeyValueMethodForPattern(self, "insert%s:atIndexes:", kCstr);
        Method removeObjectFrom_AtIndex_Method = DSKeyValueMethodForPattern(self, "removeObjectFrom%sAtIndex:", kCstr);
        Method removeAtIndexes_Method = DSKeyValueMethodForPattern(self, "remove%sAtIndexes:", kCstr);
        
        if((insertObject_InAtIndex_Method || insert_AtIndexes_Method) && (removeObjectFrom_AtIndex_Method || removeAtIndexes_Method)) {
            DSKeyValueMutatingOrderedSetMethodSet *methodSet = [[DSKeyValueMutatingOrderedSetMethodSet alloc] init];
            methodSet.insertObjectAtIndex = insertObject_InAtIndex_Method;
            methodSet.insertObjectsAtIndexes = insert_AtIndexes_Method;
            methodSet.removeObjectAtIndex = removeObjectFrom_AtIndex_Method;
            methodSet.removeObjectsAtIndexes = removeAtIndexes_Method;
            methodSet.replaceObjectAtIndex = DSKeyValueMethodForPattern(self, "replaceObjectIn%sAtIndex:withObject:", kCstr);
            methodSet.replaceObjectsAtIndexes = DSKeyValueMethodForPattern(self, "replace%sAtIndexes:with%s:", kCstr);;
            
            if([getter isKindOfClass:DSKeyValueCollectionGetter.self]) {
                DSKeyValueFastMutableCollection1Getter *collectionGetter = [[DSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:containerClassID key:key nonmutatingMethods:[(DSKeyValueCollectionGetter *)getter methods] mutatingMethods:methodSet proxyClass:DSKeyValueFastMutableOrderedSet1.self];
                [methodSet release];
                return collectionGetter;
            }
            else {
                DSKeyValueFastMutableCollection2Getter *collectionGetter = [[DSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter mutatingMethods:methodSet proxyClass:DSKeyValueFastMutableOrderedSet2.self];
                [methodSet release];
                return collectionGetter;
            }
        }
        else {
            if(!DSKeyValueCachedSetters) {
                CFSetCallBacks callbacks = {
                    kCFTypeSetCallBacks.version,
                    kCFTypeSetCallBacks.retain,
                    kCFTypeSetCallBacks.release,
                    kCFTypeSetCallBacks.copyDescription,
                    (CFSetEqualCallBack)DSKeyValueAccessorIsEqual,
                    (CFSetHashCallBack)DSKeyValueAccessorHash
                };
                DSKeyValueCachedSetters = CFSetCreateMutable(NULL, 0, &callbacks);
            }
            
            NSUInteger hashValue = 0;
            if(key) {
                hashValue  = CFHash(key);
            }
            hashValue ^= (NSUInteger)self;
            
            DSKeyValueAccessor *finder = [DSKeyValueAccessor new];
            finder.containerClassID = self;
            finder.key = key;
            finder.hashValue = hashValue;
            
            DSKeyValueSetter *setter = CFSetGetValue(DSKeyValueCachedSetters, finder);
            if(!setter) {
                setter = [self _d_createValueSetterWithContainerClassID:self key:key];
                CFSetAddValue(DSKeyValueCachedSetters, setter);
                [setter release];
            }
            
            if([setter isKindOfClass:DSKeyValueIvarSetter.self]) {
                DSKeyValueIvarMutableCollectionGetter *collectionGetter = [[DSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:[(DSKeyValueIvarSetter *)setter ivar] proxyClass:DSKeyValueIvarMutableOrderedSet.self];
                return collectionGetter;
            }
            else {
                DSKeyValueSlowMutableCollectionGetter *collectionGetter = [[DSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key baseGetter:getter baseSetter:setter containerIsa:self proxyClass:DSKeyValueSlowMutableOrderedSet.self];
                return collectionGetter;
            }
            
        }
    }
}

@end


