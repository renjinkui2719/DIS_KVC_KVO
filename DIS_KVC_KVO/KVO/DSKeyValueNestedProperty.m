//
//  DSKeyValueNestedProperty.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueNestedProperty.h"
#import "DSKeyValueUnnestedProperty.h"
#import "DSKeyValueContainerClass.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "DSKeyValueObservance.h"
#import "DSKeyValuePropertyCreate.h"
#import "DSKeyValueObserverCommon.h"

@implementation DSKeyValueNestedProperty

- (DSKeyValueNestedProperty *)_initWithContainerClass:(DSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath firstDotIndex:(NSUInteger)firstDotIndex propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
    if(self = [super _initWithContainerClass:containerClass keyPath:keyPath propertiesBeingInitialized:propertiesBeingInitialized]) {
        //假设 keyPath = "aaa.bbb.@ccc.ddd.eee"
        
        //"aaa"
        _relationshipKey = [keyPath substringToIndex:firstDotIndex].copy;
        //"bbb.@ccc.ddd.eee"
        _keyPathFromRelatedObject = [keyPath substringFromIndex:firstDotIndex + 1].copy;
        
        //property of "aaa"
        _relationshipProperty = (DSKeyValueUnnestedProperty *)DSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass, _relationshipKey, propertiesBeingInitialized);
        
        NSRange dotAtRange =  [keyPath rangeOfString:@".@"];
        if(dotAtRange.length) {
            //"aaa.bbb"
            NSString *keyPathWithoutOperatorComponents =  [keyPath substringToIndex:dotAtRange.location];
            //range of ".ddd.eee"
            NSRange dotRange = [keyPath rangeOfString:@"." options:0 range:NSMakeRange(dotAtRange.location + dotAtRange.length, keyPath.length - (dotAtRange.location + dotAtRange.length))];
            if(dotRange.length) {
                //"aaa.bbb.ddd.eee"
                keyPathWithoutOperatorComponents = [keyPathWithoutOperatorComponents stringByAppendingString:[keyPath substringFromIndex:dotRange.location]];
            }
            //"aaa.bbb.ddd.eee"
            _keyPathWithoutOperatorComponents = keyPathWithoutOperatorComponents.retain;
        }
        
        _isAllowedToResultInForwarding = [self.containerClass.originalClass _shouldAddObservationForwardersForKey:_relationshipKey];
        if (_isAllowedToResultInForwarding) {
            if ([_keyPathFromRelatedObject hasPrefix:@"@"] && [_keyPathFromRelatedObject rangeOfString:@"."].location == NSNotFound) {
                _isAllowedToResultInForwarding = NO;
            }
        }
    }
    return self;
}

- (void)object:(id)object didAddObservance:(DSKeyValueObservance *)observance recurse:(BOOL)recurse {
    if(_isAllowedToResultInForwarding) {
        int options = 0;
        void *context = NULL;
        if(self == observance.property) {
            options = observance.options;
            context = NULL;
        }
        else {
            options = DSKeyValueObservingOptionPrior;
            context = self;
        }
        
        ImplicitObservanceAdditionInfo *info = DSKeyValueGetImplicitObservanceAdditionInfo();
        ImplicitObservanceAdditionInfo backInfo = *info;
        
        info->object = object;
        info->observance = observance;
        
        DSKeyValueObserverRegistrationLockUnlock();
        id relationshipValue = [[object valueForKey:_relationshipKey] retain];
        DSKeyValueObserverRegistrationLockLock();
        
        [relationshipValue addObserver:observance forKeyPath:_keyPathFromRelatedObject options:options context:context];
        
        [relationshipValue release];
        
        *info = backInfo;
    }
    [_relationshipProperty object:object didAddObservance:observance recurse:recurse];
}

- (Class)_isaForAutonotifying {
    return [_relationshipProperty _isaForAutonotifying];
}

- (void)object:(id)object didRemoveObservance:(DSKeyValueObservance *)observance recurse:(BOOL)recurse {
    if(_isAllowedToResultInForwarding) {
        DSKeyValueObserverRegistrationLockUnlock();
        
        id relationshipValue = [object valueForKey:_relationshipKey];
        
        ImplicitObservanceRemovalInfo *info =  DSKeyValueGetImplicitObservanceRemovalInfo();
        ImplicitObservanceRemovalInfo backInfo = *info;
        
        info->relationshipObject = relationshipValue;
        info->observer = observance;
        info->keyPathFromRelatedObject = _keyPathFromRelatedObject;
        info->object = object;
        info->context  = (observance.property == self ? nil : self);
        info->flag = YES;
        
        [relationshipValue removeObserver:observance forKeyPath:_keyPathFromRelatedObject];
        
        *info = backInfo;
        
        DSKeyValueObserverRegistrationLockLock();
    }
    [self.relationshipProperty object:object didRemoveObservance:observance recurse:recurse];
}

- (NSString *)_keyPathIfAffectedByValueForKey:(id)key exactMatch:(BOOL *)exactMatch {
    if(exactMatch) {
        *exactMatch = NO;
    }
    NSString *keyPath = [self.relationshipProperty keyPathIfAffectedByValueForKey:key exactMatch:NULL];
    if(keyPath) {
        return self.keyPath;
    }
    return nil;
}

- (BOOL)object:(id)object withObservance:(DSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues *)forwardingValues {
    
    ImplicitObservanceAdditionInfo *info = DSKeyValueGetImplicitObservanceAdditionInfo();
    if(info->object != object || info->observance !=  observance) {
        //loc_6F448
        forwardingValues->p1 = nil;
        forwardingValues->p2 = nil;
        
        if(_isAllowedToResultInForwarding) {
            id relationshipObject = [object valueForKey:self.relationshipKey];
            forwardingValues->p1 = relationshipObject;
            if(!relationshipObject) {
                forwardingValues->p1 = [NSNull null];
            }
            //loc_6F4A6
        }
        //loc_6F4A6
        DSKeyValuePropertyForwardingValues forwardingValuesLocal = {0};
        if([self.relationshipProperty object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:recurse forwardingValues:&forwardingValuesLocal]) {
            forwardingValues->p2 = forwardingValuesLocal.p2;
        }
        return YES;
    }
    return NO;
}

- (void)object:(id)object withObservance:(DSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues)forwardingValues {
    if(_isAllowedToResultInForwarding) {
        ImplicitObservanceRemovalInfo *removalinfo =  DSKeyValueGetImplicitObservanceRemovalInfo();
        ImplicitObservanceRemovalInfo backRemovalinfo = *removalinfo;
        
        removalinfo->relationshipObject = (forwardingValues.p1 != [NSNull null] ? forwardingValues.p1 : nil);
        removalinfo->observer = observance;
        removalinfo->keyPathFromRelatedObject = self.keyPathFromRelatedObject;
        removalinfo->object = object;
        removalinfo->context  = (observance.property == self ? nil : self);
        removalinfo->flag = YES;

        [(forwardingValues.p1 != [NSNull null] ? forwardingValues.p1 : nil) removeObserver:observance forKeyPath:_keyPathFromRelatedObject];
        
        *removalinfo = backRemovalinfo;

        ImplicitObservanceAdditionInfo *additionInfo = DSKeyValueGetImplicitObservanceAdditionInfo();
        id prevObject = additionInfo->object;
        DSKeyValueObservance *prevObservance = additionInfo->observance;
        additionInfo->object = object;
        additionInfo->observance = observance;

        id relationshipValue = [object valueForKey:self.relationshipKey];
        
        [relationshipValue addObserver:observance forKeyPath:self.keyPathFromRelatedObject options:(observance.property == self ? observance.options | 0x100 : 0x108) context:(forwardingValues.p1 != [NSNull null] ? forwardingValues.p1 : nil)];
        
        additionInfo->object = prevObject;
        additionInfo->observance = prevObservance;
        
        if(forwardingValues.p2) {
            [self.relationshipProperty object:object withObservance:observance didChangeValueForKeyOrKeys:observance recurse:recurse forwardingValues:forwardingValues];
        }
    }
    //loc_6F6A1
}

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath {
    NSString *key = self.keyPathWithoutOperatorComponents;
    if(!key) {
        key = self.keyPath;
    }
    return  (key == keyPath) || CFEqual(keyPath, key);
}

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties {
    [self.relationshipProperty _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties:affectingProperties];
}

- (void)_addDependentValueKey:(id)valueKey {
    id valueKeyCopy = [valueKey copy];
    if(_dependentValueKeyOrKeys) {
        if(_dependentValueKeyOrKeysIsASet) {
            self.dependentValueKeyOrKeys = [self.dependentValueKeyOrKeys setByAddingObject:valueKeyCopy];
            //loc_C90F5
        }
        else {
            //loc_C9090
            self.dependentValueKeyOrKeys = [[NSSet alloc] initWithObjects:self.dependentValueKeyOrKeys,valueKeyCopy, nil];
            self.dependentValueKeyOrKeysIsASet = YES;
            //loc_C90F5
        }
    }
    else {
        //loc_C906C
        self.dependentValueKeyOrKeys = valueKeyCopy;
        //loc_C90F5
    }
    //loc_C90F5
    [valueKeyCopy release];
}

- (id)dependentValueKeyOrKeysIsASet:(BOOL *)isASet {
    *isASet = _dependentValueKeyOrKeysIsASet;
    return _dependentValueKeyOrKeys;
}

- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(id)keys {
    if([_relationshipProperty keyPathIfAffectedByValueForMemberOfKeys:keys]) {
        return self.keyPath;
    }
    return nil;
}

- (void)dealloc {
    [_dependentValueKeyOrKeys release];
    [_keyPathWithoutOperatorComponents release];
    [_relationshipProperty release];
    [_keyPathFromRelatedObject release];
    [_relationshipKey release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: Container class: %@, Relationship property: %@, Key path from related object: %@>",
            self.class, self.containerClass.originalClass, _relationshipProperty, _keyPathFromRelatedObject];
}

@end
