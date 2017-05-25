//
//  DSKeyValueFastMutableSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableSet.h"

@class DSKeyValueMutatingSetMethodSet;
@class DSKeyValueNonmutatingSetMethodSet;
@class DSKeyValueGetter;

@interface DSKeyValueFastMutableSet : DSKeyValueMutableSet
@property (nonatomic, strong) DSKeyValueMutatingSetMethodSet *mutatingMethods;
@end


@interface DSKeyValueFastMutableSet1 : DSKeyValueFastMutableSet
@property (nonatomic, strong) DSKeyValueNonmutatingSetMethodSet *nonmutatingMethods;
@end



@interface DSKeyValueFastMutableSet2 : DSKeyValueFastMutableSet
@property (nonatomic, strong) DSKeyValueGetter *valueGetter;
@end
