//
//  NSKeyValueSlowMutableCollectionGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyGetter.h"
@class NSKeyValueSetter;

@interface NSKeyValueSlowMutableCollectionGetter : NSKeyValueProxyGetter
@property(nonatomic, strong) NSKeyValueGetter *baseGetter;;
@property(nonatomic, strong) NSKeyValueSetter *baseSetter;

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter baseSetter:(NSKeyValueSetter*)baseSetter containerIsa:(Class)containerIsa proxyClass:(Class)proxyClass;
- (BOOL)treatNilValuesLikeEmptyCollections;

@end
