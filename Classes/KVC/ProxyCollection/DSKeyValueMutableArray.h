//
//  DSKeyValueMutableArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueProxyCaching.h"

@class DSKeyValueGetter;

@interface DSKeyValueMutableArray : NSMutableArray<DSKeyValueProxyCaching>
@property (nonatomic, strong) NSObject *container;
@property (nonatomic, copy) NSString *key;

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter;
@end
