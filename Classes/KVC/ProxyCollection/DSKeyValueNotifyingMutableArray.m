//
//  DSKeyValueNotifyingMutableArray.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueNotifyingMutableArray.h"
#import "DSKeyValueNotifyingMutableCollectionGetter.h"
#import "NSObject+DSKeyValueObserverRegistration.h"
#import "NSObject+DSKeyValueObserverNotification.h"

@implementation DSKeyValueNotifyingMutableArray

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueNotifyingMutableCollectionGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _mutableArray = [_DSGetProxyValueWithGetterNoLock(self.container, [getter mutableCollectionGetter]) retain];
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
    [_mutableArray release];
    [super _proxyNonGCFinalize];
}

- (NSUInteger)count {
    return _mutableArray.count;
}

- (void)addObject:(id)anObject {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:_mutableArray.count];
    [self.container d_willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray addObject:anObject];
    
    [self.container d_didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [indexes release];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:index];
    [self.container d_willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray insertObject:anObject atIndex:index];
    
    [self.container d_didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [indexes release];
}


- (void)getObjects:(id  _Nonnull *)objects range:(NSRange)range {
    [_mutableArray getObjects:objects range:range];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_mutableArray objectAtIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:index];
    [self.container d_willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray removeObjectAtIndex:index];
    
    [self.container d_didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [indexes release];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    return [_mutableArray objectsAtIndexes:indexes];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    [self.container d_willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray insertObjects:objects atIndexes:indexes];
    
    [self.container d_didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
}

- (void)removeLastObject {
     NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:_mutableArray.count];
    [self.container d_willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray removeLastObject];
    
    [self.container d_didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [indexes release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    [self.container d_willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray removeObjectsAtIndexes:indexes];
    
    [self.container d_didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
}


- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:index];
    [self.container d_willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray replaceObjectAtIndex:index withObject:anObject];
    
    [self.container d_didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    
    [indexes release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    [self.container d_willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
    
    [_mutableArray replaceObjectsAtIndexes:indexes withObjects:objects];
    
    [self.container d_didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
}

@end
