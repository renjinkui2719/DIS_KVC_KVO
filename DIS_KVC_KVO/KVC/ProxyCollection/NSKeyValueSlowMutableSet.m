//
//  NSKeyValueSlowMutableSet.m
//  KV
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueSlowMutableSet.h"
#import "NSObject+NSKeyValueCodingPrivate.h"
#import "NSKeyValueNilSetEnumerator.h"

@implementation NSKeyValueSlowMutableSet

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _valueGetter = [[getter baseGetter] retain];
        _valueSetter = [[getter baseSetter] retain];
        _treatNilValuesLikeEmptySets = [getter treatNilValuesLikeEmptyCollections];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    [_valueGetter release];
    [_valueSetter release];
    _valueGetter = nil;
    _valueSetter = nil;
    [super _proxyNonGCFinalize];
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool = {0};
    return  &proxyPool;
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector {
    [NSException raise:NSInternalInconsistencyException format:@"%@: value for key %@ of object %p is nil", _NSMethodExceptionProem(self,selector), self.key, self.container];
}

- (NSSet *)_setValueWithSelector:(SEL)selector {
    NSSet * value = _NSGetUsingKeyValueGetter(self.container, _valueGetter);
    if(!value && !_treatNilValuesLikeEmptySets) {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return value;
}

- (NSUInteger)count {
    [[self _setValueWithSelector:_cmd] count];
}

- (id)member:(id)object {
    [[self _setValueWithSelector:_cmd] member:object];
}

- (NSEnumerator *)objectEnumerator {
    NSSet *setValue = [self _setValueWithSelector:_cmd];
    if(setValue) {
        return setValue.objectEnumerator;
    }
    else {
        return [[[NSKeyValueNilSetEnumerator alloc] init] autorelease];
    }
}

- (NSMutableSet *)_createMutableSetValueWithSelector:(SEL)selector {
    NSSet * value = _NSGetUsingKeyValueGetter(self.container, _valueGetter);
    if(!value && !_treatNilValuesLikeEmptySets) {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return [value mutableCopy];
}

- (void)addObject:(id)object {
    NSMutableSet *setValue = [self _createMutableSetValueWithSelector:_cmd];
    if(setValue) {
        [setValue addObject:object];
    }
    else {
        setValue = [[NSMutableSet alloc] initWithObjects:&object count:1];
    }
    
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, setValue);
    
    [setValue release];
}

- (void)addObjectsFromArray:(NSArray *)array {
    NSMutableSet *setValue = [self _createMutableSetValueWithSelector:_cmd];
    if(setValue) {
        [setValue addObjectsFromArray:array];
    }
    else {
        setValue = [[NSMutableSet alloc] initWithArray:array];
    }
    
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, setValue);

    [setValue release];
}

- (void)intersectSet:(NSSet *)otherSet {
    NSMutableSet *setValue = [self _createMutableSetValueWithSelector:_cmd];
    if(setValue) {
        [setValue intersectSet:otherSet];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, setValue);
        [setValue release];
    }
}

- (void)minusSet:(NSSet *)otherSet {
    NSMutableSet *setValue = [self _createMutableSetValueWithSelector:_cmd];
    if(setValue) {
        [setValue minusSet:otherSet];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, setValue);
        [setValue release];
    }
}

- (void)removeAllObjects {
    if(!_treatNilValuesLikeEmptySets) {
        if(!_NSGetUsingKeyValueGetter(self.container, _valueGetter)) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
    }
    
    NSSet *setValue = [[NSSet alloc] init];
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, setValue);
    [setValue release];
}


- (void)removeObject:(id)object {
    NSMutableSet *setValue = [self _createMutableSetValueWithSelector:_cmd];
    if(setValue) {
        [setValue removeObject:object];
        _NSSetUsingKeyValueSetter(self.container, _valueSetter, setValue);
        [setValue release];
    }
}

- (void)setSet:(NSSet *)otherSet {
    if(!_treatNilValuesLikeEmptySets) {
        if(!_NSGetUsingKeyValueGetter(self.container, _valueGetter)) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
    }
    
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, otherSet);
}

- (void)unionSet:(NSSet *)otherSet {
    NSMutableSet *setValue = [self _createMutableSetValueWithSelector:_cmd];
    if(setValue) {
        [setValue unionSet:otherSet];
    }
    else {
        setValue = [otherSet mutableCopy];
    }
    _NSSetUsingKeyValueSetter(self.container, _valueSetter, setValue);
    [setValue release];
}

@end
