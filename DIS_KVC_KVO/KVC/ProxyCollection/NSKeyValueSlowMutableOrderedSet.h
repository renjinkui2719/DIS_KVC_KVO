//
//  NSKeyValueSlowMutableOrderedSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableOrderedSet.h"

@class NSKeyValueGetter;
@class NSKeyValueSetter;

@interface NSKeyValueSlowMutableOrderedSet : NSKeyValueMutableOrderedSet
@property (nonatomic, strong) NSKeyValueGetter *valueGetter;
@property (nonatomic, strong) NSKeyValueSetter *valueSetter;
@property (nonatomic, assign) BOOL treatNilValuesLikeEmptyOrderedSets;
@end
