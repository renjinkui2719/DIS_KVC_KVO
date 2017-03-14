//
//  NSKeyValueMethodSetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueSetter.h"

@interface NSKeyValueMethodSetter : NSKeyValueSetter
@property (nonatomic, assign) struct objc_method * method;

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key method:(Method)method;
@end
