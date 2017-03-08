//
//  NSKeyValueNotifyingMutableArray.h
//  KV
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSKeyValueMutableArray.h"

@interface NSKeyValueNotifyingMutableArray : NSKeyValueMutableArray
@property (nonatomic, strong) NSMutableArray *mutableArray;

@end
