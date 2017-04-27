//
//  DSKeyValueNotifyingMutableOrderedSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutableOrderedSet.h"

@interface DSKeyValueNotifyingMutableOrderedSet : DSKeyValueMutableOrderedSet

@property(nonatomic, strong) NSMutableOrderedSet *mutableOrderedSet;

@end
