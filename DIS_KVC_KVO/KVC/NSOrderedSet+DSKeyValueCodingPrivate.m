//
//  NSOrderedSet+DSKeyValueCodingPrivate.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSOrderedSet+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueCoding.h"

@implementation NSOrderedSet (DSKeyValueCodingPrivate)

- (id)_d_valueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] d_valueForKeyPath:keyPath];
}

- (id)_d_mutableArrayValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] d_mutableArrayValueForKeyPath:keyPath];
}

- (id)_d_mutableOrderedSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] d_mutableOrderedSetValueForKeyPath:keyPath];
}

- (id)_d_mutableSetValueForKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    return [[self objectAtIndex:idx] d_mutableSetValueForKeyPath:keyPath];
}

- (void)_d_setValue:(id)value forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx {
    [[self objectAtIndex:idx] d_setValue:value forKeyPath:keyPath];
}

- (BOOL)_d_validateValue:(id *)ioValue forKeyPath:(NSString *)keyPath ofObjectAtIndex:(NSUInteger)idx error:(NSError **)outError {
    return [[self objectAtIndex:idx] d_validateValue:ioValue forKeyPath:keyPath error:outError];
}

@end
