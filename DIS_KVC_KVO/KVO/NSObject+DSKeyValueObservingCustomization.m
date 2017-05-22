//
//  NSObject+DSKeyValueObservingCustomization.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/25.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSObject+DSKeyValueObservingCustomization.h"
#import "DSKeyValueObserverCommon.h"

CFMutableDictionaryRef DSKeyValueObservationInfoPerObject = NULL;
CFMutableDictionaryRef DSKeyValueOldStyleDependenciesByClass = NULL;

OSSpinLock DSKeyValueOldStyleDependenciesSpinLock = OS_SPINLOCK_INIT;


#define KeyPathsForValuesAffectingPrefix "keyPathsForValuesAffecting"

#define AutomaticallyNotifiesObserversOfPrefix "automaticallyNotifiesObserversOf"


@implementation NSObject (DSKeyValueObservingCustomization)


- (void *)d_observationInfo {
    return DSKeyValueObservationInfoPerObject ? (void *)CFDictionaryGetValue(DSKeyValueObservationInfoPerObject, OBSERVATION_INFO_KEY(self)) : NULL;
}

- (void)d_setObservationInfo:(void *)info {
    if(!DSKeyValueObservationInfoPerObject) {
        DSKeyValueObservationInfoPerObject = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    if(info) {
        CFDictionarySetValue(DSKeyValueObservationInfoPerObject, OBSERVATION_INFO_KEY(self), info);
    }
    else {
        CFDictionaryRemoveValue(DSKeyValueObservationInfoPerObject, OBSERVATION_INFO_KEY(self));
    }
}

+ (NSSet<NSString *> *)d_keyPathsForValuesAffectingValueForKey:(NSString *)key {
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
        return [self _d_keysForValuesAffectingValueForKey:key];
    }
}

+ (NSSet<NSString *> *)_d_keysForValuesAffectingValueForKey:(NSString *)key {
    os_lock_lock(&DSKeyValueOldStyleDependenciesSpinLock);
    
    NSArray *dependencies = nil;
    if(DSKeyValueOldStyleDependenciesByClass) {
        CFDictionaryRef dic = CFDictionaryGetValue(DSKeyValueOldStyleDependenciesByClass, self);
        if(dic) {
            dependencies = CFDictionaryGetValue(dic, key);
        }
    }
    
    os_lock_unlock(&DSKeyValueOldStyleDependenciesSpinLock);
    
    NSMutableSet *keySet = [NSMutableSet set];
    
    for(NSString *eachKey in dependencies) {
        if([eachKey rangeOfString:@"."].length == 0) {
            [keySet addObject:eachKey];
        }
    }
    
    return keySet;
}

+ (BOOL)d_automaticallyNotifiesObserversForKey:(NSString *)key {
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
