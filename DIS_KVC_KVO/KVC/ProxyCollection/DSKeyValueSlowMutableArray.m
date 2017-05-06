//
//  DSKeyValueSlowMutableArray.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSlowMutableArray.h"
#import "DSKeyValueSlowMutableCollectionGetter.h"
#import "NSObject+DSKeyValueCodingPrivate.h"

extern NSString * _NSMethodExceptionProem(id,SEL);

@implementation DSKeyValueSlowMutableArray

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueSlowMutableCollectionGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _valueGetter = [[getter baseGetter] retain];
        _valueSetter = [[getter baseSetter] retain];
        _treatNilValuesLikeEmptyArrays = [getter treatNilValuesLikeEmptyCollections];
    }
    return self;
}


- (id)_nonNilArrayValueWithSelector:(SEL)selector {
    id arrayValue = _DSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (!arrayValue) {
        [self _raiseNilValueExceptionWithSelector: selector];
    }
    return arrayValue;
}

- (id)_createNonNilMutableArrayValueWithSelector:(SEL)selector {
    id arrayValue = _DSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (!arrayValue) {
        [self _raiseNilValueExceptionWithSelector: selector];
    }
    return [arrayValue mutableCopy];
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector {
    [NSException raise:NSInternalInconsistencyException format:@"%@: value for key %@ of object %p is nil", _NSMethodExceptionProem(self,selector), self.key, self.container];
}

- (void)_proxyNonGCFinalize {
    [_valueGetter release];
    [_valueSetter release];
    _valueGetter = nil;
    _valueSetter = nil;
    [super _proxyNonGCFinalize];
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (NSUInteger)count {
    id arrayValue = _DSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (!arrayValue && !_treatNilValuesLikeEmptyArrays) {
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
    return [arrayValue count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [[self _nonNilArrayValueWithSelector:_cmd] objectAtIndex:index];
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    [[self _nonNilArrayValueWithSelector:_cmd] getObjects:objects range:range];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes; {
    return [[self _nonNilArrayValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (void)addObject:(id)anObject {
    id arrayValue = _DSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (arrayValue) {
        id mutableCopy = [arrayValue mutableCopy];
        [mutableCopy addObject:anObject];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
    else {
        if (!_treatNilValuesLikeEmptyArrays) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:&anObject count:1];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableArray);
        [mutableArray release];
    }
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    id arrayValue = _DSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (arrayValue) {
        id mutableCopy = [arrayValue mutableCopy];
        [mutableCopy insertObject:anObject atIndex:index];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
    else {
        if (index != 0 || !_treatNilValuesLikeEmptyArrays) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:&anObject count:1];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableArray);
        [mutableArray release];
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    id arrayValue = _DSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (arrayValue) {
        id mutableCopy = [arrayValue mutableCopy];
        [mutableCopy insertObjects:objects atIndexes:indexes];
        _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
    else {
        if (!_treatNilValuesLikeEmptyArrays) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        
        if (!objects || !indexes) {
            [NSException raise:NSInvalidArgumentException format:@"%@: the %@ must not be nil.", _NSMethodExceptionProem(self,_cmd), !objects ? @"passed-in array":@"index set"];
        }
        
        if (objects.count != indexes.count) {
            [NSException raise:NSInvalidArgumentException format:@"%@: the counts of the passed-in array (%lu) and index set (%lu) must be identical.",_NSMethodExceptionProem(self,_cmd), objects.count, indexes.count];
        }
        else if (indexes.lastIndex >= objects.count && indexes.lastIndex != NSNotFound) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        else {
            id mutableCopy = [objects mutableCopy];
            [mutableCopy insertObjects:objects atIndexes:indexes];
            _DSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
            [mutableCopy release];
        }
    }
}


- (void)removeLastObject {
    NSMutableArray *arrayValue = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [arrayValue removeLastObject];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}


- (void)removeObjectAtIndex:(NSUInteger)index {
    NSMutableArray *arrayValue = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [arrayValue removeObjectAtIndex:index];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    NSMutableArray *arrayValue = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [arrayValue removeObjectsAtIndexes:indexes];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    NSMutableArray *arrayValue = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [arrayValue replaceObjectAtIndex:index withObject:anObject];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    NSMutableArray *arrayValue = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [arrayValue replaceObjectsAtIndexes:indexes withObjects:objects];
    _DSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

@end
