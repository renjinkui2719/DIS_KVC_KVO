//
//  DSKeyValueCollectionGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyGetter.h"

@class DSKeyValueNonmutatingCollectionMethodSet;

@interface DSKeyValueCollectionGetter : DSKeyValueProxyGetter
@property (nonatomic, strong) DSKeyValueNonmutatingCollectionMethodSet *methods;
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key methods:(DSKeyValueNonmutatingCollectionMethodSet *)methods proxyClass:(Class)proxyClass;
@end
