//
//  NSObject+NSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/6.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+NSKeyValueCoding.h"
#import "NSobject+NSKeyValueCodingPrivate.h"
#import "NSKeyValueGetter.h"
#import "NSKeyValueMethodSetter.h"
#import "NSKeyValueContainerClass.h"
#import "NSKeyValueNotifyingMutableCollectionGetter.h"
#import "NSKeyValueNotifyingMutableArray.h"
#import "NSKeyValueIvarSetter.h"
#import "NSKeyValueIvarMutableCollectionGetter.h"
#import "NSKeyValueIvarMutableArray.h"
#import "NSKeyValueSlowMutableArray.h"
#import "NSKeyValueSlowMutableCollectionGetter.h"
#import "NSKeyValueCollectionGetter.h"
#import "NSKeyValueMutatingArrayMethodSet.h"
#import "NSKeyValueFastMutableCollection1Getter.h"
#import "NSKeyValueFastMutableArray.h"
#import "NSKeyValueFastMutableCollection2Getter.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <pthread.h>

extern CFMutableSetRef NSKeyValueCachedGetters;
extern CFMutableSetRef NSKeyValueCachedSetters;
extern OSSpinLock NSKeyValueCachedAccessorSpinLock;
extern BOOL __UsePedanticKVCNilKeyBehavior_throwOnNil;
extern dispatch_once_t pedanticKVCKeyOnce;

extern void NSKeyValueObservingAssertRegistrationLockNotHeld();
extern NSString * _NSMethodExceptionProem(id,SEL);

CF_EXPORT CFStringEncoding __CFDefaultEightBitStringEncoding;
CF_EXPORT CFStringEncoding __CFStringComputeEightBitStringEncoding(void);

CFMutableSetRef NSKeyValueCachedMutableArrayGetters = NULL;

@implementation NSObject (NSKeyValueCoding)

- (id)valueForKey:(NSString *)key {
    if(key) {
        NSKeyValueCacheAccessLock();
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
        
        NSKeyValueGetter *finder = [NSKeyValueGetter new];
        finder.containerClassID = self.class;
        finder.key = key;
        finder.hashValue = CFHash(key) ^ (NSUInteger)(self.class);
        NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedGetters, (__bridge void*)finder);
        if (!getter) {
            getter = [self.class _createValueGetterWithContainerClassID:self.class key:key];
            CFSetAddValue(NSKeyValueCachedGetters, (__bridge void*)getter);
        }
        NSKeyValueCacheAccessUnlock();
        return _NSGetUsingKeyValueGetter(self, getter);
    }
    else {
        dispatch_once(&pedanticKVCKeyOnce, ^{
            __UsePedanticKVCNilKeyBehavior_throwOnNil =  _NSFoundationLinkedOnAfter(0x529);
        });
        //loc_4743E
        if (__UsePedanticKVCNilKeyBehavior_throwOnNil) {
            [NSException raise:NSInvalidArgumentException format:@"%@: attempt to retrieve a value for a nil key",_NSMethodExceptionProem(self,_cmd)];
        }
    }
    return nil;
}

- (id)valueForKeyPath:(NSString *)keyPath {
    if(keyPath) {
        CFStringEncoding encoding = __CFDefaultEightBitStringEncoding;
        if(encoding == kCFStringEncodingInvalidId) {
            encoding = __CFStringComputeEightBitStringEncoding();
        }
        const char *cStr = CFStringGetCStringPtr((CFStringRef)keyPath, encoding);
        if(cStr) {
            const char *firstDotPointer = memchr(cStr, '.', keyPath.length);
            if(firstDotPointer) {
                NSString *subKey =  [[keyPath substringWithRange:NSMakeRange(0, firstDotPointer - cStr)] retain];
                NSString *subKeyPathLeft =  [[keyPath substringWithRange:NSMakeRange(firstDotPointer - cStr + 1, keyPath.length -  (firstDotPointer - cStr + 1))] retain];
                
                id value = [[self valueForKey:subKey] valueForKeyPath:subKeyPathLeft];
                
                [subKey release];
                [subKeyPathLeft release];
                
                return value;
            }
            else {
                //loc_47056
                return [self valueForKeyPath:keyPath];
            }
        }
    }
    //loc_46F99
    NSRange range = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
    if(range.length) {
        NSString *subKey =  [[keyPath substringWithRange:NSMakeRange(0, range.location)] retain];
        NSString *subKeyPathLeft =  [[keyPath substringWithRange:NSMakeRange(range.location + 1, keyPath.length -  (range.location + 1))] retain];
        
        id value = [[self valueForKey:subKey] valueForKeyPath:subKeyPathLeft];
        
        [subKey release];
        [subKeyPathLeft release];
        
        return value;
    }
    else {
        //loc_47056
        return [self valueForKeyPath:keyPath];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (key) {
        NSKeyValueCacheAccessLock();
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
        finder.containerClassID = self.class;
        finder.key = key;
        finder.hashValue = CFHash((__bridge CFTypeRef)key) ^ (NSUInteger)(self.class);
        NSKeyValueSetter *setter =  CFSetGetValue(NSKeyValueCachedSetters, (__bridge void*)finder);
        if (!setter) {
            setter = [self.class _createValueSetterWithContainerClassID:self.class key:key];
            CFSetAddValue(NSKeyValueCachedSetters, (__bridge void*)setter);
        }

        NSKeyValueCacheAccessUnlock();
        _NSSetUsingKeyValueSetter(self,setter, value);
    }
    else {
        dispatch_once(&pedanticKVCKeyOnce, ^{
            __UsePedanticKVCNilKeyBehavior_throwOnNil =  _NSFoundationLinkedOnAfter(0x529);
        });
        //loc_4743E
        if (__UsePedanticKVCNilKeyBehavior_throwOnNil) {
            [NSException raise:NSInvalidArgumentException format:@"%@: attempt to set a value for a nil key",_NSMethodExceptionProem(self,_cmd)];
        }
    }
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    if(keyPath) {
        CFStringEncoding encoding = __CFDefaultEightBitStringEncoding;
        if(encoding == kCFStringEncodingInvalidId) {
            encoding = __CFStringComputeEightBitStringEncoding();
        }
        const char *cStr = CFStringGetCStringPtr((CFStringRef)keyPath, encoding);
        if(cStr) {
            const char *firstDotPointer = memchr(cStr, '.', keyPath.length);
            if(firstDotPointer) {
                NSString *subKey =  [[keyPath substringWithRange:NSMakeRange(0, firstDotPointer - cStr)] retain];
                NSString *subKeyPathLeft =  [[keyPath substringWithRange:NSMakeRange(firstDotPointer - cStr + 1, keyPath.length -  (firstDotPointer - cStr + 1))] retain];
                
                [[self valueForKey:subKey] setValue:value forKeyPath:subKeyPathLeft];
                
                [subKey release];
                [subKeyPathLeft release];
            }
            else {
                [self setValue:value forKey:keyPath];
            }
        }
    }
    NSRange range = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
    if(range.length) {
        NSString *subKey =  [[keyPath substringWithRange:NSMakeRange(0, range.location)] retain];
        NSString *subKeyPathLeft =  [[keyPath substringWithRange:NSMakeRange(range.location + 1, keyPath.length -  (range.location + 1))] retain];
        
        [[self valueForKey:subKey] setValue:value forKeyPath:subKeyPathLeft];
        
        [subKey release];
        [subKeyPathLeft release];
        
    }
    else {
         [self setValue:value forKey:keyPath];
    }
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    for (NSString *key in keyedValues) {
        id value = keyedValues[key];
        if (value == [NSNull null]) {
            value = nil;
        }
        [self setValue:value forKey:key];
    }
}

- (void)setNilValueForKey:(NSString *)key {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.", object_getClass(self), self, key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString *reason = [NSString stringWithFormat:@"[<%@ %p> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key %@.", object_getClass(self), self,key];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self,@"NSTargetObjectUserInfoKey", key ? : [NSNull null], @"NSUnknownUserInfoKey", nil];
    NSException *exception = [NSException exceptionWithName:@"NSUnknownKeyException" reason:reason userInfo:userInfo];
    [userInfo release];
    [exception raise];
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSString *reason = [NSString stringWithFormat:@"[<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key %@.", object_getClass(self), self,key];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self,@"NSTargetObjectUserInfoKey", key ? : [NSNull null], @"NSUnknownUserInfoKey", nil];
    NSException *exception = [NSException exceptionWithName:@"NSUnknownKeyException" reason:reason userInfo:userInfo];
    [userInfo release];
    [exception raise];
    
    return nil;
}

- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys {
    NSString * *keysBuff = malloc(keys.count * sizeof(NSString *));
    id *valuesBuff = malloc(keys.count * sizeof(id));
    
    [keys getObjects:keysBuff range:NSMakeRange(0, keys.count)];
    
    for (NSUInteger i=0; i<keys.count; ++i) {
        id value = [self valueForKey:keysBuff[i]];
        valuesBuff[i] = value;
    }
    
    NSDictionary *keyedValues = [[NSDictionary alloc] initWithObjects:valuesBuff forKeys:keysBuff count:keys.count];
    [keyedValues autorelease];
    
    free(keysBuff);
    free(valuesBuff);
    
    return keyedValues;
}

- (BOOL)validateValue:(inout id  _Nullable *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable *)outError {
    NSUInteger keyLength = [inKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char inKeyCStr[keyLength + 1];
    [inKey getCString:inKeyCStr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
    if (inKey.length) {
        inKeyCStr[0] = toupper(inKeyCStr[0]);
    }
    
    Method validateMethod = NSKeyValueMethodForPattern(object_getClass(self), "validate%s:error:", inKeyCStr);
    if (validateMethod) {
        return ((BOOL (*)(id,Method,id *,NSError **))method_invoke)(self,validateMethod,ioValue, outError);
    }
    return YES;
}

- (BOOL)validateValue:(inout id  _Nullable *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError * _Nullable *)outError {
    if(inKeyPath) {
        CFStringEncoding encoding = __CFDefaultEightBitStringEncoding;
        if(encoding == kCFStringEncodingInvalidId) {
            encoding = __CFStringComputeEightBitStringEncoding();
        }
        const char *cStr = CFStringGetCStringPtr((CFStringRef)inKeyPath, encoding);
        if(cStr) {
            const char *firstDotPointer = memchr(cStr, '.', inKeyPath.length);
            if(firstDotPointer) {
                NSString *subKey =  [[inKeyPath substringWithRange:NSMakeRange(0, firstDotPointer - cStr)] retain];
                NSString *subKeyPathLeft =  [[inKeyPath substringWithRange:NSMakeRange(firstDotPointer - cStr + 1, inKeyPath.length -  (firstDotPointer - cStr + 1))] retain];
                
                BOOL valid = [[self valueForKey:subKey] validateValue:ioValue forKeyPath:subKeyPathLeft error:outError];
                
                [subKey release];
                [subKeyPathLeft release];
                
                return  valid;
            }
            else {
                return [self validateValue:ioValue forKey:inKeyPath error:outError];
            }
        }
    }
    
    NSRange range = [inKeyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, inKeyPath.length)];
    if(range.length) {
        NSString *subKey =  [[inKeyPath substringWithRange:NSMakeRange(0, range.location)] retain];
        NSString *subKeyPathLeft =  [[inKeyPath substringWithRange:NSMakeRange(range.location + 1, inKeyPath.length -  (range.location + 1))] retain];
        
        BOOL valid = [[self valueForKey:subKey] validateValue:ioValue forKeyPath:subKeyPathLeft error:outError];
        
        [subKey release];
        [subKeyPathLeft release];
        
        return  valid;
    }
    else {
        return [self validateValue:ioValue forKey:inKeyPath error:outError];
    }
}



+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}


- (id)_mutableColelctionValueForKey:(NSString *)key cache: (CFMutableSetRef *)cache getterCrateBlock:(NSKeyValueGetter * (^)(Class containerClassID, NSString *key))getterCrateBlock {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!*cache) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        *cache = CFSetCreateMutable(NULL, 0, &callbacks);
    }
    
    NSUInteger hashValue = 0;
    if(key) {
        hashValue = CFHash((CFTypeRef)key);
    }
    hashValue ^= (NSUInteger)self.class;
    
    NSKeyValueGetter *finder = [NSKeyValueGetter new];
    finder.containerClassID = self.class;
    finder.key = key;
    finder.hashValue = hashValue;
    
    NSKeyValueGetter *getter = CFSetGetValue(*cache, finder);
    if(!getter) {
        getter = getterCrateBlock(self.class, key);
        CFSetAddValue(*cache, getter);
        [getter release];
    }
    
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    
    return _NSGetUsingKeyValueGetter(self, getter);
}

- (id)_mutableColelctionValueForKeyPath:(NSString *)keyPath valueForKeyGetBlock:(id  (^)(id object, NSString *key))valueForKeyGetBlock {
    if(keyPath) {
        CFStringEncoding encoding = __CFDefaultEightBitStringEncoding;
        if(encoding == kCFStringEncodingInvalidId) {
            encoding = __CFStringComputeEightBitStringEncoding();
        }
        const char *cStr = CFStringGetCStringPtr((CFStringRef)keyPath, encoding);
        if(cStr) {
            const char *firstDotPointer = memchr(cStr, '.', keyPath.length);
            if(firstDotPointer) {
                NSString *subKey =  [[keyPath substringWithRange:NSMakeRange(0, firstDotPointer - cStr)] retain];
                NSString *subKeyPathLeft =  [[keyPath substringWithRange:NSMakeRange(firstDotPointer - cStr + 1, keyPath.length -  (firstDotPointer - cStr + 1))] retain];
                
                id value = [[self valueForKey:subKey] _mutableColelctionValueForKeyPath:subKeyPathLeft valueForKeyGetBlock: valueForKeyGetBlock];
                
                [subKey release];
                [subKeyPathLeft release];
                
                return value;
            }
            else {
                return valueForKeyGetBlock(self, keyPath);
            }
        }
    }
    
    NSRange range = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
    if(range.length) {
        NSString *subKey =  [[keyPath substringWithRange:NSMakeRange(0, range.location)] retain];
        NSString *subKeyPathLeft =  [[keyPath substringWithRange:NSMakeRange(range.location + 1, keyPath.length -  (range.location + 1))] retain];
        
        id value = [[self valueForKey:subKey] _mutableColelctionValueForKeyPath:subKeyPathLeft valueForKeyGetBlock: valueForKeyGetBlock];
        
        [subKey release];
        [subKeyPathLeft release];
        
        return  value;
    }
    else {
        return valueForKeyGetBlock(self, keyPath);
    }
}

- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key {
    return [self _mutableColelctionValueForKey:key cache:&NSKeyValueCachedMutableArrayGetters getterCrateBlock:^NSKeyValueGetter *(Class containerClassID, NSString *key) {
        return [self.class _createMutableArrayValueGetterWithContainerClassID:containerClassID key:key];
    }];
}

- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath {
    return [self _mutableColelctionValueForKeyPath:keyPath valueForKeyGetBlock:^id(id object, NSString *key) {
        return [object mutableArrayValueForKey: key];
    }];
}


- (NSMutableOrderedSet *)mutableOrderedSetValueForKey:(NSString *)key {
    return [self _mutableColelctionValueForKey:key cache:&NSKeyValueCachedMutableOrderedSetGetters getterCrateBlock:^NSKeyValueGetter *(Class containerClassID, NSString *key) {
        return [self.class _createMutableOrderedSetValueGetterWithContainerClassID:containerClassID key:key];
    }];
}

- (NSMutableOrderedSet *)mutableOrderedSetValueForKeyPath:(NSString *)keyPath {
    return [self _mutableColelctionValueForKeyPath:keyPath valueForKeyGetBlock:^id(id object, NSString *key) {
        return [object mutableOrderedSetValueForKey: key];
    }];
}

- (NSMutableOrderedSet *)mutableSetValueForKey:(NSString *)key {
    return [self _mutableColelctionValueForKey:key cache:&NSKeyValueCachedMutableSetGetters getterCrateBlock:^NSKeyValueGetter *(Class containerClassID, NSString *key) {
        return [self.class _createMutableSetValueGetterWithContainerClassID:containerClassID key:key];
    }];
}

- (NSMutableOrderedSet *)mutableSetValueForKeyPath:(NSString *)keyPath {
    return [self _mutableColelctionValueForKeyPath:keyPath valueForKeyGetBlock:^id(id object, NSString *key) {
        return [object mutableSetValueForKey: key];
    }];
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

@end
