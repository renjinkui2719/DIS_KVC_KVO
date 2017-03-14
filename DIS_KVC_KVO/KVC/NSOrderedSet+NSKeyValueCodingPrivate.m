//
//  NSOrderedSet+NSKeyValueCodingPrivate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSOrderedSet+NSKeyValueCodingPrivate.h"

@implementation NSOrderedSet (NSKeyValueCodingPrivate)

- (id)_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] valueForKeyPath:keyPath];
}

- (id)_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] mutableArrayValueForKeyPath:keyPath];
}

- (id)_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] mutableOrderedSetValueForKeyPath:keyPath];
}

- (id)_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] mutableSetValueForKeyPath:keyPath];
}

- (void)_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    [[self objectAtIndex:idx] setValue:value forKeyPath:keyPath];
}

- (BOOL)_validateValue:(id *)ioValue forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx error:(NSError **)outError {
    return [[self objectAtIndex:idx] validateValue:ioValue forKeyPath:keyPath error:outError];
}

@end
