//
//  NSKeyValueFastMutableCollection2Getter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyGetter.h"
@class NSKeyValueGetter;
@class NSKeyValueMutatingCollectionMethodSet;

@interface NSKeyValueFastMutableCollection2Getter : NSKeyValueProxyGetter
@property(nonatomic, strong) NSKeyValueGetter *baseGetter;
@property(nonatomic, strong) NSKeyValueMutatingCollectionMethodSet *mutatingMethods;
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass;
@end
