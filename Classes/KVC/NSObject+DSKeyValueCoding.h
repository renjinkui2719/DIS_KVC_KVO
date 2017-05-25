//
//  NSObject+DSKeyValueCoding.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/6.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key;
- (id)d_valueForKeyPath:(NSString *)keyPath;
- (void)d_setValue:(id)value forKey:(NSString *)key;
- (void)d_setValue:(id)value forKeyPath:(NSString *)keyPath;
- (void)d_setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;
- (void)d_setNilValueForKey:(NSString *)key;
- (void)d_setValue:(id)value forUndefinedKey:(NSString *)key;
- (id)d_valueForUndefinedKey:(NSString *)key;
- (NSDictionary<NSString *, id> *)d_dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;
- (BOOL)d_validateValue:(id *)ioValue forKey:(NSString *)inKey error:(NSError * *)outError;
- (BOOL)d_validateValue:(id *)ioValue forKeyPath:(NSString *)inKeyPath error:(NSError * *)outError;
+ (BOOL)d_accessInstanceVariablesDirectly;


- (NSMutableArray *)d_mutableArrayValueForKey:(NSString *)key;
- (NSMutableArray *)d_mutableArrayValueForKeyPath:(NSString *)keyPath;
- (NSMutableOrderedSet *)d_mutableOrderedSetValueForKey:(NSString *)key;
- (NSMutableOrderedSet *)d_mutableOrderedSetValueForKeyPath:(NSString *)keyPath;
- (NSMutableSet *)d_mutableSetValueForKey:(NSString *)key;
- (NSMutableSet *)d_mutableSetValueForKeyPath:(NSString *)keyPath;

@end
