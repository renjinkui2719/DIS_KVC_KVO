//
//  DSKeyValueUndefinedSetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSetter.h"

@interface DSKeyValueUndefinedSetter : DSKeyValueSetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa;

@end
