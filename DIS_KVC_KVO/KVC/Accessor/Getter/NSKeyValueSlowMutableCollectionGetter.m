//
//  NSKeyValueSlowMutableCollectionGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueSlowMutableCollectionGetter.h"
#import "NSKeyValueUndefinedGetter.h"
#import "NSKeyValueUndefinedSetter.h"
#import "NSKeyValueSlowGetter.h"
#import "NSKeyValueSlowSetter.h"

@implementation NSKeyValueSlowMutableCollectionGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter baseSetter:(NSKeyValueSetter*)baseSetter containerIsa:(Class)containerIsa proxyClass:(Class)proxyClass {
    if ((self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass])) {
        if([baseGetter isKindOfClass:NSKeyValueUndefinedGetter.self]) {
            _baseGetter = [[NSKeyValueSlowGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:containerIsa];
        }
        else {
            _baseGetter = [baseGetter retain];
        }
        
        if([baseSetter isKindOfClass:NSKeyValueUndefinedSetter.self]) {
            _baseSetter = [[NSKeyValueSlowSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:containerIsa];
        }
        else {
            _baseSetter = [baseSetter retain];
        }
    }
    return self;
}

- (BOOL)treatNilValuesLikeEmptyCollections {
    return [_baseSetter isKindOfClass:NSKeyValueSlowGetter.self] || [_baseSetter isKindOfClass:NSKeyValueUndefinedGetter.self];
}

- (void)dealloc {
    [_baseSetter release];
    [_baseGetter release];
    [super dealloc];
}

@end
