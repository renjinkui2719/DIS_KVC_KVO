//
//  NSKeyValueNotifyingMutableOrderedSet.h
//  KV
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableOrderedSet.h"

@interface NSKeyValueNotifyingMutableOrderedSet : NSKeyValueMutableOrderedSet

@property(nonatomic, strong) NSMutableOrderedSet *mutableOrderedSet;

@end
