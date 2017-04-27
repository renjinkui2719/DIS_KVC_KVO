//
//  DSKeyValueIvarSetter.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSetter.h"

@interface DSKeyValueIvarSetter : DSKeyValueSetter

- (struct objc_ivar *)ivar;
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa ivar:(Ivar)ivar;

@end
