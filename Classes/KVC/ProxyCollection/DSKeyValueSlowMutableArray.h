//
//  DSKeyValueSlowMutableArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableArray.h"

@class DSKeyValueGetter;
@class DSKeyValueSetter;

@interface DSKeyValueSlowMutableArray : DSKeyValueMutableArray
@property(nonatomic, strong) DSKeyValueGetter *valueGetter;
@property(nonatomic, strong) DSKeyValueSetter *valueSetter;
@property(nonatomic, assign) BOOL treatNilValuesLikeEmptyArrays;
@end
