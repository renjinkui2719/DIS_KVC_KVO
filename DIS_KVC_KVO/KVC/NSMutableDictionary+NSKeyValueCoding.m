//
//  NSMutableDictionary+NSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSMutableDictionary+NSKeyValueCoding.h"

@implementation NSMutableDictionary (NSKeyValueCoding)

- (void)setValue:(id)value forKey:(NSString *)key {
    if(value) {
        [self setObject:value forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end
