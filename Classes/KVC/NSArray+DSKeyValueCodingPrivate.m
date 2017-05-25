//
//  NSArray+DSKeyValueCodingPrivate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/8.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSArray+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueCoding.h"

@implementation NSArray (DSKeyValueCodingPrivate)

- (id)_d_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] d_valueForKeyPath:keyPath];
}

- (id)_d_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] d_mutableArrayValueForKeyPath:keyPath];
}

- (id)_d_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] d_mutableSetValueForKeyPath:keyPath];
}

- (id)_d_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] d_mutableOrderedSetValueForKeyPath:keyPath];
}

- (void)_d_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)index {
    [[self objectAtIndex:index] d_setValue:value forKey:keyPath];
}

- (char)_d_validateValue:(id *)ioValue forKeyPath:(NSString *)inKeyPath ofObjectAtIndex:(NSUInteger)index error:(NSError * *)outError {
    return [[self objectAtIndex:index] d_validateValue:ioValue forKeyPath:inKeyPath error:outError];
}

@end
