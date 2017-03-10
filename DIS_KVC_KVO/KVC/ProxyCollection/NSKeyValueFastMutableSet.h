//
//  NSKeyValueFastMutableSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableSet.h"

@class NSKeyValueMutatingSetMethodSet;
@class NSKeyValueNonmutatingSetMethodSet;
@class NSKeyValueGetter;

@interface NSKeyValueFastMutableSet : NSKeyValueMutableSet
@property (nonatomic, strong) NSKeyValueMutatingSetMethodSet *mutatingMethods;
@end


@interface NSKeyValueFastMutableSet1 : NSKeyValueFastMutableSet
@property (nonatomic, strong) NSKeyValueNonmutatingSetMethodSet *nonmutatingMethods;
@end



@interface NSKeyValueFastMutableSet2 : NSKeyValueFastMutableSet
@property (nonatomic, strong) NSKeyValueGetter *valueGetter;
@end
