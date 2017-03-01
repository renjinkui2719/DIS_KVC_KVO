//
//  NSKeyValueNestedProperty.m
//  KV
//
//  Created by renjinkui on 2017/2/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueNestedProperty.h"
#import "NSKeyValueUnnestedProperty.h"
#import "NSKeyValueContainerClass.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import "NSObject+NSKeyValueObserverRegistration.h"
#import "NSKeyValueObservance.h"
#import "NSKeyValuePropertyCreate.h"

@implementation NSKeyValueNestedProperty

- (NSKeyValueNestedProperty *)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath firstDotIndex:(NSUInteger)firstDotIndex propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
    if(self = [super _initWithContainerClass:containerClass keyPath:keyPath propertiesBeingInitialized:propertiesBeingInitialized]) {
        _relationshipKey = [keyPath substringToIndex:firstDotIndex].copy;
        _keyPathFromRelatedObject = [keyPath substringFromIndex:firstDotIndex + 1].copy;
        _relationshipProperty = (NSKeyValueUnnestedProperty *)NSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass, _relationshipKey, propertiesBeingInitialized);
        NSRange range =  [keyPath rangeOfString:@".@"];
        if(range.length) {
            NSString *sub =  [keyPath substringToIndex:range.location];
            range = [keyPath rangeOfString:@"." options:0 range:NSMakeRange(range.location + range.length, keyPath.length - (range.location + range.length))];
            if(range.length) {
                sub = [sub stringByAppendingString:[keyPath substringFromIndex:range.location]];
                //loc_6DB0B
            }
            //loc_6DB0B
            _keyPathWithoutOperatorComponents = sub.copy;
            //loc_6DB1C
        }
        //loc_6DB1C
        
        if((_isAllowedToResultInForwarding = [self.containerClass.originalClass _shouldAddObservationForwardersForKey:_relationshipKey]) &&
            [_keyPathFromRelatedObject hasPrefix:@"@"]  &&
            [_keyPathFromRelatedObject rangeOfString:@"."].location == NSNotFound
           ) {
            _isAllowedToResultInForwarding = NO;
        }
        //loc_6DB96
    }
    return self;
}

- (void)object:(id)object didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse {
    if(self.isAllowedToResultInForwarding) {
        int options = 0;
        void *context = NULL;
        if(self == observance.property) {
            //loc_6DBEB
            options = observance.options | 0x100;
            context = NULL;
        }
        else {
            //loc_6DC09
            options = 0x108;
            context = self;
        }
        
        //loc_6DC09
        ImplicitObservanceAdditionInfo *info = NSKeyValueGetImplicitObservanceAdditionInfo();
        id prevObject = info->object;
        NSKeyValueObservance *prevObservance = info->observance;
        info->object = object;
        info->observance = observance;
        
        NSKeyValueObserverRegistrationLockUnlock();
        id relationshipValue = [[object valueForKey:self.relationshipKey] retain];
        NSKeyValueObserverRegistrationLockLock();
        
        [relationshipValue addObserver:observance forKeyPath:self.keyPathFromRelatedObject options:options context:context];
        [relationshipValue release];
        
        info->object = prevObject;
        info->observance = prevObservance;
    }
    //loc_6DCC0
    [self.relationshipProperty object:object didAddObservance:observance recurse:recurse];
}

- (Class)_isaForAutonotifying {
    return [self.relationshipProperty _isaForAutonotifying];
}

- (void)object:(id)object didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse {
    if(self.isAllowedToResultInForwarding) {
        NSKeyValueObserverRegistrationLockUnlock();
        
        id relationshipObject = [object valueForKey:self.relationshipKey];
        
        ImplicitObservanceRemovalInfo *info =  NSKeyValueGetImplicitObservanceRemovalInfo();
        ImplicitObservanceRemovalInfo prevInfo = {0};
        
        prevInfo.relationshipObject = info->relationshipObject;
        prevInfo.observance = info->observance;
        prevInfo.keyPathFromRelatedObject = info->keyPathFromRelatedObject;
        prevInfo.object = info->object;
        prevInfo.property = info->property;
        prevInfo.flag = info->flag;
        
        info->relationshipObject = relationshipObject;
        info->observance = observance;
        info->keyPathFromRelatedObject = self.keyPathFromRelatedObject;
        info->object = object;
        info->property  = (observance.property == self ? nil : self);
        info->flag = YES;
        
        [relationshipObject removeObserver:observance forKeyPath:self.keyPathFromRelatedObject];
        //loc_6E357
        info->relationshipObject = prevInfo.relationshipObject;
        info->observance = prevInfo.observance;
        info->keyPathFromRelatedObject = prevInfo.keyPathFromRelatedObject;
        info->object = prevInfo.object;
        info->property = prevInfo.property;
        info->flag = prevInfo.flag;
        
        NSKeyValueObserverRegistrationLockLock();
        //loc_6E37F
    }
    //loc_6E37F
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

- (BOOL)object:(id)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues *)forwardingValues {
    
    ImplicitObservanceAdditionInfo *info = NSKeyValueGetImplicitObservanceAdditionInfo();
    if(info->object != object || info->observance !=  observance) {
        //loc_6F448
        forwardingValues->p1 = nil;
        forwardingValues->p2 = nil;
        
        if(self.isAllowedToResultInForwarding) {
            id relationshipObject = [object valueForKey:self.relationshipKey];
            forwardingValues->p1 = relationshipObject;
            if(!relationshipObject) {
                forwardingValues->p1 = [NSNull null];
            }
            //loc_6F4A6
        }
        //loc_6F4A6
        NSKeyValuePropertyForwardingValues forwardingValuesLocal = {0};
        if([self.relationshipProperty object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:recurse forwardingValues:&forwardingValuesLocal]) {
            forwardingValues->p2 = forwardingValuesLocal.p2;
        }
        return YES;
    }
    return NO;
}

- (void)object:(id)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues)forwardingValues {
    if(self.isAllowedToResultInForwarding) {
        //loc_6F575
        ImplicitObservanceRemovalInfo *removalinfo =  NSKeyValueGetImplicitObservanceRemovalInfo();
        ImplicitObservanceRemovalInfo prevRemovalInfo = {0};
        
        prevRemovalInfo.relationshipObject = removalinfo->relationshipObject;
        prevRemovalInfo.observance = removalinfo->observance;
        prevRemovalInfo.keyPathFromRelatedObject = removalinfo->keyPathFromRelatedObject;
        prevRemovalInfo.object = removalinfo->object;
        prevRemovalInfo.property = removalinfo->property;
        prevRemovalInfo.flag = removalinfo->flag;

        removalinfo->relationshipObject = (forwardingValues.p1 != [NSNull null] ? forwardingValues.p1 : nil);
        removalinfo->observance = observance;
        removalinfo->keyPathFromRelatedObject = self.keyPathFromRelatedObject;
        removalinfo->object = object;
        removalinfo->property  = (observance.property == self ? nil : self);
        removalinfo->flag = YES;

        [(forwardingValues.p1 != [NSNull null] ? forwardingValues.p1 : nil) removeObserver:observance forKeyPath:self.keyPathFromRelatedObject];
        
        //loc_6F605
        removalinfo->relationshipObject = prevRemovalInfo.relationshipObject;
        removalinfo->observance = prevRemovalInfo.observance;
        removalinfo->keyPathFromRelatedObject = prevRemovalInfo.keyPathFromRelatedObject;
        removalinfo->object = prevRemovalInfo.object;
        removalinfo->property = prevRemovalInfo.property;
        removalinfo->flag = prevRemovalInfo.flag;

        ImplicitObservanceAdditionInfo *additionInfo = NSKeyValueGetImplicitObservanceAdditionInfo();
        id prevObject = additionInfo->object;
        NSKeyValueObservance *prevObservance = additionInfo->observance;
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
    if(self.dependentValueKeyOrKeys) {
        if(self.dependentValueKeyOrKeysIsASet) {
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
    *isASet = self.dependentValueKeyOrKeysIsASet;
    return self.dependentValueKeyOrKeys;
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
