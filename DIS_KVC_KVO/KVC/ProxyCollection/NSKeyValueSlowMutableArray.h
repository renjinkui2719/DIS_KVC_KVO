//
//  NSKeyValueSlowMutableArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableArray.h"

@class NSKeyValueGetter;
@class NSKeyValueSetter;

@interface NSKeyValueSlowMutableArray : NSKeyValueMutableArray
@property(nonatomic, strong) NSKeyValueGetter *valueGetter;
@property(nonatomic, strong) NSKeyValueSetter *valueSetter;
@property(nonatomic, assign) BOOL treatNilValuesLikeEmptyArrays;
@end
