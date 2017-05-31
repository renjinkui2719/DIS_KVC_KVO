//
//  DSKeyValueIvarMutableArray.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueIvarMutableArray.h"
#import "DSKeyValueCodingCommon.h"
#import "DSKeyValueIvarMutableCollectionGetter.h"


@implementation DSKeyValueIvarMutableArray

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueIvarMutableCollectionGetter *)getter {
    if ((self = [super _proxyInitWithContainer:container getter:getter])) {
        _ivar = [getter ivar];
    }
    return self;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

- (id)_nonNilMutableArrayValueWithSelector:(SEL)selector {
    id value = object_getIvarDirectly(self.container, _ivar);
    if (!value) {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return value;
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector {
    [NSException raise:NSInternalInconsistencyException format:@"%@: value for key %@ of object %p is nil", _NSMethodExceptionProem(self,selector), self.key, self.container];
}

- (void)_proxyNonGCFinalize {
    [super _proxyNonGCFinalize];
    _ivar = NULL;
}

- (NSUInteger)count {
    return [object_getIvarDirectly(self.container, _ivar) count];
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    [[self _nonNilMutableArrayValueWithSelector:_cmd] getObjects:objects range:range];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [[self _nonNilMutableArrayValueWithSelector:_cmd] objectAtIndex:index];
}

- (NSArray<id> *)objectsAtIndexes:(NSIndexSet *)indexes {
    return [[self _nonNilMutableArrayValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (void)addObject:(id)anObject {
    NSMutableArray *arrayValue = object_getIvarDirectly(self.container, _ivar);
    if (arrayValue) {
        [arrayValue addObject:anObject];
    }
    else {
        arrayValue = [[NSMutableArray alloc] initWithObjects:&anObject count:1];
        object_setIvarDirectly(self.container, _ivar, arrayValue);
    }
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    NSMutableArray *arrayValue = object_getIvarDirectly(self.container, _ivar);
    if (arrayValue) {
        [arrayValue insertObject:anObject atIndex:index];
    }
    else {
        if (index != 0) {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        arrayValue = [[NSMutableArray alloc] initWithObjects:&anObject count:1];
        object_setIvarDirectly(self.container, _ivar, arrayValue);
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    NSMutableArray *arrayValue = object_getIvarDirectly(self.container, _ivar);
    if (arrayValue) {
        [arrayValue insertObjects:objects atIndexes:indexes];
    }
    else {
        if (objects && indexes) {
            [NSException raise:NSInvalidArgumentException format:@"%@: the %@ must not be nil.", _NSMethodExceptionProem(self, _cmd), !objects ? @"passed-in array":@"index set"];
        }
        else if (objects.count != indexes.count) {
            [NSException raise:NSInvalidArgumentException format:@"%@: the counts of the passed-in array (%lu) and index set (%lu) must be identical.", _NSMethodExceptionProem(self, _cmd), objects.count, indexes.count];
        }
        else if (indexes.lastIndex >= objects.count && indexes.lastIndex != NSNotFound){
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        else {
            object_setIvarDirectly(self.container, _ivar, objects.mutableCopy);
        }
    }
}

- (void)removeLastObject {
    [[self _nonNilMutableArrayValueWithSelector:_cmd] removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [[self _nonNilMutableArrayValueWithSelector:_cmd] removeObjectAtIndex:index];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    [[self _nonNilMutableArrayValueWithSelector:_cmd] removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [[self _nonNilMutableArrayValueWithSelector:_cmd] replaceObjectAtIndex:index withObject:anObject];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    [[self _nonNilMutableArrayValueWithSelector:_cmd] replaceObjectsAtIndexes:indexes withObjects:objects];
}

@end
