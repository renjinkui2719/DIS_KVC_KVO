//
//  NSKeyValueIvarMutableArray.h
//  KV
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutableArray.h"

@interface NSKeyValueIvarMutableArray : NSKeyValueMutableArray
@property (nonatomic, assign) struct objc_ivar *ivar;


@end
