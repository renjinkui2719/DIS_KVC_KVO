//
//  NSKeyValueIvarMutableOrderedSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableOrderedSet.h"

@interface NSKeyValueIvarMutableOrderedSet : NSKeyValueMutableOrderedSet
@property (nonatomic, assign) struct objc_ivar *_ivar;
@end
