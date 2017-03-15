//
//  NSObject+NSKeyValueCoding.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/6.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CFMutableSetRef NSKeyValueCachedMutableArrayGetters;

@class NSKeyValueGetter;
@interface NSObject (NSKeyValueCoding)

- (id)valueForKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;
- (void)setNilValueForKey:(NSString *)key;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
- (id)valueForUndefinedKey:(NSString *)key;
- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;
- (BOOL)validateValue:(inout id  _Nullable *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable *)outError;
- (BOOL)validateValue:(inout id  _Nullable *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError * _Nullable *)outError;
+ (BOOL)accessInstanceVariablesDirectly;


- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;
- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath;
- (NSMutableOrderedSet *)mutableOrderedSetValueForKey:(NSString *)key;
- (NSMutableOrderedSet *)mutableOrderedSetValueForKeyPath:(NSString *)keyPath;
- (NSMutableOrderedSet *)mutableSetValueForKey:(NSString *)key;
- (NSMutableOrderedSet *)mutableSetValueForKeyPath:(NSString *)keyPath;

@end
