//
//  DSKeyValueFastMutableCollection2Getter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyGetter.h"
@class DSKeyValueGetter;
@class DSKeyValueMutatingCollectionMethodSet;

@interface DSKeyValueFastMutableCollection2Getter : DSKeyValueProxyGetter
@property(nonatomic, strong) DSKeyValueGetter *baseGetter;
@property(nonatomic, strong) DSKeyValueMutatingCollectionMethodSet *mutatingMethods;
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key baseGetter:(DSKeyValueGetter *)baseGetter mutatingMethods:(DSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass;
@end
