//
//  NSObject.h
//  KVOIMP
//
//  Created by JK on 2017/1/6.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSKeyValueGetter;

@interface NSObject (NSKeyValueCoding)

- (id)valueForKey:(NSString *)key;

+ (NSKeyValueGetter *)_createMutableArrayValueGetterWithContainerClassID:(Class)containerClassID key:(NSString *)key;
@end
