//
//  DSKeyValueSlowMutableCollectionGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSlowMutableCollectionGetter.h"
#import "DSKeyValueUndefinedGetter.h"
#import "DSKeyValueUndefinedSetter.h"
#import "DSKeyValueSlowGetter.h"
#import "DSKeyValueSlowSetter.h"

@implementation DSKeyValueSlowMutableCollectionGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key baseGetter:(DSKeyValueGetter *)baseGetter baseSetter:(DSKeyValueSetter*)baseSetter containerIsa:(Class)containerIsa proxyClass:(Class)proxyClass {
    if ((self = [super initWithContainerClassID:containerClassID key:key proxyClass:proxyClass])) {
        if([baseGetter isKindOfClass:DSKeyValueUndefinedGetter.self]) {
            _baseGetter = [[DSKeyValueSlowGetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:containerIsa];
        }
        else {
            _baseGetter = [baseGetter retain];
        }
        
        if([baseSetter isKindOfClass:DSKeyValueUndefinedSetter.self]) {
            _baseSetter = [[DSKeyValueSlowSetter alloc] initWithContainerClassID:containerClassID key:key containerIsa:containerIsa];
        }
        else {
            _baseSetter = [baseSetter retain];
        }
    }
    return self;
}

- (BOOL)treatNilValuesLikeEmptyCollections {
    return [_baseSetter isKindOfClass:DSKeyValueSlowGetter.self] || [_baseSetter isKindOfClass:DSKeyValueUndefinedGetter.self];
}

- (void)dealloc {
    [_baseSetter release];
    [_baseGetter release];
    [super dealloc];
}

@end
