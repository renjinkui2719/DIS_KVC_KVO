#import "DSKeyValueProperty.h"
#import "DSKeyValueContainerClass.h"

@implementation DSKeyValueProperty

- (NSString *)restOfKeyPathIfContainedByValueForKeyPath:(NSString *)keyPath {
    if(keyPath != _keyPath &&
       !CFEqual(keyPath,_keyPath) &&
       [_keyPath hasPrefix:keyPath] &&
       _keyPath.length > keyPath.length &&
       [_keyPath characterAtIndex:keyPath.length] == '.'
       ) {
        return [_keyPath substringFromIndex:keyPath.length + 1];
    }
    return @"";
}

- (id)dependentValueKeyOrKeysIsASet:(BOOL *)isASet {
    return nil;
}

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath {
    return NO;
}

- (void)object:(id)object withObservance:(DSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues)forwardingValues { }

- (BOOL)object:(id)object withObservance:(DSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues *)forwardingValues {
    forwardingValues->changingValue = nil;
    forwardingValues->affectingValuesMap = nil;
    return YES;
}

- (void)object:(id)object didAddObservance:(DSKeyValueObservance *)observance recurse:(BOOL)recurse {}

- (void)object:(id)object didRemoveObservance:(DSKeyValueObservance *)observance recurse:(BOOL)recurse {}

- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(id)keys {
    return [self _keyPathIfAffectedByValueForMemberOfKeys:keys];
}


- (NSString *)keyPathIfAffectedByValueForKey:(id)key exactMatch:(BOOL *)exactMatch {
    return [self _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch];
}

- (Class)isaForAutonotifying {
    return [self _isaForAutonotifying];
}

- (id)copyWithZone:(struct _NSZone *)zone {
	return [self retain];
}

- (void)dealloc {
    [_keyPath release];
    [_containerClass release];
    [super dealloc];
}

- (id)_initWithContainerClass:(DSKeyValueContainerClass *)containerClass keyPath:(id)keyPath propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
	if(self = [super init]) {
        _containerClass = [containerClass retain];
        _keyPath = [keyPath copy];
        CFSetAddValue(propertiesBeingInitialized,self);
	}
	return self;
}

@end
