//
//  DSKeyValueIvarMutableSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableSet.h"

@interface DSKeyValueIvarMutableSet : DSKeyValueMutableSet
@property (nonatomic, assign) struct objc_ivar *ivar;
@end
