//
//  NSArray+DSKeyValueCodingPrivate.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/8.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DSKeyValueCodingPrivate)
- (id)_d_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (id)_d_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (id)_d_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (id)_d_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (void)_d_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index;

- (char)_d_validateValue:(id *)ioValue forKeyPath:(NSString *)inKeyPath ofObjectAtIndex:(NSUInteger)index error:(NSError * *)outError;

@end
