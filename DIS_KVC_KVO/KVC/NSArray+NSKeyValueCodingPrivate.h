//
//  NSArray+NSKeyValueCodingPrivate.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/8.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSKeyValueCodingPrivate)
- (id)_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (id)_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (id)_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (id)_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (void)_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (char)_validateValue:(id *)ioValue forKeyPath:(NSString *)inKeyPath ofObjectAtIndex:(NSUInteger)index error:(NSError * *)outError;

@end
