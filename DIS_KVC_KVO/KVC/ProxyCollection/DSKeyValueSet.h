//
//  DSKeyValueSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueProxyCaching.h"

@class DSKeyValueNonmutatingSetMethodSet;
@class DSKeyValueGetter;

@interface DSKeyValueSet : NSSet<DSKeyValueProxyCaching>
@property (nonatomic, strong) id container;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, strong) DSKeyValueNonmutatingSetMethodSet *methods;

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter ;

@end
