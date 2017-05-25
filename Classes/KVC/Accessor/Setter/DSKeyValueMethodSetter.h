//
//  DSKeyValueMethodSetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSetter.h"

@interface DSKeyValueMethodSetter : DSKeyValueSetter
@property (nonatomic, assign) struct objc_method * method;

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key method:(Method)method;
@end
