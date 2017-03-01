//
//  NSKeyValueFastMutableArray.h
//  KV
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableArray.h"

@class NSKeyValueMutatingArrayMethodSet;
@class NSKeyValueNonmutatingArrayMethodSet;
@class NSKeyValueGetter;

@interface NSKeyValueFastMutableArray : NSKeyValueMutableArray
@property (nonatomic, strong) NSKeyValueMutatingArrayMethodSet *mutatingMethods;
@end

@interface NSKeyValueFastMutableArray1 : NSKeyValueFastMutableArray
@property (nonatomic, strong) NSKeyValueNonmutatingArrayMethodSet *nonmutatingMethods;
@end

@interface NSKeyValueFastMutableArray2 : NSKeyValueFastMutableArray
@property (nonatomic, strong) NSKeyValueGetter *valueGetter;
@end
