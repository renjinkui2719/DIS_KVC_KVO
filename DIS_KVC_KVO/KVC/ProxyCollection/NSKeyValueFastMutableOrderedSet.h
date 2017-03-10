//
//  NSKeyValueFastMutableOrderedSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableOrderedSet.h"

@class NSKeyValueMutatingOrderedSetMethodSet;
@class NSKeyValueNonmutatingOrderedSetMethodSet;
@class NSKeyValueGetter;

@interface NSKeyValueFastMutableOrderedSet : NSKeyValueMutableOrderedSet
@property (nonatomic, strong) NSKeyValueMutatingOrderedSetMethodSet *mutatingMethods;
@end

@interface NSKeyValueFastMutableOrderedSet1 : NSKeyValueFastMutableOrderedSet
@property (nonatomic, strong) NSKeyValueNonmutatingOrderedSetMethodSet *nonmutatingMethods;
@end

@interface NSKeyValueFastMutableOrderedSet2 : NSKeyValueFastMutableOrderedSet
@property (nonatomic, strong) NSKeyValueGetter *valueGetter;
@end
