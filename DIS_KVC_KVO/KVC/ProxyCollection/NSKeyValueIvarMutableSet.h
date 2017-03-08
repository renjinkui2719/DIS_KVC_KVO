//
//  NSKeyValueIvarMutableSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableSet.h"

@interface NSKeyValueIvarMutableSet : NSKeyValueMutableSet
@property (nonatomic, assign) struct objc_ivar *ivar;
@end
