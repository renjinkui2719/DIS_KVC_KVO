//
//  NSKeyValueProxyGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueGetter.h"

@interface NSKeyValueProxyGetter : NSKeyValueGetter
@property (nonatomic, assign) Class proxyClass;
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key proxyClass:(Class)proxyClass;
@end
