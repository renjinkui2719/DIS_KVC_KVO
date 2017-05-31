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
        //_relationshipProperty 必定是Unnested Property
        _relationshipProperty = (DSKeyValueUnnestedProperty *)DSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass, _relationshipKey, propertiesBeingInitialized);
        
        NSRange dotAtRange =  [keyPath rangeOfString:@".@"];
        if(dotAtRange.length) {
            //"aaa.bbb"
            NSString *keyPathBeforeDotAt =  [keyPath substringToIndex:dotAtRange.location];
            //range of "." in ".ddd.eee"
            NSRange dotRangeAfterDotAt = [keyPath rangeOfString:@"." options:0 range:NSMakeRange(dotAtRange.location + dotAtRange.length, keyPath.length - (dotAtRange.location + dotAtRange.length))];
            //aaa.bbb"
            NSString * keyPathWithoutOperatorComponents = keyPathBeforeDotAt;
            if(dotRangeAfterDotAt.length) {
                //"aaa.bbb.ddd.eee"
                keyPathWithoutOperatorComponents = [keyPathWithoutOperatorComponents stringByAppendingString:[keyPath substringFromIndex:dotRangeAfterDotAt.location]];
            }
            //"aaa.bbb.ddd.eee"
            _keyPathWithoutOperatorComponents = keyPathWithoutOperatorComponents.retain;
        }
        
        _isAllowedToResultInForwarding = [self.containerClass.originalClass _d_shouldAddObservationForwardersForKey:_relationshipKey];
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
            options = observance.options | 0x0100;
            context = NULL;
        }
        else {
            options = NSKeyValueObservingOptionPrior | 0x0100;
            context = self;
        }
        
        ImplicitObservanceAdditionInfo *info = DSKeyValueGetImplicitObservanceAdditionInfo();
        ImplicitObservanceAdditionInfo backInfo = *info;
        
        info->originalObservable = object;
        info->observance = observance;
        
        DSKeyValueObserverRegistrationLockUnlock();
        id relationshipValue = [[object valueForKey:_relationshipKey] retain];
        DSKeyValueObserverRegistrationLockLock();
        
        LOG_KVO(@"in property: %@, will add observer: %@ to it's relationshipValue: %@, with keypath: %@, options: 0X%02x, context: %p", simple_desc(self), simple_desc(observance), simple_desc(relationshipValue), _keyPathFromRelatedObject, options, context);
        [relationshipValue d_addObserver:observance forKeyPath:_keyPathFromRelatedObject options:options context:context];
        
        [relationshipValue release];
        
        *info = backInfo;
    }
    //为_relationshipProperty依赖的所有 property继续添加监听
    [_relationshipProperty object:object didAddObservance:observance recurse:recurse];
}

- (Class)_isaForAutonotifying {
    return [_relationshipProperty isaForAutonotifying];
}

- (void)object:(id)object didRemoveObservance:(DSKeyValueObservance *)observance recurse:(BOOL)recurse {
    if(_isAllowedToResultInForwarding) {
        DSKeyValueObserverRegistrationLockUnlock();
        
        id relationshipValue = [object valueForKey:_relationshipKey];
        
        ImplicitObservanceRemovalInfo *info =  DSKeyValueGetImplicitObservanceRemovalInfo();
        ImplicitObservanceRemovalInfo backInfo = *info;
        
        info->removingObject = relationshipValue;
        info->observer = observance;
        info->keyPath = _keyPathFromRelatedObject;
        info->originalObservable = object;
        info->context  = (observance.property == self ? nil : self);
        info->shouldCompareContext = YES;
        
        LOG_KVO(@"in property: %@, will remove observer: %@ from it's relationshipValue: %@, with keypath: %@", simple_desc(self), simple_desc(observance), simple_desc(relationshipValue), _keyPathFromRelatedObject);
        [relationshipValue d_removeObserver:observance forKeyPath:_keyPathFromRelatedObject];
        
        *info = backInfo;
        
        DSKeyValueObserverRegistrationLockLock();
    }
    [_relationshipProperty object:object didRemoveObservance:observance recurse:recurse];
}

- (NSString *)_keyPathIfAffectedByValueForKey:(id)key exactMatch:(BOOL *)exactMatch {
    if(exactMatch) {
        *exactMatch = NO;
    }
    NSString *keyPath = [_relationshipProperty keyPathIfAffectedByValueForKey:key exactMatch:NULL];
    if(keyPath) {
        return self.keyPath;
    }
    return nil;
}

- (BOOL)object:(id)object withObservance:(DSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues *)forwardingValues {
    ImplicitObservanceAdditionInfo *info = DSKeyValueGetImplicitObservanceAdditionInfo();
    if(info->originalObservable != object || info->observance !=  observance) {
        forwardingValues->changingValue = nil;
        forwardingValues->affectingValuesMap = nil;
        
        if(_isAllowedToResultInForwarding) {
            id relationshipObject = [object valueForKey:_relationshipKey];
            forwardingValues->changingValue = relationshipObject;
            if(!relationshipObject) {
                forwardingValues->changingValue = [NSNull null];
            }
        }
        
        DSKeyValuePropertyForwardingValues forwarding = {0};
        if([_relationshipProperty object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:recurse forwardingValues:&forwarding]) {
            forwardingValues->affectingValuesMap = forwarding.affectingValuesMap;
        }
        return YES;
    }
    return NO;
}

- (void)object:(id)object withObservance:(DSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues)forwardingValues {
    if(_isAllowedToResultInForwarding) {
        NSKeyValueObservingOptions option = 0;
        void *context = NULL;
        
        if (observance.property == self) {
            option = observance.options | 0x0100;
            context = NULL;
        }
        else {
            option = NSKeyValueObservingOptionPrior | 0x0100;
            context = self;
        }
        
        ImplicitObservanceRemovalInfo *removalinfo =  DSKeyValueGetImplicitObservanceRemovalInfo();
        ImplicitObservanceRemovalInfo backRemovalinfo = *removalinfo;
        
        id changingRelationshipObject = (forwardingValues.changingValue != [NSNull null] ? forwardingValues.changingValue : nil);
        
        removalinfo->removingObject = changingRelationshipObject;
        removalinfo->observer = observance;
        removalinfo->keyPath = _keyPathFromRelatedObject;
        removalinfo->originalObservable = object;
        removalinfo->context  = context;
        removalinfo->shouldCompareContext = YES;

        LOG_KVO(@"in property: %@, will remove observer: %@ from changingRelationshipObject: %@, with keypath: %@", simple_desc(self), simple_desc(observance), simple_desc(changingRelationshipObject), _keyPathFromRelatedObject);
        [changingRelationshipObject d_removeObserver:observance forKeyPath:_keyPathFromRelatedObject];
        
        *removalinfo = backRemovalinfo;

        ImplicitObservanceAdditionInfo *additionInfo = DSKeyValueGetImplicitObservanceAdditionInfo();
        ImplicitObservanceAdditionInfo backAdditionInfo = *additionInfo;
        
        additionInfo->originalObservable = object;
        additionInfo->observance = observance;

        id newRelationshipObject = [object valueForKey:_relationshipKey];
        
        LOG_KVO(@"in property: %@, will add observer: %@ to new RelationshipObject: %@, with keypath: %@, options: 0X%02x, context: %p", simple_desc(self), simple_desc(observance), simple_desc(newRelationshipObject), _keyPathFromRelatedObject, option, context);
        [newRelationshipObject d_addObserver:observance forKeyPath:_keyPathFromRelatedObject options:option context:context];
        
        *additionInfo = backAdditionInfo;
    }

    if(forwardingValues.affectingValuesMap) {
        [_relationshipProperty object:object withObservance:observance didChangeValueForKeyOrKeys:observance recurse:recurse forwardingValues:forwardingValues];
    }
}

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath {
    NSString *key = _keyPathWithoutOperatorComponents;
    if(!key) {
        key = self.keyPath;
    }
    return  (key == keyPath) || CFEqual(keyPath, key);
}

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties {
    [_relationshipProperty _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties:affectingProperties];
}

- (void)_addDependentValueKey:(id)key {
    id copied = [key copy];
    
    if(_dependentValueKeyOrKeys) {
        if(_dependentValueKeyOrKeysIsASet) {
            _dependentValueKeyOrKeys = [_dependentValueKeyOrKeys setByAddingObject:copied];
        }
        else {
            _dependentValueKeyOrKeys = [[NSSet alloc] initWithObjects:_dependentValueKeyOrKeys,copied, nil];
            _dependentValueKeyOrKeysIsASet = YES;
        }
    }
    else {
        _dependentValueKeyOrKeys = copied;
    }
    
    [copied release];
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
