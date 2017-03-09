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
    
}

@end
