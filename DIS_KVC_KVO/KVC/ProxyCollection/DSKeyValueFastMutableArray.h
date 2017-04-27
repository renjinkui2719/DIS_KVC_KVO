//
//  DSKeyValueFastMutableArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableArray.h"

@class DSKeyValueMutatingArrayMethodSet;
@class DSKeyValueNonmutatingArrayMethodSet;
@class DSKeyValueGetter;

@interface DSKeyValueFastMutableArray : DSKeyValueMutableArray
@property (nonatomic, strong) DSKeyValueMutatingArrayMethodSet *mutatingMethods;
@end

@interface DSKeyValueFastMutableArray1 : DSKeyValueFastMutableArray
@property (nonatomic, strong) DSKeyValueNonmutatingArrayMethodSet *nonmutatingMethods;
@end

@interface DSKeyValueFastMutableArray2 : DSKeyValueFastMutableArray
@property (nonatomic, strong) DSKeyValueGetter *valueGetter;
@end
