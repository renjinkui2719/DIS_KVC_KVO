//
//  NSOrderedSet+DSKeyValueCodingPrivate.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOrderedSet (DSKeyValueCodingPrivate)
- (id)_d_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (id)_d_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (id)_d_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (id)_d_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (void)_d_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (BOOL)_d_validateValue:(id *)ioValue forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx error:(NSError **)outError;
@end
