//
//  NSURL+DSKeyValueObservingCustomization.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/29.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSURL+DSKeyValueObservingCustomization.h"

@implementation NSURL (DSKeyValueObservingCustomization)

+ (BOOL)d_automaticallyNotifiesObserversForKey:(NSString *)key {
    return NO;
}

@end
