//
//  NSArray+DSKeyValueCoding.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/8.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DSKeyValueCoding)

/**
 返回Array内每个对象的“key”对应值组成的数组
 */
- (id)d_valueForKey:(NSString *)key;

/**
 如果keyPath中包含集合运算符，则返回运算结果, 否则返回Array内每个对象的“keyPath”对应值组成的数组
 */
- (id)d_valueForKeyPath:(NSString *)keyPath;

/**
 设置Array里每个对象的key对应值为value
 */
- (void)d_setValue:(id)value forKey:(NSString *)key;

@end
