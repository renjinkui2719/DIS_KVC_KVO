//
//  NSKeyValueFastMutableCollection1Getter.h
//  KV
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyGetter.h"

@class NSKeyValueNonmutatingCollectionMethodSet;
@class NSKeyValueMutatingCollectionMethodSet;

@interface NSKeyValueFastMutableCollection1Getter : NSKeyValueProxyGetter
@property (nonatomic, strong) NSKeyValueNonmutatingCollectionMethodSet *nonmutatingMethods;
@property (nonatomic, strong) NSKeyValueMutatingCollectionMethodSet *mutatingMethods;

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key nonmutatingMethods:(NSKeyValueNonmutatingCollectionMethodSet *)nonmutatingMethods mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass;
@end
