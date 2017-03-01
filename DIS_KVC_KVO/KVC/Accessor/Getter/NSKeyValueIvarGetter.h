//
//  NSKeyValueIvarGetter.h
//  KVOIMP
//
//  Created by JK on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueGetter.h"
#import <objc/runtime.h>

@interface NSKeyValueIvarGetter : NSKeyValueGetter
- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa ivar:(Ivar)ivar;
@end
