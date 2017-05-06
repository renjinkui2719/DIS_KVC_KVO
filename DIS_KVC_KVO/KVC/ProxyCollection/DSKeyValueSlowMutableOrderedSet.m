//
//  DSKeyValueSlowMutableOrderedSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSlowMutableOrderedSet.h"
#import "DSKeyValueSlowMutableCollectionGetter.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "DSKeyValueCodingCommon.h"

@implementation DSKeyValueSlowMutableOrderedSet

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueSlowMutableCollectionGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _valueGetter = [[getter baseGetter] retain];
        _valueSetter = [[getter baseSetter] retain];
        _treatNilValuesLikeEmptyOrderedSets = [getter treatNilValuesLikeEmptyCollections];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    [_valueGetter release];
    [_valueSetter release];
    [super _proxyNonGCFinalize];
    _valueGetter = nil;
    _valueSetter = nil;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector {
    [NSException raise:NSInternalInconsistencyException format:@"%@: value for key %@ of object %p is nil", _NSMethodExceptionProem(self,selector), self.key, self.container];
}

- (id)_nonNilOrderedSetValueWithSelector:(SEL)selector {
    id value = _DSGetUsingKeyValueGetter(self.container, _valueGetter);
    if(!value) {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return value;
}

- (id)_createNonNilMutableOrderedSetValueWithSelector:(SEL)selector {
    id value = _DSGetUsingKeyValueGetter(self.container, _valueGetter);
    if(!value) {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return [value mutableCopy];
}

- (NSUInteger)count {
    id value = _DSGetUsingKeyValueGetter(self.container, _valueGetter);
    if (!value && !_treatNilValuesLikeEmptyOrderedSets) {
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
    return [value count];
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    [[self _nonNilOrderedSetValueWithSelector:_cmd] getObjects:objects range:range];
}

- (NSUInteger)indexOfObject:(id)object {
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] indexOfObject:object];
}

- (id)objectAtIndex:(NSUInteger)idx {
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] objectAtIndex:idx];
}

- (NSArray<id> *)objectsAtIndexes:(NSIndexSet *)indexes {
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
    id value = _DSGetUsingKeyValueGetter(self.container, _valueGetter);
    if (value) {
        id mutableCopy = [value mutableCopy];
        [mutableCopy insertObject:object atIndex:idx];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
    else if(idx != 0 || !_treatNilValuesLikeEmptyOrderedSets){
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
    else {
        value = [[NSMutableOrderedSet alloc] initWithObjects:&object count:1];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, value);
        [value release];
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    id value = _DSGetUsingKeyValueGetter(self.container, _valueGetter);
    if(value) {
        id mutableCopy = [value mutableCopy];
        [mutableCopy insertObjects:objects atIndexes:indexes];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
    else if(!_treatNilValuesLikeEmptyOrderedSets){
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
    else if(!objects || !indexes) {
        [NSException raise:NSInvalidArgumentException format:@"%@: the %@ must not be nil.", _NSMethodExceptionProem(self, _cmd), !objects ? @"passed-in ordered set":@"index set"];
    }
    else if(objects.count != indexes.count) {
        [NSException raise:NSInvalidArgumentException format:@"%@: the counts of the passed-in ordered set (%lu) and index set (%lu) must be identical.",_NSMethodExceptionProem(self, _cmd), objects.count, indexes.count];
    }
    else if(indexes.lastIndex >= objects.count && indexes.lastIndex != NSNotFound){
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
    else {
        id mutableCopy = [objects mutableCopy];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)idx {
    id value = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [value removeObjectAtIndex:idx];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, value);
    [value release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    id value = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [value removeObjectsAtIndexes:indexes];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, value);
    [value release];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
    id value = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [value replaceObjectAtIndex:idx withObject:object];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, value);
    [value release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    id value = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [value replaceObjectsAtIndexes:indexes withObjects:objects];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, value);
    [value release];
}

@end
