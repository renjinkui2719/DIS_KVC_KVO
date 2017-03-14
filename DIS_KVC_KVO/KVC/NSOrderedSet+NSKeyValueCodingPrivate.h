//
//  NSOrderedSet+NSKeyValueCodingPrivate.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOrderedSet (NSKeyValueCodingPrivate)
- (id)_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (id)_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (id)_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (id)_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (void)_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx;
- (BOOL)_validateValue:(id *)ioValue forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx error:(NSError **)outError;
@end
