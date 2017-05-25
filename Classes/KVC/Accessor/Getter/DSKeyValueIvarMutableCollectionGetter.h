//
//  DSKeyValueIvarMutableCollectionGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyGetter.h"

@interface DSKeyValueIvarMutableCollectionGetter : DSKeyValueProxyGetter
@property (nonatomic, assign) struct objc_ivar *ivar;

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa ivar:(struct objc_ivar *)ivar proxyClass:(Class)proxyClass;

@end
