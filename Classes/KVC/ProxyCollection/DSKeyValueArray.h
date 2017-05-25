//
//  DSKeyValueArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueProxyCaching.h"

@class DSKeyValueNonmutatingArrayMethodSet;
@class DSKeyValueGetter;

@interface DSKeyValueArray : NSArray <DSKeyValueProxyCaching>

@property(nonatomic, strong) NSObject *container;
@property(nonatomic, copy) NSString *key;
@property(nonatomic, strong) DSKeyValueNonmutatingArrayMethodSet *methods;

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter;

@end
