//
//  NSKeyValueMutableSet.h
//  KV
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSKeyValueProxyCaching.h"


@class NSKeyValueGetter;

@interface NSKeyValueMutableSet : NSMutableSet<NSKeyValueProxyCaching>
@property(nonatomic, strong) NSObject *container;
@property(nonatomic, copy) NSString *key;

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter;
@end
