//
//  NSKeyValueSlowMutableSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableSet.h"

@class NSKeyValueGetter;
@class NSKeyValueSetter;

@interface NSKeyValueSlowMutableSet : NSKeyValueMutableSet

@property (nonatomic, strong) NSKeyValueGetter *valueGetter;
@property (nonatomic, strong) NSKeyValueSetter *valueSetter;
@property (nonatomic, assign) BOOL treatNilValuesLikeEmptySets;

@end
