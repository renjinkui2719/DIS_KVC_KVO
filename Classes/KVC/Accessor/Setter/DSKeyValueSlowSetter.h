//
//  DSKeyValueSlowSetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/9.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSetter.h"

@interface DSKeyValueSlowSetter : DSKeyValueSetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa;

@end
