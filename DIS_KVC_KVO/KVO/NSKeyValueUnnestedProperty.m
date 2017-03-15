#import "NSKeyValueUnnestedProperty.h"
#import "NSKeyValueContainerClass.h"
#import "NSKeyValueMethodGetter.h"
#import "NSKeyValueMethodSetter.h"
#import "NSKeyValueMutatingArrayMethodSet.h"
#import "NSKeyValueMutatingOrderedSetMethodSet.h"
#import "NSKeyValueMutatingSetMethodSet.h"
#import "NSObject+NSKeyValueCoding.h"
#import "NSObject+NSKeyValueCodingPrivate.h"
#import "NSKeyValuePropertyCreate.h"
#import "NSSetValueAndNotify.h"
#import <pthread.h>
#import <objc/runtime.h>
#import <objc/objc.h>
#import <objc/message.h>

const char *NSKVOOriginalImplementationSelectorForSelector_originalImplementationMethodNamePrefix = "_original_";

extern OSSpinLock NSKeyValueCachedAccessorSpinLock;
extern CFMutableSetRef NSKeyValueCachedSetters;
extern CFMutableSetRef NSKeyValueCachedMutableArrayGetters;
extern void *_CF_forwarding_prep_0;

void _NSKVONotifyingEnableForInfoAndKey(NSKeyValueNotifyingInfo *info, NSString *key) ;

@implementation NSKeyValueUnnestedProperty

- (id)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass key:(NSString *)key propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized {
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
        
        for (NSKeyValueUnnestedProperty *property in _affectingProperties) {
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
    return [NSString stringWithFormat:@"<%@:Container class:%@, key:%@, isa for autonotifying:%@,key paths of directly and indirectly affecting properties:%@>",self.class, self.containerClass.originalClass, self.keyPath, isaForAutoNotifying, valuesString.length ? valuesString : (NSString *)CFSTR("none")];
}

- (Class)isaForAutonotifying {
    if(!_cachedIsaForAutonotifyingIsValid) {
        Class isaForAutonotifying = [self _isaForAutonotifying];
        _cachedIsaForAutonotifying = isaForAutonotifying;
        for (NSKeyValueProperty *property in _affectingProperties) {
            if((isaForAutonotifying = [property _isaForAutonotifying])) {
                _cachedIsaForAutonotifying = isaForAutonotifying;
            }
        }
        _cachedIsaForAutonotifyingIsValid = YES;
    }
    return _cachedIsaForAutonotifying;
}

- (Class)_isaForAutonotifying {
    BOOL autoNotify = [self.containerClass.originalClass automaticallyNotifiesObserversForKey:self.keyPath];
    if(autoNotify) {
        NSKeyValueNotifyingInfo *info = _NSKeyValueContainerClassGetNotifyingInfo(self.containerClass);
        if (info) {
            _NSKVONotifyingEnableForInfoAndKey(info,self.keyPath);
            return info->containerClass;
        }
    }
    return NULL;
}

- (void)_addDependentValueKey:(NSString *)key {}


- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties {
    if (_affectingProperties) {
        [affectingProperties addObjectsFromArray: _affectingProperties];
    }
    else {
        //获取self.keyPath依赖的其他keyPath
        NSSet<NSString *>* keyPaths = [self.containerClass.originalClass keyPathsForValuesAffectingValueForKey:self.keyPath];
        for (NSString *eachKeyPath in keyPaths) {
            if ([eachKeyPath isEqualToString: self.keyPath]) {
                [NSException raise:NSInternalInconsistencyException
                            format:@"%@: A +keyPathsForValuesAffectingValueForKey: message returned a set that includes the same key \
                 that was passed in, which is not valid.\nPassed-in key: %@\nReturned key path set: %@", self.containerClass.originalClass, self.keyPath, keyPaths];
            }
            else {
                NSString *prefix = [self.keyPath stringByAppendingString:@"."];
                if ([eachKeyPath hasPrefix: prefix]) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@: A +keyPathsForValuesAffectingValueForKey: message \
                     returned a set that includes a key path that starts with the same key that was passed in, which is not valid. The \
                     property identified by the key path already depends on the property identified by the key, never vice versa.\nPassed-in \
                     key: %@\nReturned key path set: %@",  self.containerClass.originalClass, self.keyPath, keyPaths];
                }
                else {
                    //创建被依赖的每个keyPath对应的property
                    NSKeyValueProperty *property = NSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass ,eachKeyPath, propertiesBeingInitialized);
                    if(![affectingProperties containsObject:property]) {
                        [affectingProperties addObject:property];
                        //被依赖property本身也会有自己的其他依赖项,获取之
                        [property _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties: affectingProperties];
                    }
                }
            }
        }
    }
}


- (NSString*)_keyPathIfAffectedByValueForMemberOfKeys:(NSSet<NSString *> *)keys {
    if([keys containsObject:self.keyPath]) {
        return self.keyPath;
    }
    return nil;
}

- (NSString*)keyPathIfAffectedByValueForMemberOfKeys:(NSSet<NSString *> *)keys {
    NSString *keyPath = nil;
    if((keyPath = [self _keyPathIfAffectedByValueForMemberOfKeys:keys])) {
        return keyPath;
    }
    for(NSKeyValueUnnestedProperty *property in self.affectingProperties) {
        if([property _keyPathIfAffectedByValueForMemberOfKeys:keys]) {
            return self.keyPath;
        }
    }
    return nil;
}

- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch {
    if(key != self.keyPath && !CFEqual(key, self.keyPath)) {
        return nil;
    }
    if(exactMatch) {
        *exactMatch = YES;
    }
    return self.keyPath;
}

- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch {
    NSString *keyPath = [self _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch];
    if(keyPath) {
        return keyPath;
    }
    for(NSKeyValueUnnestedProperty *property in self.affectingProperties) {
        if([property _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch]) {
            if(exactMatch) {
                *exactMatch = NO;
                return self.keyPath;
            }
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

- (BOOL)object:(id)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues *)forwardingValues {
    
    NSMutableDictionary *var_8C = nil;
    NSKeyValuePropertyForwardingValues forwardingValuesLocal;
    
    if(recurse && self.affectingProperties) {
        for(NSKeyValueUnnestedProperty *property in self.affectingProperties) {
            NSString *keyPath = nil;
            if([keyOrKeys isKindOfClass:NSSet.self]) {
                keyPath = [property keyPathIfAffectedByValueForMemberOfKeys:keyOrKeys];
            }
            else {
                keyPath = [property keyPathIfAffectedByValueForKey:keyOrKeys exactMatch:NULL];
            }
            if(keyPath) {
                if([property object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:NO forwardingValues:&forwardingValuesLocal]) {
                    if(forwardingValuesLocal.p1) {
                        if(var_8C) {
                            [var_8C setObject:forwardingValuesLocal.p1 forKey:property];
                        }
                        else {
                            var_8C = [NSMutableDictionary dictionaryWithObject:forwardingValuesLocal.p1 forKey:property];
                        }
                        //loc_41FEB
                    }
                    //loc_41FEB
                    if(forwardingValuesLocal.p2) {
                        if(var_8C) {
                            [var_8C addEntriesFromDictionary:forwardingValuesLocal.p2];
                        }
                        else {
                            var_8C = forwardingValuesLocal.p2;
                        }
                    }
                }
            }
        }
    }
    //loc_4205D
    forwardingValues->p1 = 0;
    forwardingValues->p2 = var_8C;
    
    return YES;
}

- (void)object:(id)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues)forwardingValues {
    for(NSKeyValueUnnestedProperty *key in forwardingValues.p2) {
        NSKeyValuePropertyForwardingValues forwardingValuesLocal = {key, nil};
        [key object:object withObservance:observance didChangeValueForKeyOrKeys:keyOrKeys recurse:NO forwardingValues:forwardingValuesLocal];
    }
}

- (void)object:(id)object didAddObservance:(id)observance recurse:(BOOL)recurse {
    if(recurse && self.affectingProperties) {
        for(NSKeyValueUnnestedProperty *property in self.affectingProperties) {
            [property object:object didAddObservance:observance recurse:NO];
        }
    }
}

- (void)object:(id)object didRemoveObservance:(id)observance recurse:(BOOL)recurse {
    if(recurse && self.affectingProperties) {
        for(NSKeyValueUnnestedProperty *property in self.affectingProperties) {
            [property object:object didRemoveObservance:observance recurse:NO];
        }
    }
}

@end


void NSKVOForwardInvocation(id object, SEL selector, void *param) {
    
}

void _NSKeyValueInvalidateCachedMutatorsForIsaAndKey(Class isa, NSString *key) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    NSUInteger hashValue = 0;
    if(key) {
        hashValue = CFHash(key);
    }
    hashValue ^= (NSUInteger)isa;
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = isa;
    finder.key = key;
    finder.hashValue = hashValue;
    
    if(NSKeyValueCachedSetters) {
        id find = CFSetGetValue(NSKeyValueCachedSetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedSetters, find);
        }
    }
    if(NSKeyValueCachedMutableArrayGetters) {
        id find = CFSetGetValue(NSKeyValueCachedMutableArrayGetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedMutableArrayGetters, find);
        }
    }
    if(NSKeyValueCachedMutableOrderedSetGetters) {
        id find = CFSetGetValue(NSKeyValueCachedMutableOrderedSetGetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedMutableOrderedSetGetters, find);
        }
    }
    if(NSKeyValueCachedMutableSetGetters) {
        id find = CFSetGetValue(NSKeyValueCachedMutableSetGetters, finder);
        if(find) {
            CFSetRemoveValue(NSKeyValueCachedMutableSetGetters, find);
        }
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
}

NSKeyValueGetter * _NSKeyValueMutableSetGetterForClassAndKey(Class isa, NSString *key) {
    return nil;
}

NSKeyValueGetter * _NSKeyValueMutableOrderedSetGetterForIsaAndKey(Class isa, NSString *key) {
    return nil;
}

NSKeyValueGetter * _NSKeyValueMutableArrayGetterForIsaAndKey(Class isa, NSString *key) {
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if(!NSKeyValueCachedMutableArrayGetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = (CFSetEqualCallBack)NSKeyValueAccessorIsEqual;
        callbacks.hash = (CFSetHashCallBack)NSKeyValueAccessorHash;
        NSKeyValueCachedMutableArrayGetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = isa;
    finder.key = key;
    finder.hashValue = (key ? CFHash((__bridge CFTypeRef)key) : 0) ^ (NSUInteger)isa;
    NSKeyValueGetter *getter =  CFSetGetValue(NSKeyValueCachedSetters, (__bridge CFTypeRef)finder);
    if (!getter) {
        getter = [isa _createMutableArrayValueGetterWithContainerClassID:isa key:key];
        CFSetAddValue(NSKeyValueCachedMutableArrayGetters, (__bridge void*)getter);
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return getter;
}

NSKeyValueSetter * _NSKeyValueSetterForClassAndKey(Class containerClassID, NSString *key, Class class){
    OSSpinLockLock(&NSKeyValueCachedAccessorSpinLock);
    if (!NSKeyValueCachedSetters) {
        CFSetCallBacks callbacks = {0};
        callbacks.version = kCFTypeSetCallBacks.version;
        callbacks.retain = kCFTypeSetCallBacks.retain;
        callbacks.release = kCFTypeSetCallBacks.release;
        callbacks.copyDescription = kCFTypeSetCallBacks.copyDescription;
        callbacks.equal = NSKeyValueAccessorIsEqual;
        callbacks.hash = NSKeyValueAccessorHash;
        NSKeyValueCachedSetters = CFSetCreateMutable(NULL,0,&callbacks);
    }
    
    NSKeyValueSetter *finder = [NSKeyValueSetter new];
    finder.containerClassID = containerClassID;
    finder.key = key;
    finder.hashValue = (key ? CFHash((__bridge CFTypeRef)key) : 0) ^ (NSUInteger)containerClassID;
    NSKeyValueSetter *setter =  CFSetGetValue(NSKeyValueCachedSetters, (__bridge CFTypeRef)finder);
    if (!setter) {
        setter = [class _createValueSetterWithContainerClassID:containerClassID key:key];
        CFSetAddValue(NSKeyValueCachedSetters, (__bridge void*)setter);
    }
    OSSpinLockUnlock(&NSKeyValueCachedAccessorSpinLock);
    return setter;
}

void _NSKVONotifyingEnableForInfoAndKey(NSKeyValueNotifyingInfo *info, NSString *key) {
    pthread_mutex_lock(&info->mutex);
    CFSetAddValue(info->keys, (CFStringRef)key);
    pthread_mutex_unlock(&info->mutex);
    
    NSKeyValueSetter * setter = _NSKeyValueSetterForClassAndKey(info->originalClass, key, info->originalClass);
    if([setter isKindOfClass: [NSKeyValueMethodSetter class]]) {
        Method setMethod = [(NSKeyValueMethodSetter *)setter method];
        const char *encoding = method_getTypeEncoding(setMethod);
        if (*encoding == 'v') {
            char *argType = method_copyArgumentType(setMethod, 2);
            IMP imp = NULL;
            switch (*argType) {
                case 'c': {
                    imp = (IMP)_NSSetCharValueAndNotify;
                } break;
                case 'd': {
                    imp = (IMP)_NSSetDoubleValueAndNotify;
                } break;
                case 'f': {
                    imp = (IMP)_NSSetFloatValueAndNotify;
                } break;
                case 'i': {
                    imp = (IMP)_NSSetIntValueAndNotify;
                } break;
                case 'l': {
                    imp = (IMP)_NSSetLongValueAndNotify;
                } break;
                case 'q': {
                    imp = (IMP)_NSSetLongLongValueAndNotify;
                } break;
                case 's': {
                    imp = (IMP)_NSSetShortValueAndNotify;
                } break;
                case 'S': {
                    imp = (IMP)_NSSetUnsignedShortValueAndNotify;
                } break;
                case '{': {
                    if(strcmp(argType, "{CGPoint=ff}") ==0) {
                        imp = (IMP)_NSSetPointValueAndNotify;
                    }
                    else if (strcmp(argType, "{_NSPoint=ff}") == 0) {
                        imp = (IMP)_NSSetPointValueAndNotify;
                    }
                    else if (strcmp (argType, "{_NSRange=II}") == 0) {
                        imp = (IMP)_NSSetRangeValueAndNotify;
                    }
                    else if (strcmp(argType,"{CGRect={CGPoint=ff}{CGSize=ff}}") == 0) {
                        imp = (IMP)_NSSetRectValueAndNotify;
                    }
                    else if (strcmp(argType,"{_NSRect={_NSPoint=ff}{_NSSize=ff}}") == 0) {
                        imp = (IMP)_NSSetRectValueAndNotify;
                    }
                    else if(strcmp(argType, "{CGSize=ff}") == 0) {
                        imp = (IMP)_NSSetSizeValueAndNotify;
                    }
                    else if (strcmp(argType, "{_NSSize=ff}") == 0) {
                        imp = (IMP)_NSSetSizeValueAndNotify;
                    }
                    else {
                        imp = (IMP)_CF_forwarding_prep_0;
                    }
                } break;
                case 'B': {
                    imp = (IMP)_NSSetBoolValueAndNotify;
                } break;
                case 'C': {
                    imp = (IMP)_NSSetUnsignedCharValueAndNotify;
                } break;
                case 'I': {
                    imp = (IMP)_NSSetUnsignedIntValueAndNotify;
                } break;
                case 'L': {
                    imp = (IMP)_NSSetUnsignedLongValueAndNotify;
                } break;
                case 'Q': {
                    imp = (IMP)_NSSetUnsignedLongLongValueAndNotify;
                } break;
                case '#': {
                    imp = (IMP)_NSSetObjectValueAndNotify;
                } break;
                default: {
                    //
                } break;
            }
            
            if (imp) {
                free(argType);
                SEL setMethodSEL = method_getName(setMethod);
                NSKVONotifyingSetMethodImplementation(info, setMethodSEL, imp, key);
                if (imp == _CF_forwarding_prep_0) {
                    NSKVONotifyingSetMethodImplementation(info, @selector(forwardInvocation:), (IMP)NSKVOForwardInvocation, nil);
                    char *setMethodSELName = sel_getName(setMethodSEL);
                    size_t setMethodSELNameLen = strlen(setMethodSELName);
                    char buff[setMethodSELNameLen + 26];
                    strlcpy(buff,
                            NSKVOOriginalImplementationSelectorForSelector_originalImplementationMethodNamePrefix,
                            setMethodSELNameLen + 11);
                    strlcat(buff, setMethodSELName, setMethodSELNameLen + 11);
                    SEL registedSEL = sel_registerName(buff);
                    IMP setMethodImp =  method_getImplementation(setMethod);
                    class_addMethod(info->containerClass, registedSEL, setMethodImp, method_getTypeEncoding(setMethod));
                }
            }
            else {
                free(argType);
                NSLog(@"KVO autonotifying only supports -set<Key>: methods that take id, \
                      NSNumber-supported scalar types, and some NSValue-supported structure \
                      types. Autonotifying will not be done for invocations of -[%s %s].",
                      class_getName(info->originalClass), sel_getName(method_getName(setMethod))
                      );
            }
        }
        else {
            NSLog(@"KVO autonotifying only supports -set<Key>: \
                  methods that return void. Autonotifying will not be done for invocations of -[%s %s].",
                  class_getName(info->originalClass), sel_getName(method_getName(setMethod)));
        }
    }
    
    NSKeyValueGetter* getter = _NSKeyValueMutableArrayGetterForIsaAndKey(info->originalClass, key);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        NSKeyValueMutatingArrayMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.insertObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectAtIndex),(IMP)NSKVOInsertObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.insertObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectsAtIndexes),(IMP)NSKVOInsertObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.removeObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectAtIndex),(IMP)NSKVORemoveObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.removeObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectsAtIndexes),(IMP)NSKVORemoveObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.replaceObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectAtIndex),(IMP)NSKVOReplaceObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.replaceObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectsAtIndexes),(IMP)NSKVOReplaceObjectsAtIndexesAndNotify,key);
            }
            //loc_1DA6E
        }
        //loc_1DA6E
    }
    //loc_1DA6E
    getter = _NSKeyValueMutableOrderedSetGetterForIsaAndKey(info->originalClass, key);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        NSKeyValueMutatingOrderedSetMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.insertObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectAtIndex),(IMP)NSKVOInsertObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.insertObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectsAtIndexes),(IMP)NSKVOInsertObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.removeObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectAtIndex),(IMP)NSKVORemoveObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.removeObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectsAtIndexes),(IMP)NSKVORemoveObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.replaceObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectAtIndex),(IMP)NSKVOReplaceObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.replaceObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectsAtIndexes),(IMP)NSKVOReplaceObjectsAtIndexesAndNotify,key);
            }
        }
    }
    //loc_1DBF6
    getter = _NSKeyValueMutableSetGetterForClassAndKey(info->originalClass, key);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        NSKeyValueMutatingSetMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.addObject) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.addObject),(IMP)NSKVOAddObjectAndNotify,key);
            }
            if(mutatingMethods.intersectSet) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.intersectSet),(IMP)NSKVOIntersectSetAndNotify,key);
            }
            if(mutatingMethods.minusSet) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.minusSet),(IMP)NSKVOMinusSetAndNotify,key);
            }
            if(mutatingMethods.removeObject) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObject),(IMP)NSKVORemoveObjectAndNotify,key);
            }
            if(mutatingMethods.unionSet) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.unionSet),(IMP)NSKVOUnionSetAndNotify,key);
            }
        }
    }
    //loc_1DD45
    _NSKeyValueInvalidateCachedMutatorsForIsaAndKey(info->containerClass, key);
}
