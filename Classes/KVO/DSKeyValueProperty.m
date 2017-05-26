#import "DSKeyValueProperty.h"
#import "DSKeyValueContainerClass.h"

@implementation DSKeyValueProperty

- (NSString *)restOfKeyPathIfContainedByValueForKeyPath:(NSString *)keyPath {
    if(keyPath != self.keyPath &&
       !CFEqual(keyPath,_keyPath) &&
       [self.keyPath hasPrefix:keyPath] &&
       self.keyPath.length > keyPath.length &&
       [self.keyPath characterAtIndex:keyPath.length] == '.'
       ) {
        return [self.keyPath substringFromIndex:keyPath.length + 1];
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
    [self.keyPath release];
    [self.containerClass release];
    [super dealloc];
}

- (id)_initWithContainerClass:(DSKeyValueContainerClass *)containerClass keyPath:(id)keyPath propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
	if(self = [super init]) {
        self.containerClass = [containerClass retain];
        self.keyPath = [keyPath copy];
        CFSetAddValue(propertiesBeingInitialized,self);
	}
	return self;
}

@end
