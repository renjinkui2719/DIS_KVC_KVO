//
//  NSObject+NSKeyValueObservingCustomization.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/25.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+NSKeyValueObservingCustomization.h"
#import <objc/runtime.h>
#import <objc/message.h>

extern CFMutableDictionaryRef NSKeyValueObservationInfoPerObject;
extern CFMutableDictionaryRef NSKeyValueOldStyleDependenciesByClass;

extern OSSpinLock NSKeyValueOldStyleDependenciesSpinLock;

extern void os_lock_lock(void *);
extern void os_lock_unlock(void *);

#define ObservationInfoKey(object) ((void *)(~(NSUInteger)object))
#define KeyPathsForValuesAffectingPrefix "keyPathsForValuesAffecting"
#define AutomaticallyNotifiesObserversOfPrefix "automaticallyNotifiesObserversOf"

@implementation NSObject (NSKeyValueObservingCustomization)

- (void *)observationInfo {
    return NSKeyValueObservationInfoPerObject ? (void *)CFDictionaryGetValue(NSKeyValueObservationInfoPerObject, ObservationInfoKey(self)) : NULL;
}

- (void)setObservationInfo:(void *)info {
    if(!NSKeyValueObservationInfoPerObject) {
        NSKeyValueObservationInfoPerObject = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    if(info) {
        CFDictionarySetValue(NSKeyValueObservationInfoPerObject, ObservationInfoKey(self), info);
    }
    else {
        CFDictionaryRemoveValue(NSKeyValueObservationInfoPerObject, ObservationInfoKey(self));
    }
}

+ (id)keyPathsForValuesAffectingValueForKey:(NSString *)key {
   NSUInteger keyBytesLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCStr[keyBytesLength + 1];
    [key getCString:keyCStr maxLength:keyBytesLength + 1 encoding:NSUTF8StringEncoding];
    if(key.length) {
        keyCStr[0] = toupper(keyCStr[0]);
    }
    
    NSUInteger keyCStrLen = strlen(keyCStr);
    NSUInteger prefixLen = strlen(KeyPathsForValuesAffectingPrefix);
    char newName[keyCStrLen + prefixLen + 1];
    
    snprintf(newName, keyCStrLen + prefixLen, KeyPathsForValuesAffectingPrefix"%s",keyCStr);

    Method m = class_getClassMethod(self, sel_registerName(newName));
    if(m) {
        return ((id (*)(id,Method))method_invoke)(self,m);
    }
    else {
        return [self _keysForValuesAffectingValueForKey:key];
    }
}

+ (id)_keysForValuesAffectingValueForKey:(NSString *)key {
    os_lock_lock(&NSKeyValueOldStyleDependenciesSpinLock);
    
    NSArray *dependencies = nil;
    if(NSKeyValueOldStyleDependenciesByClass) {
        CFDictionaryRef dic = CFDictionaryGetValue(NSKeyValueOldStyleDependenciesByClass, self);
        if(dic) {
            dependencies = CFDictionaryGetValue(dic, key);
        }
    }
    
    os_lock_unlock(&NSKeyValueOldStyleDependenciesSpinLock);
    
    NSMutableSet *keySet = [NSMutableSet set];
    
    for(NSString *eachKey in dependencies) {
        if([eachKey rangeOfString:@"."].length == 0) {
            [keySet addObject:eachKey];
        }
    }
    
    return keySet;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    NSUInteger keyBytesLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyCStr[keyBytesLength + 1];
    [key getCString:keyCStr maxLength:keyBytesLength + 1 encoding:NSUTF8StringEncoding];
    if(key.length) {
        keyCStr[0] = toupper(keyCStr[0]);
    }

    NSUInteger keyCStrLen = strlen(keyCStr);
    NSUInteger prefixLen = strlen(AutomaticallyNotifiesObserversOfPrefix);
    char newName[keyCStrLen + prefixLen + 1];
    
    snprintf(newName, keyCStrLen + prefixLen, AutomaticallyNotifiesObserversOfPrefix"%s",keyCStr);
    
    Method m = class_getClassMethod(self, sel_registerName(newName));
    if(m) {
        return ((BOOL (*)(id,Method))method_invoke)(self,m);
    }
    return YES;
}

@end
