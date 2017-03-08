//
//  NSArray+NSKeyValueCodingPrivate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/8.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSArray+NSKeyValueCodingPrivate.h"

@implementation NSArray (NSKeyValueCodingPrivate)

- (id)_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] valueForKeyPath:keyPath];
}

- (id)_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] mutableArrayValueForKeyPath:keyPath];
}

- (id)_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] mutableSetValueForKeyPath:keyPath];
}

- (id)_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] mutableOrderedSetValueForKeyPath:keyPath];
}

- (void)_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    [[self objectAtIndex:index] setValue:value forKey:keyPath];
}

- (char)_validateValue:(id *)ioValue forKeyPath:(NSString *)inKeyPath ofObjectAtIndex:(NSUInteger)index error:(NSError * *)outError {
    return [[self objectAtIndex:index] validateValue:ioValue forKeyPath:inKeyPath error:outError];
}

@end
