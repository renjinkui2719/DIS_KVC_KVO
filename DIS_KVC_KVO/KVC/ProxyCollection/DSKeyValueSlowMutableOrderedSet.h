//
//  DSKeyValueSlowMutableOrderedSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableOrderedSet.h"

@class DSKeyValueGetter;
@class DSKeyValueSetter;

@interface DSKeyValueSlowMutableOrderedSet : DSKeyValueMutableOrderedSet
@property (nonatomic, strong) DSKeyValueGetter *valueGetter;
@property (nonatomic, strong) DSKeyValueSetter *valueSetter;
@property (nonatomic, assign) BOOL treatNilValuesLikeEmptyOrderedSets;
@end
