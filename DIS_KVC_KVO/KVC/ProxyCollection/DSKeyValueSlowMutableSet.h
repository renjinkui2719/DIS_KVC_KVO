//
//  DSKeyValueSlowMutableSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableSet.h"

@class DSKeyValueGetter;
@class DSKeyValueSetter;

@interface DSKeyValueSlowMutableSet : DSKeyValueMutableSet

@property (nonatomic, strong) DSKeyValueGetter *valueGetter;
@property (nonatomic, strong) DSKeyValueSetter *valueSetter;
@property (nonatomic, assign) BOOL treatNilValuesLikeEmptySets;

@end
