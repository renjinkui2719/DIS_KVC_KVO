//
//  NSNull+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSNull+DSKeyValueCoding.h"

@implementation NSNull (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    return self;
}

@end
