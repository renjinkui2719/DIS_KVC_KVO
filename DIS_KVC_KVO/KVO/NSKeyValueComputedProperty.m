#import "NSKeyValueComputedProperty.h"
#import "NSKeyValueContainerClass.h"
#import "NSKeyValuePropertyCreate.h"

@implementation NSKeyValueComputedProperty

- (id)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
    if(self = [super _initWithContainerClass:containerClass keyPath:keyPath propertiesBeingInitialized:propertiesBeingInitialized]) {
        NSRange range = [keyPath rangeOfString:@"."];
        if(range.length) {
            self.operationName = [keyPath substringWithRange:NSMakeRange(1, range.location - 1)].copy;
            self.operationArgumentKeyPath = [keyPath substringFromIndex:range.location + 1].copy;
            self.operationArgumentProperty = NSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass, self.operationArgumentKeyPath, propertiesBeingInitialized);
        }
        else {
            self.operationName = keyPath;
        }
    }
	return self;
}

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties {
    if([self.operationArgumentProperty respondsToSelector:@selector(_givenPropertiesBeingInitialized:getAffectingProperties:)]) {
        [self.operationArgumentProperty performSelector:@selector(_givenPropertiesBeingInitialized:getAffectingProperties:) withObject:(id)propertiesBeingInitialized withObject:affectingProperties];
    }
}

- (void)_addDependentValueKey:(id)valueKey {
    if([self.operationArgumentProperty respondsToSelector:@selector(_addDependentValueKey:)]) {
        [self.operationArgumentProperty performSelector:@selector(_addDependentValueKey:) withObject:valueKey];
    }
}

- (Class)_isaForAutonotifying {
    return [self.operationArgumentProperty _isaForAutonotifying];
}

- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch {
    if(exactMatch) *exactMatch = NO;
    if([self.operationArgumentProperty _keyPathIfAffectedByValueForKey:key exactMatch:NULL]) {
        return self.keyPath;
    }
    return nil;
}

- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(id)keys {
    if([self.operationArgumentProperty _keyPathIfAffectedByValueForMemberOfKeys:keys]) {
        return self.keyPath;
    }
    return nil;
}

- (void)object:(id)object didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse {
    [self.operationArgumentProperty object:object didAddObservance:observance recurse:recurse];
}

- (void)object:(id)object didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse {
    [self.operationArgumentProperty object:object didRemoveObservance:observance recurse:recurse];
}

- (BOOL)object:(id)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues *)forwardingValues {
   return [self.operationArgumentProperty object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:recurse forwardingValues:forwardingValues];
}

- (void)object:(id)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues)forwardingValues {
    [self.operationArgumentProperty object:object withObservance:observance didChangeValueForKeyOrKeys:keyOrKeys recurse:recurse forwardingValues:forwardingValues];
}

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath {
    return self.operationArgumentKeyPath == keyPath || CFEqual(self.operationArgumentKeyPath, keyPath);
}

- (void)dealloc {
    [self.operationArgumentProperty release];
    [self.operationArgumentKeyPath release];
    [self.operationName release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: Container class: %@, Operation name: %@, Operation argument property: %@",
            self.class, self.containerClass.originalClass, self.operationName, self.operationArgumentProperty];
}

@end
