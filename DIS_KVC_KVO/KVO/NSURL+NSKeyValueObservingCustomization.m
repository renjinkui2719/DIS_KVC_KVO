//
//  NSURL+NSKeyValueObservingCustomization.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/29.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSURL+NSKeyValueObservingCustomization.h"

@implementation NSURL (NSKeyValueObservingCustomization)

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return NO;
}

@end
