//
//  DSKeyValueNotifyingMutableCollectionGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyGetter.h"

@interface DSKeyValueNotifyingMutableCollectionGetter : DSKeyValueProxyGetter
@property (nonatomic, strong) DSKeyValueProxyGetter *mutableCollectionGetter;
- (id)initWithContainerClassID:(id)containerClassID key:(id)key mutableCollectionGetter:(id)mutableCollectionGetter proxyClass:(Class)proxyClass;
@end
