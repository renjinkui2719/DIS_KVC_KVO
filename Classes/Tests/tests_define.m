#import "tests_define.h"

#pragma mark - class
@implementation A

- (BOOL)isEqual:(id)object {
    if (object == self) { return YES; }
    if (![object isKindOfClass:self.class]) { return NO; }
    A *other = (A *)object;
    return [_identifier isEqualToString:other.identifier];
}

- (NSUInteger)hash {
    return _identifier.hash;
}

- (NSString *)description {
    return  self.debugDescription;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p>, identifier: %@", self.class,self, _identifier];
}

- (void)setNSArray_field:(NSMutableArray<A *> *)NSArray_field {
    _NSArray_field = [NSArray_field retain];
}

#if AFFECTING_KEY_PATH_TEST_ON
+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"B_field"]) {
        return [NSSet setWithObjects:@"C_field.char_field", @"E_field", @"F_field", nil];
    }
    else if ([key isEqualToString:@"C_field"]) {
        return [NSSet setWithObjects:@"D_field.char_field", nil];
    }
    return [super keyPathsForValuesAffectingValueForKey:key];
}

+ (NSSet<NSString *> *)d_keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"B_field"]) {
        return [NSSet setWithObjects:@"C_field.char_field", @"E_field", @"F_field", nil];
    }
    else if ([key isEqualToString:@"C_field"]) {
        return [NSSet setWithObjects:@"D_field.char_field", nil];
    }
    return [super d_keyPathsForValuesAffectingValueForKey:key];
}
#endif

#if AUTO_NOTIFY_ON
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return YES;
}

+ (BOOL)d_automaticallyNotifiesObserversForKey:(NSString *)key {
    return YES;
}
#else
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return NO;
}

+ (BOOL)d_automaticallyNotifiesObserversForKey:(NSString *)key {
    return NO;
}
#endif

#if CUSTOMER_WILL_OR_DID_CHANGE
- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
}
- (void)d_willChangeValueForKey:(NSString *)key {
    [super d_willChangeValueForKey:key];
}
#endif

#if NSARRAY_MUTE_BY_CONTAINER

- (void)insertObject:(A *)object inNSArray_fieldAtIndex:(NSUInteger)index {
    [_NSArray_field insertObject:object atIndex:index];
}

- (void)removeObjectFromNSArray_fieldAtIndex:(NSUInteger)index {
    [_NSArray_field removeObjectAtIndex:index];
}

- (void)replaceObjectInNSArray_fieldAtIndex:(NSUInteger)index withObject:(id)object {
    [_NSArray_field replaceObjectAtIndex:index withObject:object];
}

- (void)insertNSArray_field:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [_NSArray_field insertObjects:array atIndexes:indexes];
}

- (void)removeNSArray_fieldAtIndexes:(NSIndexSet *)indexes {
    [_NSArray_field removeObjectsAtIndexes:indexes];
}

- (void)replaceNSArray_fieldAtIndexes:(NSIndexSet *)indexes withNSArray_field:(NSArray *)array {
    [_NSArray_field replaceObjectsAtIndexes:indexes withObjects:array];
}


#endif

#if NSSET_MUTE_BY_CONTAINER
- (void)addNSSet_fieldObject:(A *)object {
    [_NSSet_field addObject:object];
}

- (void)removeNSSet_fieldObject:(A *)object {
    [_NSSet_field removeObject:object];
}

-(void)intersectNSSet_field:(NSSet *)objects {
    [_NSSet_field intersectSet:objects];
}

- (void)removeNSSet_field:(NSSet *)objects {
    [_NSSet_field minusSet:objects];
}

- (void)addNSSet_field:(NSSet *)objects {
    [_NSSet_field unionSet:objects];
}
#endif

#if NSORDEDSET_MUTE_BY_CONTAINER

- (void)insertObject:(A *)object inNSOrderedSet_fieldAtIndex:(NSUInteger)index {
    [_NSOrderedSet_field insertObject:object atIndex:index];
}

- (void)removeObjectFromNSOrderedSet_fieldAtIndex:(NSUInteger)index {
    [_NSOrderedSet_field removeObjectAtIndex:index];
}

- (void)replaceObjectInNSOrderedSet_fieldAtIndex:(NSUInteger)index withObject:(id)object {
    [_NSOrderedSet_field replaceObjectAtIndex:index withObject:object];
}

- (void)insertNSOrderedSet_field:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [_NSOrderedSet_field insertObjects:array atIndexes:indexes];
}

- (void)removeNSOrderedSet_fieldAtIndexes:(NSIndexSet *)indexes {
    [_NSOrderedSet_field removeObjectsAtIndexes:indexes];
}

- (void)replaceNSOrderedSet_fieldAtIndexes:(NSIndexSet *)indexes withNSOrderedSet_field:(NSArray *)array {
    [_NSOrderedSet_field replaceObjectsAtIndexes:indexes withObjects:array];
}

#endif

+ (instancetype)random {
    return [self randomWithIdentifier:random_string_20];
}

+ (instancetype)randomWithIdentifier:(NSString *)identifier {
    A *a = [self new];
    a.identifier = identifier;
    a.char_field = arc4random();
    a.BOOL_field = arc4random() % 2 == 0;
    a.unsigned_char_field = arc4random();
    a.short_field = arc4random();
    a.unsigned_short_field = arc4random();
    a.int_field = arc4random();
    a.unsigned_int_field = arc4random();
    a.long_field = arc4random();
    a.unsigned_long_field = arc4random();
    a.long_long_field = arc4random();
    a.unsigned_long_long_field = arc4random();
    a.float_field = arc4random()/100.0;
    a.double_field = arc4random()/100.0;
#if TARGET_OS_OSX
    a.NSPoint_field = NSMakePoint(arc4random()/100.0, arc4random()/100.0);
    a.NSRect_field = NSMakeRect(arc4random()/100.0, arc4random()/100.0, arc4random()/100.0, arc4random()/100.0);
#endif
    a.NSRange_field = NSMakeRange(arc4random()/100.0, arc4random()/100.0);
    a.CGPoint_field = CGPointMake(arc4random()/100.0, arc4random()/100.0);
    a.CGRect_field = CGRectMake(arc4random()/100.0, arc4random()/100.0, arc4random()/100.0, arc4random()/100.0);
    return a;
}

@end

@implementation B
@end

@implementation C
@end

@implementation D
@end

@implementation E
@end

@implementation F
@end

#pragma mark - notify result

@implementation _KVONotifyItem
- (void)dealloc {
    [_observer release];
    [_keyPath release];
    [_object release];
    [_change release];
    [super dealloc];
}

- (NSUInteger)hash {
    return [_observer hash] + [_keyPath hash] + [_object hash] + [_change hash];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    _KVONotifyItem *other = (_KVONotifyItem *)object;
    
    return other.observer == _observer && [other.keyPath isEqualToString:_keyPath] && other.object == _object && [other.change.allKeys isEqualToArray:_change.allKeys];
}

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"_observer:%@, _keyPath:%@, _object:%@,_change:%@,_context:%p}", _observer, _keyPath,_object,_change,_context];
}

@end


@implementation KVONotifyResult

- (void)dealloc {
    [_thread release];
    [_items release];
    [super dealloc];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    return [((KVONotifyResult *)object).items isEqualToArray:_items];
}

- (void)appendWithObserver:(id)observer KeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!_thread) {
        _thread = [NSThread currentThread].retain;
    }
    if (!_items) {
        _items = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [_items addObject:({
        _KVONotifyItem *item = [_KVONotifyItem new];
        item.observer = observer;
        item.keyPath = keyPath;
        item.object = object;
        item.change = change;
        item.context = context;
        item;
    })];
}

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"thread:%@, items:", _thread];
    for (_KVONotifyItem *item in _items) {
        [desc appendFormat:@"\n{\n%@\n}", item.debugDescription];
    }
    return desc;
}
@end

#pragma mark - Observer

@implementation Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [GET_NOTIFY_RESULT_PERTHREAD() appendWithObserver:self KeyPath:keyPath ofObject:object change:change context:context];
    LOG(@"observer:%@,observeValueForKeyPath: %@, object: %@, change:%@, context:%s",self, keyPath, object, change, (char *)context);
}

@end


@implementation ObserverA
@end
@implementation ObserverB
@end
@implementation ObserverC
@end
@implementation ObserverD
@end
@implementation ObserverE
@end
@implementation ObserverF
@end
