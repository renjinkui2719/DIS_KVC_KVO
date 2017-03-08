//
//  NSKeyValueNotifyingMutableOrderedSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueNotifyingMutableOrderedSet.h"
#import "NSKeyValueGetter.h"

@implementation NSKeyValueNotifyingMutableOrderedSet
- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _mutableOrderedSet = [_NSGetProxyValueWithGetterNoLock(self.container, [getter mutableCollectionGetter]) retain];
    }
    return self;
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static NSKeyValueProxyNonGCPoolPointer proxyPool = {0};
    return &proxyPool;
}

+ (NSHashTable *)_proxyShare {
    static NSHashTable * proxyShare = nil;
    if(!proxyShare) {
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    }
    return proxyShare;
}

- (void)_proxyNonGCFinalize {
    [_mutableOrderedSet release];
    _mutableOrderedSet = nil;
    [super _proxyNonGCFinalize];
}

- (NSUInteger)count {
    return _mutableOrderedSet.count;
}

- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    [_mutableOrderedSet getObjects:objects range:range];
}

- (NSUInteger)indexOfObject:(id)object {
    return [_mutableOrderedSet indexOfObject:object];
}

- (id)objectAtIndex:(NSUInteger)idx {
    return [_mutableOrderedSet objectAtIndex:idx];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    return [_mutableOrderedSet objectsAtIndexes:indexes];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [self.container willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet insertObject:object atIndex:idx];
    
    [self.container didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    [indexes release];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    [self.container willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet insertObjects:objects atIndexes:indexes];
    
    [self.container didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
}

- (void)removeObjectAtIndex:(NSUInteger)idx {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [self.container willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet removeObjectAtIndex:idx];
    
    [self.container didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    [indexes release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    [self.container willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet removeObjectsAtIndexes:indexes];
    
    [self.container didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [self.container willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet replaceObjectAtIndex:idx withObject:object];
    
    [self.container didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    [indexes release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    [self.container willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet replaceObjectsAtIndexes:indexes withObjects:objects];
    
    [self.container didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
}

@end
