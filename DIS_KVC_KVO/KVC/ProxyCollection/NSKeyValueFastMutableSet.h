//
//  NSKeyValueFastMutableSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableSet.h"

@class NSKeyValueMutatingSetMethodSet;

@interface NSKeyValueFastMutableSet : NSKeyValueMutableSet
@property (nonatomic, strong) NSKeyValueMutatingSetMethodSet *mutatingMethods;
@end

@class NSKeyValueNonmutatingSetMethodSet;
@interface NSKeyValueFastMutableSet1 : NSKeyValueFastMutableSet
@property (nonatomic, strong) NSKeyValueNonmutatingSetMethodSet *nonmutatingMethods;
@end

@class NSKeyValueGetter;
@interface NSKeyValueFastMutableSet2 : NSKeyValueFastMutableSet
@property (nonatomic, strong) NSKeyValueGetter *valueGetter;
@end
