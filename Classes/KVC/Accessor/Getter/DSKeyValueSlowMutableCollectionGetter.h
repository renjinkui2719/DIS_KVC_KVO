//
//  DSKeyValueSlowMutableCollectionGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyGetter.h"
@class DSKeyValueSetter;

@interface DSKeyValueSlowMutableCollectionGetter : DSKeyValueProxyGetter
@property(nonatomic, strong) DSKeyValueGetter *baseGetter;;
@property(nonatomic, strong) DSKeyValueSetter *baseSetter;

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key baseGetter:(DSKeyValueGetter *)baseGetter baseSetter:(DSKeyValueSetter*)baseSetter containerIsa:(Class)containerIsa proxyClass:(Class)proxyClass;
- (BOOL)treatNilValuesLikeEmptyCollections;

@end
