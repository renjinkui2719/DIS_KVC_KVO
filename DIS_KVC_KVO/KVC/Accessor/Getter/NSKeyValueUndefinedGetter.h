//
//  NSKeyValueUndefinedGetter.h
//  KV
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueGetter.h"

@interface NSKeyValueUndefinedGetter : NSKeyValueGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key containerIsa:(Class)containerIsa;

@end
