//
//  NSObject+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/6.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+DSKeyValueCoding.h"
#import "NSobject+DSKeyValueCodingPrivate.h"
#import "DSKeyValueGetter.h"
#import "DSKeyValueMethodSetter.h"
#import "DSKeyValueContainerClass.h"
#import "DSKeyValueNotifyingMutableCollectionGetter.h"
#import "DSKeyValueNotifyingMutableArray.h"
#import "DSKeyValueIvarSetter.h"
#import "DSKeyValueIvarMutableCollectionGetter.h"
#import "DSKeyValueIvarMutableArray.h"
#import "DSKeyValueSlowMutableArray.h"
#import "DSKeyValueSlowMutableCollectionGetter.h"
#import "DSKeyValueCollectionGetter.h"
#import "DSKeyValueMutatingArrayMethodSet.h"
#import "DSKeyValueFastMutableCollection1Getter.h"
#import "DSKeyValueFastMutableArray.h"
#import "DSKeyValueFastMutableCollection2Getter.h"
#import "DSKeyValueCodingCommon.h"


extern CFMutableSetRef DSKeyValueCachedGetters;
extern CFMutableSetRef DSKeyValueCachedSetters;
extern OSSpinLock DSKeyValueCachedAccessorSpinLock;
extern BOOL __UsePedanticKVCNilKeyBehavior_throwOnNil;
extern dispatch_once_t pedanticKVCKeyOnce;

extern void DSKeyValueObservingAssertRegistrationLockNotHeld();
extern NSString * _NSMethodExceptionProem(id,SEL);


@implementation NSObject (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    if(key) {
        OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
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
        
        DSKeyValueGetter *finder = [DSKeyValueGetter new];
        finder.containerClassID = self.class;
        finder.key = key;
        finder.hashValue = CFHash(key) ^ (NSUInteger)(self.class);
        DSKeyValueGetter *getter =  CFSetGetValue(DSKeyValueCachedGetters, finder);
        if (!getter) {
            getter = [self.class _createValueGetterWithContainerClassID:self.class key:key];
            CFSetAddValue(DSKeyValueCachedGetters, getter);
        }
        OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
        return _DSGetUsingKeyValueGetter(self, getter);
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

- (id)d_valueForKeyPath:(NSString *)keyPath {
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
                
                id value = [[self d_valueForKey:subKey] d_valueForKeyPath:subKeyPathLeft];
                
                [subKey release];
                [subKeyPathLeft release];
                
                return value;
            }
            else {
                //loc_47056
                return [self d_valueForKeyPath:keyPath];
            }
        }
    }
    //loc_46F99
    NSRange range = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
    if(range.length) {
        NSString *subKey =  [[keyPath substringWithRange:NSMakeRange(0, range.location)] retain];
        NSString *subKeyPathLeft =  [[keyPath substringWithRange:NSMakeRange(range.location + 1, keyPath.length -  (range.location + 1))] retain];
        
        id value = [[self d_valueForKey:subKey] d_valueForKeyPath:subKeyPathLeft];
        
        [subKey release];
        [subKeyPathLeft release];
        
        return value;
    }
    else {
        //loc_47056
        return [self d_valueForKeyPath:keyPath];
    }
}

- (void)d_setValue:(id)value forKey:(NSString *)key {
    if (key) {
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
        finder.containerClassID = self.class;
        finder.key = key;
        finder.hashValue = CFHash((__bridge CFTypeRef)key) ^ (NSUInteger)(self.class);
        DSKeyValueSetter *setter =  CFSetGetValue(DSKeyValueCachedSetters, (__bridge void*)finder);
        if (!setter) {
            setter = [self.class _createValueSetterWithContainerClassID:self.class key:key];
            CFSetAddValue(DSKeyValueCachedSetters, (__bridge void*)setter);
        }

        OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
        _DSSetUsingKeyValueSetter(self,setter, value);
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

- (void)d_setValue:(id)value forKeyPath:(NSString *)keyPath {
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
                
                [[self d_valueForKey:subKey] setValue:value forKeyPath:subKeyPathLeft];
                
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
        
        [[self d_valueForKey:subKey] setValue:value forKeyPath:subKeyPathLeft];
        
        [subKey release];
        [subKeyPathLeft release];
        
    }
    else {
         [self setValue:value forKey:keyPath];
    }
}

- (void)d_setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    for (NSString *key in keyedValues) {
        id value = keyedValues[key];
        if (value == [NSNull null]) {
            value = nil;
        }
        [self setValue:value forKey:key];
    }
}

- (void)d_setNilValueForKey:(NSString *)key {
    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.", object_getClass(self), self, key];
}

- (void)d_setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString *reason = [NSString stringWithFormat:@"[<%@ %p> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key %@.", object_getClass(self), self,key];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self,@"NSTargetObjectUserInfoKey", key ? : [NSNull null], @"NSUnknownUserInfoKey", nil];
    NSException *exception = [NSException exceptionWithName:@"NSUnknownKeyException" reason:reason userInfo:userInfo];
    [userInfo release];
    [exception raise];
}

- (id)d_valueForUndefinedKey:(NSString *)key {
    NSString *reason = [NSString stringWithFormat:@"[<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key %@.", object_getClass(self), self,key];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self,@"NSTargetObjectUserInfoKey", key ? : [NSNull null], @"NSUnknownUserInfoKey", nil];
    NSException *exception = [NSException exceptionWithName:@"NSUnknownKeyException" reason:reason userInfo:userInfo];
    [userInfo release];
    [exception raise];
    
    return nil;
}

- (NSDictionary<NSString *, id> *)d_dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys {
    NSString * *keysBuff = malloc(keys.count * sizeof(NSString *));
    id *valuesBuff = malloc(keys.count * sizeof(id));
    
    [keys getObjects:keysBuff range:NSMakeRange(0, keys.count)];
    
    for (NSUInteger i=0; i<keys.count; ++i) {
        id value = [self d_valueForKey:keysBuff[i]];
        valuesBuff[i] = value;
    }
    
    NSDictionary *keyedValues = [[NSDictionary alloc] initWithObjects:valuesBuff forKeys:keysBuff count:keys.count];
    [keyedValues autorelease];
    
    free(keysBuff);
    free(valuesBuff);
    
    return keyedValues;
}

- (BOOL)d_validateValue:(inout id  _Nullable *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable *)outError {
    NSUInteger keyLength = [inKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char inKeyCStr[keyLength + 1];
    [inKey getCString:inKeyCStr maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
    if (inKey.length) {
        inKeyCStr[0] = toupper(inKeyCStr[0]);
    }
    
    Method validateMethod = DSKeyValueMethodForPattern(object_getClass(self), "validate%s:error:", inKeyCStr);
    if (validateMethod) {
        return ((BOOL (*)(id,Method,id *,NSError **))method_invoke)(self,validateMethod,ioValue, outError);
    }
    return YES;
}

- (BOOL)d_validateValue:(inout id  _Nullable *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError * _Nullable *)outError {
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
                
                BOOL valid = [[self d_valueForKey:subKey] validateValue:ioValue forKeyPath:subKeyPathLeft error:outError];
                
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
        
        BOOL valid = [[self d_valueForKey:subKey] validateValue:ioValue forKeyPath:subKeyPathLeft error:outError];
        
        [subKey release];
        [subKeyPathLeft release];
        
        return  valid;
    }
    else {
        return [self validateValue:ioValue forKey:inKeyPath error:outError];
    }
}



+ (BOOL)d_accessInstanceVariablesDirectly {
    return YES;
}


- (id)_d_mutableColelctionValueForKey:(NSString *)key cache: (CFMutableSetRef *)cache getterCrateBlock:(DSKeyValueGetter * (^)(Class containerClassID, NSString *key))getterCrateBlock {
    OSSpinLockLock(&DSKeyValueCachedAccessorSpinLock);
    if (!*cache) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)DSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)DSKeyValueAccessorHash;
        *cache = CFSetCreateMutable(NULL, 0, &callbacks);
    }
    
    NSUInteger hashValue = 0;
    if(key) {
        hashValue = CFHash((CFTypeRef)key);
    }
    hashValue ^= (NSUInteger)self.class;
    
    DSKeyValueGetter *finder = [DSKeyValueGetter new];
    finder.containerClassID = self.class;
    finder.key = key;
    finder.hashValue = hashValue;
    
    DSKeyValueGetter *getter = CFSetGetValue(*cache, finder);
    if(!getter) {
        getter = getterCrateBlock(self.class, key);
        CFSetAddValue(*cache, getter);
        [getter release];
    }
    
    OSSpinLockUnlock(&DSKeyValueCachedAccessorSpinLock);
    
    return _DSGetUsingKeyValueGetter(self, getter);
}

- (id)_d_mutableColelctionValueForKeyPath:(NSString *)keyPath valueForKeyGetBlock:(id  (^)(id object, NSString *key))valueForKeyGetBlock {
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
                
                id value = [[self d_valueForKey:subKey] _d_mutableColelctionValueForKeyPath:subKeyPathLeft valueForKeyGetBlock: valueForKeyGetBlock];
                
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
        
        id value = [[self d_valueForKey:subKey] _d_mutableColelctionValueForKeyPath:subKeyPathLeft valueForKeyGetBlock: valueForKeyGetBlock];
        
        [subKey release];
        [subKeyPathLeft release];
        
        return  value;
    }
    else {
        return valueForKeyGetBlock(self, keyPath);
    }
}

- (NSMutableArray *)d_mutableArrayValueForKey:(NSString *)key {
    return [self _d_mutableColelctionValueForKey:key cache:&DSKeyValueCachedMutableArrayGetters getterCrateBlock:^DSKeyValueGetter *(Class containerClassID, NSString *key) {
        return [self.class _createMutableArrayValueGetterWithContainerClassID:containerClassID key:key];
    }];
}

- (NSMutableArray *)d_mutableArrayValueForKeyPath:(NSString *)keyPath {
    return [self _d_mutableColelctionValueForKeyPath:keyPath valueForKeyGetBlock:^id(id object, NSString *key) {
        return [object mutableArrayValueForKey: key];
    }];
}

- (NSMutableOrderedSet *)d_mutableOrderedSetValueForKey:(NSString *)key {
    return [self _d_mutableColelctionValueForKey:key cache:&DSKeyValueCachedMutableOrderedSetGetters getterCrateBlock:^DSKeyValueGetter *(Class containerClassID, NSString *key) {
        return [self.class _createMutableOrderedSetValueGetterWithContainerClassID:containerClassID key:key];
    }];
}

- (NSMutableOrderedSet *)d_mutableOrderedSetValueForKeyPath:(NSString *)keyPath {
    return [self _d_mutableColelctionValueForKeyPath:keyPath valueForKeyGetBlock:^id(id object, NSString *key) {
        return [object mutableOrderedSetValueForKey: key];
    }];
}

- (NSMutableOrderedSet *)d_mutableSetValueForKey:(NSString *)key {
    return [self _d_mutableColelctionValueForKey:key cache:&DSKeyValueCachedMutableSetGetters getterCrateBlock:^DSKeyValueGetter *(Class containerClassID, NSString *key) {
        return [self.class _createMutableSetValueGetterWithContainerClassID:containerClassID key:key];
    }];
}

- (NSMutableOrderedSet *)d_mutableSetValueForKeyPath:(NSString *)keyPath {
    return [self _d_mutableColelctionValueForKeyPath:keyPath valueForKeyGetBlock:^id(id object, NSString *key) {
        return [object mutableSetValueForKey: key];
    }];
}

@end
