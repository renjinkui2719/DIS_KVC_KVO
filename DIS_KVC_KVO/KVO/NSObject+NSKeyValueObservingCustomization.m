//
//  NSObject+NSKeyValueObservingCustomization.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/25.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+NSKeyValueObservingCustomization.h"
#import "NSKeyValueObserverCommon.h"
#import <objc/runtime.h>
#import <objc/message.h>

CFMutableDictionaryRef NSKeyValueObservationInfoPerObject = NULL;
CFMutableDictionaryRef NSKeyValueOldStyleDependenciesByClass = NULL;

OSSpinLock NSKeyValueOldStyleDependenciesSpinLock = OS_SPINLOCK_INIT;


#define KeyPathsForValuesAffectingPrefix "keyPathsForValuesAffecting"

#define AutomaticallyNotifiesObserversOfPrefix "automaticallyNotifiesObserversOf"


@implementation NSObject (NSKeyValueObservingCustomization)

- (void *)_observationInfoKey {
    return ((void *)(~(NSUInteger)self));
}

- (void *)observationInfo {
    return NSKeyValueObservationInfoPerObject ? (void *)CFDictionaryGetValue(NSKeyValueObservationInfoPerObject, [self _observationInfoKey]) : NULL;
}

- (void)setObservationInfo:(void *)info {
    if(!NSKeyValueObservationInfoPerObject) {
        NSKeyValueObservationInfoPerObject = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    if(info) {
        CFDictionarySetValue(NSKeyValueObservationInfoPerObject, [self _observationInfoKey], info);
    }
    else {
        CFDictionaryRemoveValue(NSKeyValueObservationInfoPerObject, [self _observationInfoKey]);
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
    char prefixedName[keyCStrLen + prefixLen + 1];
    
    snprintf(prefixedName, keyCStrLen + prefixLen, KeyPathsForValuesAffectingPrefix"%s",keyCStr);

    Method prefixedMethod = class_getClassMethod(self, sel_registerName(prefixedName));
    if(prefixedMethod) {
        return ((id (*)(id,Method))method_invoke)(self,prefixedMethod);
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
    char prefixedName[keyCStrLen + prefixLen + 1];
    
    snprintf(prefixedName, keyCStrLen + prefixLen, AutomaticallyNotifiesObserversOfPrefix"%s",keyCStr);
    
    Method prefixedMethod = class_getClassMethod(self, sel_registerName(prefixedName));
    if(prefixedMethod) {
        return ((BOOL (*)(id,Method))method_invoke)(self,prefixedMethod);
    }
    return YES;
}

@end
