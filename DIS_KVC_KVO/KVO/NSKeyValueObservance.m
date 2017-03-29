#import "NSKeyValueObservance.h"
#import "NSKeyValueProperty.h"
#import "NSKeyValueChangeDictionary.h"
#import "NSKeyValueObserverCommon.h"

const NSString * const NSKeyValueChangeOriginalObservableKey = @"originalObservable";

void NSKeyValueWillChangeForObservance(id,id,BOOL,id);
void NSKeyValueDidChangeForObservance(id,id,BOOL,id);
void NSKVONotify(id, NSString *, id, NSDictionary *, void *);

@implementation NSKeyValueObservance

- (id)_initWithObserver:(id)observer property:(id)property options:(int)options context:(void *)context originalObservable:(id)originalObservable {
    if (self = [super init]) {
        _observer = observer;
        _property = property;
        _options = options;
        _context = context;
        _originalObservable = originalObservable;
        _cachedIsShareable = !([observer isKindOfClass:[NSKeyValueObservance class]]);
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id originalObservable = change[NSKeyValueChangeOriginalObservableKey];
	if(originalObservable) {
		if (context) {
			BOOL isASet = NO;
			id dependentValueKeyOrKeys = [(NSKeyValueProperty *)context dependentValueKeyOrKeysIsASet: &isASet];
            BOOL isPrior = [change[NSKeyValueChangeNotificationIsPriorKey] boolValue];
			if(isPrior) {
				NSKeyValueWillChangeForObservance(originalObservable, dependentValueKeyOrKeys, isASet, self);
			}
			else {
				NSKeyValueDidChangeForObservance(originalObservable, dependentValueKeyOrKeys, isASet, self);
			}
		}
		else {
			if([change isKindOfClass: [NSKeyValueChangeDictionary class]]) {
				[(NSKeyValueChangeDictionary *)change setOriginalObservable:_originalObservable];
                NSKVONotify(_observer, [_property keyPath], originalObservable, change, _context);
			}
			else {
                NSMutableDictionary *change_copy = [change mutableCopy];
                if (_originalObservable) {
                    change_copy[NSKeyValueChangeOriginalObservableKey] = _originalObservable;
                }
                else {
                    [change_copy removeObjectForKey:NSKeyValueChangeOriginalObservableKey];
                }
                NSKVONotify(_observer, [_property keyPath], originalObservable, change_copy, _context);
			}
		}
	}
}


- (NSUInteger)hash {
	return _PointersHash(5, _observer, _property, (void *)((unsigned char)_options & 0x7F), _context, _originalObservable);
}

- (BOOL)isEqual:(id)object {
	if (object == self) {
		return YES;
	}
    
	if (![object isKindOfClass: self.class]) {
		return NO;
	}

	NSKeyValueObservance *other = (NSKeyValueObservance *)object;
	if (other.observer != self.observer) {
		return NO;
	}
	unsigned char opt_self = (unsigned char)self.options;
	unsigned char opt_other = (unsigned char)other.options;
	if (opt_self ^ opt_other) {
		return NO;
	}

	if (other.context != self.context) {
		return NO;
	}

    if (self.originalObservable == other.originalObservable) {
    	return YES;
    }

    return NO;
}

- (NSString *)description {
	NSString *option_if_new = (_options & NSKeyValueObservingOptionNew ? @"YES": @"NO");
	NSString *option_if_old = (_options & NSKeyValueObservingOptionOld ? @"YES": @"NO");
	NSString *option_if_prior = (_options & NSKeyValueObservingOptionPrior ? @"YES" : @"NO");
	return [NSString stringWithFormat:@"<%@ %p: Observer: %p, Key path: %@, Options: <New: %@, Old: %@, Prior: %@> Context: %p, Property: %p>", 
		self.class, self, _observer, _property.keyPath, option_if_new, option_if_prior, _context, _property];
}

@end



