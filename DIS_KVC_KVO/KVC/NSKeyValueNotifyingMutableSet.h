//
//  NSKeyValueNotifyingMutableSet.h
//  KV
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableSet.h"

@interface NSKeyValueNotifyingMutableSet : NSKeyValueMutableSet

@property (nonatomic, strong) NSMutableSet *mutableSet;;

@end
