//
//  NSKeyValuePropertyCreate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/24.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValuePropertyCreate.h"
#import "NSKeyValueUnnestedProperty.h"
#import "NSKeyValueNestedProperty.h"
#import "NSKeyValueComputedProperty.h"
#import "NSKeyValueContainerClass.h"

extern CFMutableSetRef NSKeyValueProperties;

BOOL NSKeyValuePropertyIsEqual(NSKeyValueProperty *property1, NSKeyValueProperty *property2) {
    return (property1.containerClass == property2.containerClass) &&
    (property1.keyPath == property2.keyPath || [property1.keyPath isEqual: property2.keyPath]);
}

NSUInteger NSKeyValuePropertyHash(NSKeyValueProperty *property) {
    return property.keyPath.hash ^ (NSUInteger)(void *)property.containerClass;
}

NSKeyValueProperty *NSKeyValuePropertyForIsaAndKeyPath(Class isa, NSString *keypath) {
    NSKeyValueContainerClass *containerClass = _NSKeyValueContainerClassForIsa(isa);
    if(NSKeyValueProperties) {
        NSKeyValueProperty *finder = [NSKeyValueProperty new];
        finder.containerClass = containerClass;
        finder.keyPath = keypath;
        NSKeyValueProperty *property = CFSetGetValue(NSKeyValueProperties,finder);
        if(property) {
            return property;
        }
    }
    
    CFSetCallBacks callbacks = {0};
    callbacks.version =  kCFTypeSetCallBacks.version;
    callbacks.retain =  kCFTypeSetCallBacks.retain;
    callbacks.release =  kCFTypeSetCallBacks.release;
    callbacks.copyDescription =  kCFTypeSetCallBacks.copyDescription;
    callbacks.equal =  (CFSetEqualCallBack)NSKeyValuePropertyIsEqual;
    callbacks.hash =  (CFSetHashCallBack)NSKeyValuePropertyHash;
    CFMutableSetRef propertySet = CFSetCreateMutable(NULL,0,&callbacks);
    
    NSKeyValueProperty *property = NSKeyValuePropertyForIsaAndKeyPathInner(isa, keypath, propertySet);
    
    CFRelease(propertySet);
    
    return property;
}


NSKeyValueProperty * NSKeyValuePropertyForIsaAndKeyPathInner( Class isa, NSString *keyPath, CFMutableSetRef propertySet) {
    NSKeyValueContainerClass *containerClass = _NSKeyValueContainerClassForIsa(isa);
    
    NSKeyValueProperty *finder = [NSKeyValueProperty new];
    finder.containerClass = containerClass;
    finder.keyPath = keyPath;
    
    NSKeyValueProperty *property = CFSetGetValue(propertySet,finder);
    
    if(!property) {
        if(NSKeyValueProperties) {
            property = CFSetGetValue(NSKeyValueProperties, finder);
            if(property) {
                return property;
            }
        }
        char c = [keyPath characterAtIndex:0];
        if(c == '@') {
            property = [[NSKeyValueComputedProperty alloc] _initWithContainerClass:containerClass keyPath:keyPath propertiesBeingInitialized:propertySet];
        }
        else {
            NSRange range = [keyPath rangeOfString:@"."];
            if (range.length != 0) {
                property = [[NSKeyValueNestedProperty alloc] _initWithContainerClass:containerClass keyPath:keyPath firstDotIndex: range.location propertiesBeingInitialized:propertySet];
            }
            else {
                property = [[NSKeyValueUnnestedProperty alloc] _initWithContainerClass: containerClass key: keyPath propertiesBeingInitialized: propertySet];
            }
        }
        
        if(!NSKeyValueProperties) {
            CFSetCallBacks callbacks = {0};
            callbacks.version =  kCFTypeSetCallBacks.version;
            callbacks.retain =  kCFTypeSetCallBacks.retain;
            callbacks.release =  kCFTypeSetCallBacks.release;
            callbacks.copyDescription =  kCFTypeSetCallBacks.copyDescription;
            callbacks.equal =  (CFSetEqualCallBack)NSKeyValuePropertyIsEqual;
            callbacks.hash =  (CFSetHashCallBack)NSKeyValuePropertyHash;
            NSKeyValueProperties =  CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        CFSetAddValue(NSKeyValueProperties, property);
        CFSetRemoveValue(propertySet, property);
    }
    return property;
}
