//
//  NSKeyValueSlowMutableArray.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueSlowMutableArray.h"
#import "NSKeyValueSlowMutableCollectionGetter.h"
#import "NSObject+NSKeyValueCodingPrivate.h"

extern NSString * _NSMethodExceptionProem(id,SEL);

@implementation NSKeyValueSlowMutableArray

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueSlowMutableCollectionGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _valueGetter = [[getter baseGetter] retain];
        _valueSetter = [[getter baseSetter] retain];
        _treatNilValuesLikeEmptyArrays = [getter treatNilValuesLikeEmptyCollections];
    }
    return self;
}

- (id)_nonNilArrayValueWithSelector:(SEL)selector {
    id value = _NSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (!value) {
        [self _raiseNilValueExceptionWithSelector: selector];
    }
    return value;
}

- (id)_createNonNilMutableArrayValueWithSelector:(SEL)selector {
    id value = _NSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (!value) {
        [self _raiseNilValueExceptionWithSelector: selector];
    }
    return [value mutableCopy];
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

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (NSUInteger)count {
    id value = _NSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (!value && !_treatNilValuesLikeEmptyArrays) {
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
    return [value count];
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
    id value = _NSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (value) {
        id mutableCopy = [value mutableCopy];
        [mutableCopy addObject:anObject];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
    else {
        if (!_treatNilValuesLikeEmptyArrays) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:&anObject count:1];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, mutableArray);
        [mutableArray release];
    }
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    id value = _NSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (value) {
        id mutableCopy = [value mutableCopy];
        [mutableCopy insertObject:anObject atIndex:index];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
        [mutableCopy release];
    }
    else {
        if (index != 0 || !_treatNilValuesLikeEmptyArrays) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:&anObject count:1];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, mutableArray);
        [mutableArray release];
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    id value = _NSGetUsingKeyValueGetter(self.container, self.valueGetter);
    if (value) {
        id mutableCopy = [value mutableCopy];
        [mutableCopy insertObjects:objects atIndexes:indexes];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
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
            _NSSetUsingKeyValueSetter(self.container, _valueSetter, mutableCopy);
            [mutableCopy release];
        }
    }
}


- (void)removeLastObject {
    NSMutableArray *arrayValue = [self _nonNilArrayValueWithSelector:_cmd];
    [arrayValue removeLastObject];
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}


- (void)removeObjectAtIndex:(NSUInteger)index {
    NSMutableArray *arrayValue = [self _nonNilArrayValueWithSelector:_cmd];
    [arrayValue removeObjectAtIndex:index];
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    NSMutableArray *arrayValue = [self _nonNilArrayValueWithSelector:_cmd];
    [arrayValue removeObjectsAtIndexes:indexes];
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    NSMutableArray *arrayValue = [self _nonNilArrayValueWithSelector:_cmd];
    [arrayValue replaceObjectAtIndex:index withObject:anObject];
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    NSMutableArray *arrayValue = [self _nonNilArrayValueWithSelector:_cmd];
    [arrayValue replaceObjectsAtIndexes:indexes withObjects:objects];
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, arrayValue);
    [arrayValue release];
}

@end
