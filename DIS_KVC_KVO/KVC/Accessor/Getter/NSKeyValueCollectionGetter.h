//
//  NSKeyValueCollectionGetter.h
//  KVOIMP
//
//  Created by JK on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyGetter.h"

@class NSKeyValueNonmutatingCollectionMethodSet;

@interface NSKeyValueCollectionGetter : NSKeyValueProxyGetter
@property (nonatomic, strong) NSKeyValueNonmutatingCollectionMethodSet *methods;
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key methods:(NSKeyValueNonmutatingCollectionMethodSet *)methods proxyClass:(Class)proxyClass;
@end
