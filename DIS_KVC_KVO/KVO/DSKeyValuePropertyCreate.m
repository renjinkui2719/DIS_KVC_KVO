//
//  DSKeyValuePropertyCreate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/24.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValuePropertyCreate.h"
#import "DSKeyValueUnnestedProperty.h"
#import "DSKeyValueNestedProperty.h"
#import "DSKeyValueComputedProperty.h"
#import "DSKeyValueContainerClass.h"

CFMutableSetRef DSKeyValueProperties;

BOOL DSKeyValuePropertyIsEqual(DSKeyValueProperty *property1, DSKeyValueProperty *property2) {
    return (property1.containerClass == property2.containerClass) &&
    (property1.keyPath == property2.keyPath || [property1.keyPath isEqual: property2.keyPath]);
}

NSUInteger DSKeyValuePropertyHash(DSKeyValueProperty *property) {
    return property.keyPath.hash ^ (NSUInteger)(void *)property.containerClass;
}

DSKeyValueProperty *DSKeyValuePropertyForIsaAndKeyPath(Class isa, NSString *keypath) {
    DSKeyValueContainerClass *containerClass = _DSKeyValueContainerClassForIsa(isa);
    if(DSKeyValueProperties) {
        DSKeyValueProperty *finder = [DSKeyValueProperty new];
        finder.containerClass = containerClass;
        finder.keyPath = keypath;
        DSKeyValueProperty *property = CFSetGetValue(DSKeyValueProperties,finder);
        if(property) {
            return property;
        }
    }
    
    CFSetCallBacks callbacks = {0};
    callbacks.version =  kCFTypeSetCallBacks.version;
    callbacks.retain =  kCFTypeSetCallBacks.retain;
    callbacks.release =  kCFTypeSetCallBacks.release;
    callbacks.copyDescription =  kCFTypeSetCallBacks.copyDescription;
    callbacks.equal =  (CFSetEqualCallBack)DSKeyValuePropertyIsEqual;
    callbacks.hash =  (CFSetHashCallBack)DSKeyValuePropertyHash;
    CFMutableSetRef initializedProperties = CFSetCreateMutable(NULL,0,&callbacks);
    
    DSKeyValueProperty *property = DSKeyValuePropertyForIsaAndKeyPathInner(isa, keypath, initializedProperties);
    
    CFRelease(initializedProperties);
    
    return property;
}


DSKeyValueProperty * DSKeyValuePropertyForIsaAndKeyPathInner( Class isa, NSString *keyPath, CFMutableSetRef initializedProperties) {
    DSKeyValueContainerClass *containerClass = _DSKeyValueContainerClassForIsa(isa);
    
    DSKeyValueProperty *finder = [DSKeyValueProperty new];
    finder.containerClass = containerClass;
    finder.keyPath = keyPath;
    
    DSKeyValueProperty *property = CFSetGetValue(initializedProperties,finder);
    
    if(!property) {
        if(DSKeyValueProperties) {
            property = CFSetGetValue(DSKeyValueProperties, finder);
            if(property) {
                return property;
            }
        }
        char c = [keyPath characterAtIndex:0];
        if(c == '@') {
            property = [[DSKeyValueComputedProperty alloc] _initWithContainerClass:containerClass keyPath:keyPath propertiesBeingInitialized:initializedProperties];
        }
        else {
            NSRange range = [keyPath rangeOfString:@"."];
            if (range.length != 0) {
                property = [[DSKeyValueNestedProperty alloc] _initWithContainerClass:containerClass keyPath:keyPath firstDotIndex: range.location propertiesBeingInitialized:initializedProperties];
            }
            else {
                property = [[DSKeyValueUnnestedProperty alloc] _initWithContainerClass: containerClass key: keyPath propertiesBeingInitialized: initializedProperties];
            }
        }
        
        if(!DSKeyValueProperties) {
            CFSetCallBacks callbacks = {0};
            callbacks.version =  kCFTypeSetCallBacks.version;
            callbacks.retain =  kCFTypeSetCallBacks.retain;
            callbacks.release =  kCFTypeSetCallBacks.release;
            callbacks.copyDescription =  kCFTypeSetCallBacks.copyDescription;
            callbacks.equal =  (CFSetEqualCallBack)DSKeyValuePropertyIsEqual;
            callbacks.hash =  (CFSetHashCallBack)DSKeyValuePropertyHash;
            DSKeyValueProperties =  CFSetCreateMutable(NULL, 0, &callbacks);
        }
        
        CFSetAddValue(DSKeyValueProperties, property);
        
        CFSetRemoveValue(initializedProperties, property);
    }
    return property;
}
