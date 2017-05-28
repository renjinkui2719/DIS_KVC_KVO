#import "DSKeyValueObservance.h"
#import "DSKeyValueProperty.h"
#import "DSKeyValueChangeDictionary.h"
#import "DSKeyValueObserverCommon.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueObserverNotification.h"

@implementation DSKeyValueObservance

- (id)_initWithObserver:(id)observer property:(id)property options:(int)options context:(void *)context originalObservable:(id)originalObservable {
    if (self = [super init]) {
        _observer = observer;
        _property = property;
        _options = options;
        _context = context;
        _originalObservable = originalObservable;
        _cachedIsShareable = !([observer isKindOfClass:[DSKeyValueObservance class]]);
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id originalObservable = change[NSKeyValueChangeOriginalObservableKey];
    LOG_KVO(@"observance: %@, _observer: %@, _property.keyPath: %@, receive kvo notify for keyPath: %@, of object: %@, change, context:%@, originalObservable: %@", simple_desc(self), simple_desc(_observer), _property.keyPath, keyPath, simple_desc(object), change, context ? simple_desc((id)context) : @"null", simple_desc(originalObservable));
    
    if(originalObservable) {
		if (context) {
			BOOL isASet = NO;
			id dependentValueKeyOrKeys = [(DSKeyValueProperty *)context dependentValueKeyOrKeysIsASet: &isASet];
            BOOL isPrior = [change[NSKeyValueChangeNotificationIsPriorKey] boolValue];
			
            if(isPrior) {
				DSKeyValueWillChangeForObservance(originalObservable, dependentValueKeyOrKeys, isASet, self);
			}
			else {
				DSKeyValueDidChangeForObservance(originalObservable, dependentValueKeyOrKeys, isASet, self);
			}
		}
		else {
			if([change isKindOfClass: [DSKeyValueChangeDictionary class]]) {
				[(DSKeyValueChangeDictionary *)change setOriginalObservable:_originalObservable];
                DSKVONotify(_observer, [_property keyPath], originalObservable, change, _context);
			}
			else {
                NSMutableDictionary *change_copy = [change mutableCopy];
                if (_originalObservable) {
                    change_copy[NSKeyValueChangeOriginalObservableKey] = _originalObservable;
                }
                else {
                    [change_copy removeObjectForKey:NSKeyValueChangeOriginalObservableKey];
                }
                DSKVONotify(_observer, [_property keyPath], originalObservable, change_copy, _context);
			}
		}
	}
}


- (NSUInteger)hash {
	return _DSKVOPointersHash(5, _observer, _property, (void *)(NSUInteger)(_options), _context, _originalObservable);
}

- (BOOL)isEqual:(id)object {
	if (object == self) {
		return YES;
	}
    
	if (![object isKindOfClass: self.class]) {
		return NO;
	}

	DSKeyValueObservance *other = (DSKeyValueObservance *)object;
    
    return  other.observer == self.observer &&
            other.options == self.options &&
            other.context == self.context &&
            other.originalObservable == self.originalObservable;
    
}

- (NSString *)description {
	NSString *option_if_new = (_options & NSKeyValueObservingOptionNew ? @"YES": @"NO");
	NSString *option_if_old = (_options & NSKeyValueObservingOptionOld ? @"YES": @"NO");
	NSString *option_if_prior = (_options & NSKeyValueObservingOptionPrior ? @"YES" : @"NO");
	return [NSString stringWithFormat:@"<%@ %p: Observer: %p, Key path: %@, Options: <New: %@, Old: %@, Prior: %@> Context: %p, Property: %p, originalObservable: %@>",
		self.class, self, _observer, _property.keyPath, option_if_new, option_if_old, option_if_prior, _context, _property, _originalObservable];
}

@end

@implementation DSKeyValueShareableObservanceKey


@end



