//
//  NSKeyValueSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueNonmutatingSetMethodSet;

@interface NSKeyValueSet : NSSet
@property (nonatomic, strong) id container;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, strong) NSKeyValueNonmutatingSetMethodSet *methods;
@end
