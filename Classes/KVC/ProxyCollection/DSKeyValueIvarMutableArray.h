//
//  DSKeyValueIvarMutableArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableArray.h"

@interface DSKeyValueIvarMutableArray : DSKeyValueMutableArray
@property (nonatomic, assign) struct objc_ivar *ivar;
@end
