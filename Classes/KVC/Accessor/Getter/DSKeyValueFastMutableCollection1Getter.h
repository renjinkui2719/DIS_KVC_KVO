//
//  DSKeyValueFastMutableCollection1Getter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyGetter.h"

@class DSKeyValueNonmutatingCollectionMethodSet;
@class DSKeyValueMutatingCollectionMethodSet;

@interface DSKeyValueFastMutableCollection1Getter : DSKeyValueProxyGetter
@property (nonatomic, strong) DSKeyValueNonmutatingCollectionMethodSet *nonmutatingMethods;
@property (nonatomic, strong) DSKeyValueMutatingCollectionMethodSet *mutatingMethods;


- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key nonmutatingMethods:(DSKeyValueNonmutatingCollectionMethodSet *)nonmutatingMethods mutatingMethods:(DSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass;
@end
