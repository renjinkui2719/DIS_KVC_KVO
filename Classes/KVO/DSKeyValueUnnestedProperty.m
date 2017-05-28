#import "DSKeyValueUnnestedProperty.h"
#import "DSKeyValueContainerClass.h"
#import "DSKeyValueMethodGetter.h"
#import "DSKeyValueMethodSetter.h"
#import "DSKeyValueMutatingArrayMethodSet.h"
#import "DSKeyValueMutatingOrderedSetMethodSet.h"
#import "DSKeyValueMutatingSetMethodSet.h"
#import "NSObject+DSKeyValueCoding.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueObservingCustomization.h"
#import "DSKeyValuePropertyCreate.h"
#import "DSSetValueAndNotify.h"


@implementation DSKeyValueUnnestedProperty

- (id)_initWithContainerClass:(DSKeyValueContainerClass *)containerClass key:(NSString *)key propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
	if(self = [super _initWithContainerClass:containerClass keyPath:key propertiesBeingInitialized:propertiesBeingInitialized]) {
		NSMutableSet *affectingProperties = [[NSMutableSet alloc] init];
		[self _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties:affectingProperties];
		[affectingProperties removeObject: self];
		if (affectingProperties.count) {
			_affectingProperties = [affectingProperties allObjects].retain;
		}
		else {
			_affectingProperties = nil;
		}
		[affectingProperties release];
        
        for (DSKeyValueProperty *property in _affectingProperties) {
        	[property _addDependentValueKey: self.keyPath];
        }
	}
    return self;
}

- (void)dealloc {
    [_affectingProperties release];
    [super dealloc];
}

- (NSString *)description {
    NSArray *values = [_affectingProperties valueForKey:@"keyPath"];
    values = [values sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *valuesString = [values componentsJoinedByString:@","];
    Class isaForAutoNotifying = NULL;
    if(self.cachedIsaForAutonotifyingIsValid) {
        isaForAutoNotifying = self.cachedIsaForAutonotifying;
    }
    else {
        isaForAutoNotifying = (void *)CFSTR("not cached yet");
    }
    return [NSString stringWithFormat:@"<%@:Container class:%@, key:%@, isa for autonotifying:%@,key paths of directly and indirectly affecting properties:%@>",self.class, self.containerClass.originalClass, self.keyPath, isaForAutoNotifying, valuesString.length ? valuesString : @"none"];
}

- (Class)isaForAutonotifying {
    if(!_cachedIsaForAutonotifyingIsValid) {
        Class isaForAutonotifying = [self _isaForAutonotifying];
        _cachedIsaForAutonotifying = isaForAutonotifying;
        for (DSKeyValueProperty *property in _affectingProperties) {
            if((isaForAutonotifying = [property _isaForAutonotifying])) {
                _cachedIsaForAutonotifying = isaForAutonotifying;
            }
        }
        _cachedIsaForAutonotifyingIsValid = YES;
    }
    return _cachedIsaForAutonotifying;
}

- (Class)_isaForAutonotifying {
    BOOL autoNotify = [self.containerClass.originalClass d_automaticallyNotifiesObserversForKey:self.keyPath];
    if(autoNotify) {
        DSKeyValueNotifyingInfo *info = _DSKeyValueContainerClassGetNotifyingInfo(self.containerClass);
        if (info) {
            _DSKVONotifyingEnableForInfoAndKey(info,self.keyPath);
            return info->newSubClass;
        }
    }
    return NULL;
}

- (void)_addDependentValueKey:(NSString *)key {}

/**
 *  获取当前property依赖的其他property
 *
 *  @param propertiesBeingInitialized 所有创建的property集合
 *  @param affectingProperties        依赖的property集合
 */
- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties {
    if (_affectingProperties) {
        [affectingProperties addObjectsFromArray: _affectingProperties];
    }
    else {
        //获取当前keyPath依赖的其他keyPath
        NSSet<NSString *>* keyPaths = [self.containerClass.originalClass d_keyPathsForValuesAffectingValueForKey:self.keyPath];
        for (NSString *eachKeyPath in keyPaths) {
            //某个依赖的keyPath和当前keyPath相同，出现“自己依赖自己”，非法
            if ([eachKeyPath isEqualToString: self.keyPath]) {
                [NSException raise:NSInternalInconsistencyException
                            format:@"%@: A +keyPathsForValuesAffectingValueForKey: message returned a set that includes the same key \
                 that was passed in, which is not valid.\nPassed-in key: %@\nReturned key path set: %@", self.containerClass.originalClass, self.keyPath, keyPaths];
            }
            else {
                NSString *prefix = [self.keyPath stringByAppendingString:@"."];
                //某个依赖的keyPath包含当前keyPath，也属于“自己依赖自己”的情况，非法
                //比如 "student" 依赖 “student.age”
                if ([eachKeyPath hasPrefix: prefix]) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@: A +keyPathsForValuesAffectingValueForKey: message \
                     returned a set that includes a key path that starts with the same key that was passed in, which is not valid. The \
                     property identified by the key path already depends on the property identified by the key, never vice versa.\nPassed-in \
                     key: %@\nReturned key path set: %@",  self.containerClass.originalClass, self.keyPath, keyPaths];
                }
                else {
                    //创建依赖的每个keyPath对应的property
                    DSKeyValueProperty *property = DSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass ,eachKeyPath, propertiesBeingInitialized);
                    if(![affectingProperties containsObject:property]) {
                        [affectingProperties addObject:property];
                        //依赖property本身也可能会有自己的其他依赖项,递归获取之
                        //A-依赖->B  B-依赖->C, 那么A-依赖->C
                        [property _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties: affectingProperties];
                    }
                }
            }
        }
    }
}

/**
 @return self.keyPath if keys contains self.keyPath, otherwise nil
*/
- (NSString*)_keyPathIfAffectedByValueForMemberOfKeys:(NSSet<NSString *> *)keys {
    if([keys containsObject:self.keyPath]) {
        return self.keyPath;
    }
    return nil;
}

/**
 @return self.keyPath if keys contains self.keyPath OR keys contains some other keyPath which affecting self.keyPath, otherwise nil
 */
- (NSString*)keyPathIfAffectedByValueForMemberOfKeys:(NSSet<NSString *> *)keys {
    NSString *keyPath = nil;
    if((keyPath = [self _keyPathIfAffectedByValueForMemberOfKeys:keys])) {
        return keyPath;
    }
    for(DSKeyValueUnnestedProperty *property in self.affectingProperties) {
        if([property _keyPathIfAffectedByValueForMemberOfKeys:keys]) {
            return self.keyPath;
        }
    }
    return nil;
}

/**
 *  判断参数key是否和当前property的keyPath相等
 *  @param exactMatch key和当前property的keyPath相等,置为YES,否则置为NO
 *  @return 如果key等于当前property的keyPath，返回当前property的keyPath,  否则返回nil
 */
- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch {
    if(key != self.keyPath && !CFEqual(key, self.keyPath)) {
        return nil;
    }
    if(exactMatch) {
        *exactMatch = YES;
    }
    return self.keyPath;
}


/**
 *  判断参数key是否和当前property的keyPath相等， 或者和当前property依赖的某个property的keyPath相等
 *  @param exactMatch key和当前property的keyPath相等,置为YES,否则置为NO
 *  @return 找到相等，返回当前property的keyPath值， 否则返回nil
 */
- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch {
    NSString *keyPath = [self _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch];
    if(keyPath) {
        return keyPath;
    }
    
    for(DSKeyValueUnnestedProperty *property in self.affectingProperties) {
        if([property _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch]) {
            if(exactMatch) {
                *exactMatch = NO;
            }
            return self.keyPath;
        }
    }
    return nil;
}

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath {
    if(self.keyPath == keyPath) {
        return YES;
    }
    return CFEqual(self.keyPath, keyPath);
}

- (BOOL)object:(id)object withObservance:(DSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues *)forwardingValues {
    NSMutableDictionary *affectingMap = nil;
    DSKeyValuePropertyForwardingValues forwarding = {0x00};
    
    if(recurse && self.affectingProperties) {
        for(DSKeyValueUnnestedProperty *property in self.affectingProperties) {
            NSString *affectedKeyPath = nil;
            if([keyOrKeys isKindOfClass:NSSet.self]) {
                affectedKeyPath = [property keyPathIfAffectedByValueForMemberOfKeys:keyOrKeys];
            }
            else {
                affectedKeyPath = [property keyPathIfAffectedByValueForKey:keyOrKeys exactMatch:NULL];
            }
            if(affectedKeyPath) {
                if([property object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:NO forwardingValues:&forwarding]) {
                    if(forwarding.changingValue) {
                        if(affectingMap) {
                            [affectingMap setObject:forwarding.changingValue forKey:property];
                        }
                        else {
                            affectingMap = [NSMutableDictionary dictionaryWithObject:forwarding.changingValue forKey:property];
                        }
                    }
                    if(forwarding.affectingValuesMap) {
                        if(affectingMap) {
                            [affectingMap addEntriesFromDictionary:forwarding.affectingValuesMap];
                        }
                        else {
                            affectingMap = forwarding.affectingValuesMap;
                        }
                    }
                }
            }
        }
    }

    forwardingValues->changingValue = nil;
    forwardingValues->affectingValuesMap = affectingMap;
    
    return YES;
}

- (void)object:(id)object withObservance:(DSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues)forwardingValues {
    for(DSKeyValueProperty *property in forwardingValues.affectingValuesMap) {
        DSKeyValuePropertyForwardingValues forwarding = {forwardingValues.affectingValuesMap[property], nil};
        [property object:object withObservance:observance didChangeValueForKeyOrKeys:keyOrKeys recurse:NO forwardingValues:forwarding];
    }
}

- (void)object:(id)object didAddObservance:(id)observance recurse:(BOOL)recurse {
    if(recurse && self.affectingProperties) {
        for(DSKeyValueProperty *property in self.affectingProperties) {
            [property object:object didAddObservance:observance recurse:NO];
        }
    }
}

- (void)object:(id)object didRemoveObservance:(id)observance recurse:(BOOL)recurse {
    if(recurse && self.affectingProperties) {
        for(DSKeyValueUnnestedProperty *property in self.affectingProperties) {
            [property object:object didRemoveObservance:observance recurse:NO];
        }
    }
}

@end

