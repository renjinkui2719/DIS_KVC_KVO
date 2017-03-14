//
//  NSUserDefaults+NSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSUserDefaults+NSKeyValueCoding.h"

@implementation NSUserDefaults (NSKeyValueCoding)

- (id)valueForKey:(NSString *)key {
    NSString *subKey = nil;
    if(key.length && [key characterAtIndex:0] == '@' && (subKey = [key substringWithRange:NSMakeRange(1, key.length - 1)])) {
        return [super valueForKey:subKey];
    }
    else {
        return [self objectForKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if(value) {
        [self setObject:value forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end
