//
//  DSKeyValueProxyGetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueGetter.h"

@class DSKeyValueProxyGetter;

extern id _DSGetProxyValueWithGetterNoLock(id object, DSKeyValueProxyGetter *getter);
extern id _DSGetProxyValueWithGetter(id object, SEL selector, DSKeyValueProxyGetter *getter);

@interface DSKeyValueProxyGetter : DSKeyValueGetter

@property (nonatomic, assign) Class proxyClass;
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key proxyClass:(Class)proxyClass;

@end
