//
//  NSNull+NSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSNull+NSKeyValueCoding.h"

@implementation NSNull (NSKeyValueCoding)

- (id)valueForKey:(NSString *)key {
    return self;
}

@end
