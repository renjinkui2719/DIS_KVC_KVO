//
//  NSOrderedSet+DSKeyValueCodingPrivate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSOrderedSet+DSKeyValueCodingPrivate.h"

@implementation NSOrderedSet (DSKeyValueCodingPrivate)

- (id)_d_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] valueForKeyPath:keyPath];
}

- (id)_d_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] mutableArrayValueForKeyPath:keyPath];
}

- (id)_d_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] mutableOrderedSetValueForKeyPath:keyPath];
}

- (id)_d_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] mutableSetValueForKeyPath:keyPath];
}

- (void)_d_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    [[self objectAtIndex:idx] setValue:value forKeyPath:keyPath];
}

- (BOOL)_d_validateValue:(id *)ioValue forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx error:(NSError **)outError {
    return [[self objectAtIndex:idx] validateValue:ioValue forKeyPath:keyPath error:outError];
}

@end
