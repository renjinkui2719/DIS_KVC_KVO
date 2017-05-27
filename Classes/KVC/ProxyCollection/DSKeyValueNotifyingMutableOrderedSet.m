//
//  DSKeyValueNotifyingMutableOrderedSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueNotifyingMutableOrderedSet.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueObserverNotification.h"
#import "DSKeyValueProxyGetter.h"

@implementation DSKeyValueNotifyingMutableOrderedSet
- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _mutableOrderedSet = [_DSGetProxyValueWithGetterNoLock(self.container, [getter mutableCollectionGetter]) retain];
    }
    return self;
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return &proxyPool;
}

+ (NSHashTable *)_proxyShare {
    static NSHashTable * proxyShare = nil;
    if(!proxyShare) {
        proxyShare = [_DSKeyValueProxyShareCreate() retain];
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
    [self.container d_willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet insertObject:object atIndex:idx];
    
    [self.container d_didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    [indexes release];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    [self.container d_willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet insertObjects:objects atIndexes:indexes];
    
    [self.container d_didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
}

- (void)removeObjectAtIndex:(NSUInteger)idx {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [self.container d_willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet removeObjectAtIndex:idx];
    
    [self.container d_didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    [indexes release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    [self.container d_willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet removeObjectsAtIndexes:indexes];
    
    [self.container d_didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [self.container d_willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet replaceObjectAtIndex:idx withObject:object];
    
    [self.container d_didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    [indexes release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    [self.container d_willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableOrderedSet replaceObjectsAtIndexes:indexes withObjects:objects];
    
    [self.container d_didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
}

@end
