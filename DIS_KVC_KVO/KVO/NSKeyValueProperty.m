#import "NSKeyValueProperty.h"
#import "NSKeyValueContainerClass.h"

@implementation NSKeyValueProperty

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

- (void)object:(id)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues)forwardingValues { }

- (BOOL)object:(id)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues *)forwardingValues {
    forwardingValues->p1 = nil;
    forwardingValues->p2 = nil;
    return YES;
}

- (void)object:(id)object didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse {}

- (void)object:(id)object didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse {}

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

- (id)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(id)keyPath propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
	if(self = [super init]) {
        self.containerClass = [containerClass retain];
        self.keyPath = [keyPath copy];
        CFSetAddValue(propertiesBeingInitialized,self);
	}
	return self;
}

@end
