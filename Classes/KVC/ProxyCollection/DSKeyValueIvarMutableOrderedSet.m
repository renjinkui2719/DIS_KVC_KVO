//
//  DSKeyValueIvarMutableOrderedSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueIvarMutableOrderedSet.h"
#import "DSKeyValueCodingCommon.h"

@implementation DSKeyValueIvarMutableOrderedSet

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    if ((self = [super _proxyInitWithContainer:container getter:getter])) {
        _ivar = [getter ivar];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    [super _proxyNonGCFinalize];
    _ivar = NULL;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector {
    [NSException raise:NSInternalInconsistencyException format:@"%@: value for key %@ of object %p is nil", _NSMethodExceptionProem(self,selector), self.key, self.container];
}

- (id)_nonNilMutableOrderedSetValueWithSelector:(SEL)selector {
    id value = object_getIvarDirectly(self.container, _ivar);
    if(!value) {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return value;
}

- (NSUInteger)count {
    return [object_getIvarDirectly(self.container, _ivar) count];
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    [[self _nonNilMutableOrderedSetValueWithSelector:_cmd] getObjects:objects range:range];
}

- (NSUInteger)indexOfObject:(id)object {
    id value = object_getIvarDirectly(self.container, _ivar);
    return value ? [value indexOfObject:object] : NSNotFound;
}

- (id)objectAtIndex:(NSUInteger)idx {
    return [[self _nonNilMutableOrderedSetValueWithSelector:_cmd] objectAtIndex:idx];
}

- (NSArray<id> *)objectsAtIndexes:(NSIndexSet *)indexes {
    return [[self _nonNilMutableOrderedSetValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
    NSMutableOrderedSet * orderSetValue = object_getIvarDirectly(self.container, _ivar);
    if(orderSetValue) {
        [orderSetValue insertObject:object atIndex:idx];
    }
    else if(idx != 0){
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
    else {
        orderSetValue = [[NSMutableOrderedSet alloc] initWithObjects:&object count:1];
        object_setIvarDirectly(self.container, _ivar, orderSetValue);
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    NSMutableOrderedSet *orderSetValue = object_getIvarDirectly(self.container, _ivar);
    if (orderSetValue) {
        [orderSetValue insertObjects:objects atIndexes:indexes];
    }
    else {
        if (objects && indexes) {
            [NSException raise:NSInvalidArgumentException format:@"%@: the %@ must not be nil.", _NSMethodExceptionProem(self, _cmd), !objects ? @"passed-in ordered set":@"index set"];
        }
        else if (objects.count != indexes.count) {
            [NSException raise:NSInvalidArgumentException format:@"%@: the counts of the passed-in ordered set (%lu) and index set (%lu) must be identical.", _NSMethodExceptionProem(self, _cmd), objects.count, indexes.count];
        }
        else if (indexes.lastIndex >= objects.count && indexes.lastIndex != NSNotFound){
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        else {
            object_setIvarDirectly(self.container, _ivar, objects.mutableCopy);
        }
    }
}


- (void)removeObjectAtIndex:(NSUInteger)index {
    [[self _nonNilMutableOrderedSetValueWithSelector:_cmd] removeObjectAtIndex:index];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    [[self _nonNilMutableOrderedSetValueWithSelector:_cmd] removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [[self _nonNilMutableOrderedSetValueWithSelector:_cmd] replaceObjectAtIndex:index withObject:anObject];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    [[self _nonNilMutableOrderedSetValueWithSelector:_cmd] replaceObjectsAtIndexes:indexes withObjects:objects];
}


@end
