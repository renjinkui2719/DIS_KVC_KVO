//
//  NSMutableDictionary+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSMutableDictionary+DSKeyValueCoding.h"

@implementation NSMutableDictionary (DSKeyValueCoding)

- (void)d_setValue:(id)value forKey:(NSString *)key {
    if(value) {
        [self setObject:value forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end
