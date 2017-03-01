//
//  NSObject.m
//  KVOIMP
//
//  Created by JK on 2017/1/6.
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
#import <pthread.h>

extern CFMutableSetRef NSKeyValueCachedGetters;
extern CFMutableSetRef NSKeyValueCachedSetters;
extern OSSpinLock NSKeyValueCachedAccessorSpinLock;
extern BOOL __UsePedanticKVCNilKeyBehavior_throwOnNil;
extern dispatch_once_t pedanticKVCKeyOnce;

extern void NSKeyValueObservingAssertRegistrationLockNotHeld();

CF_EXPORT CFStringEncoding __CFDefaultEightBitStringEncoding;
CF_EXPORT CFStringEncoding __CFStringComputeEightBitStringEncoding(void);


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
        finder.hashValue = CFHash((__bridge CFTypeRef)key) ^ (NSUInteger)(self.class);
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

+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}



extern CFMutableSetRef NSKeyValueCachedMutableArrayGetters;

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
        
        NSKeyValueGetter *mutableCollectionGetter = CFSetGetValue(NSKeyValueCachedMutableArrayGetters, finder);
        if(!mutableCollectionGetter) {
            mutableCollectionGetter = [originalClass _createMutableArrayValueGetterWithContainerClassID:originalClass key:key];
            CFSetAddValue(NSKeyValueCachedMutableArrayGetters, mutableCollectionGetter);
            [mutableCollectionGetter release];
        }
        
        return [[NSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key mutableCollectionGetter:mutableCollectionGetter proxyClass:NSKeyValueNotifyingMutableArray.self];
    }
    else {
        NSUInteger keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char c_str[keyLength + 1];
        [key getCString:c_str maxLength:keyLength + 1 encoding:NSUTF8StringEncoding];
        if(key.length) {
            toupper(c_str[0]);
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
           hashValue =  CFHash(key);
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
        
        Method insertObjectAtIndexMethod = NSKeyValueMethodForPattern(self,"insertObject:in%sAtIndex:", c_str);
        Method insertObjectsAtIndexesMethod = NSKeyValueMethodForPattern(self,"insert%s:atIndexes:", c_str);
        Method removeObjectAtIndexMethod = NSKeyValueMethodForPattern(self,"removeObjectFrom%sAtIndex:", c_str);
        Method removeObjectsAtIndexesMethod = NSKeyValueMethodForPattern(self,"remove%sAtIndexes:", c_str);
        
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
            NSKeyValueIvarSetter *setter =  CFSetGetValue(NSKeyValueCachedSetters, (__bridge void*)finder);
            if (!setter) {
                setter = (NSKeyValueIvarSetter *)[self.class _createValueSetterWithContainerClassID:self.class key:key];
                CFSetAddValue(NSKeyValueCachedSetters, (__bridge void*)setter);
                [setter release];
            }
            if([setter isKindOfClass:NSKeyValueIvarSetter.self]) {
                return [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:self ivar:setter.ivar proxyClass:NSKeyValueIvarMutableArray.self];
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
            methodSet.replaceObjectAtIndex = NSKeyValueMethodForPattern(self,"replaceObjectIn%sAtIndex:withObject:", c_str);
            methodSet.replaceObjectsAtIndexes = NSKeyValueMethodForPattern(self,"replace%sAtIndexes:with%s:", c_str);
            
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
