//
//  NSKeyValueMutableArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSKeyValueProxyCaching.h"

@class NSKeyValueGetter;

@interface NSKeyValueMutableArray : NSMutableArray<NSKeyValueProxyCaching>
@property (nonatomic, strong) NSObject *container;
@property (nonatomic, copy) NSString *key;

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter;
@end
