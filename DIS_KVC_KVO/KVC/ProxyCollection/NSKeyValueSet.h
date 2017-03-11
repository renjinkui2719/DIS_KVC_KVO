//
//  NSKeyValueSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSKeyValueProxyCaching.h"

@class NSKeyValueNonmutatingSetMethodSet;
@class NSKeyValueGetter;

@interface NSKeyValueSet : NSSet<NSKeyValueProxyCaching>
@property (nonatomic, strong) id container;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, strong) NSKeyValueNonmutatingSetMethodSet *methods;

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter ;

@end
