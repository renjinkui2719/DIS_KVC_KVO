//
//  NSKeyValueNotifyingMutableCollectionGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyGetter.h"

@interface NSKeyValueNotifyingMutableCollectionGetter : NSKeyValueProxyGetter
@property (nonatomic, strong) NSKeyValueProxyGetter *mutableCollectionGetter;
- (id)initWithContainerClassID:(id)containerClassID key:(id)key mutableCollectionGetter:(id)mutableCollectionGetter proxyClass:(Class)proxyClass;
@end
