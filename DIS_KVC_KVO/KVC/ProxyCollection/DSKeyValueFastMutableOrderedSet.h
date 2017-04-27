//
//  DSKeyValueFastMutableOrderedSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableOrderedSet.h"

@class DSKeyValueMutatingOrderedSetMethodSet;
@class DSKeyValueNonmutatingOrderedSetMethodSet;
@class DSKeyValueGetter;

@interface DSKeyValueFastMutableOrderedSet : DSKeyValueMutableOrderedSet
@property (nonatomic, strong) DSKeyValueMutatingOrderedSetMethodSet *mutatingMethods;
@end

@interface DSKeyValueFastMutableOrderedSet1 : DSKeyValueFastMutableOrderedSet
@property (nonatomic, strong) DSKeyValueNonmutatingOrderedSetMethodSet *nonmutatingMethods;
@end

@interface DSKeyValueFastMutableOrderedSet2 : DSKeyValueFastMutableOrderedSet
@property (nonatomic, strong) DSKeyValueGetter *valueGetter;
@end
