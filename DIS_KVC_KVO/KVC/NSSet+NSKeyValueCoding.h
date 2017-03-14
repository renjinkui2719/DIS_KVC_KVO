//
//  NSSet+NSKeyValueCoding.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (NSKeyValueCoding)
- (id)valueForKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKey:(NSString *)key;

- (NSNumber *)_sumForKeyPath:(NSString *)keyPath;
- (NSNumber *)_avgForKeyPath:(NSString *)keyPath;
- (NSNumber *)_countForKeyPath:(NSString *)keyPath;
- (id)_maxForKeyPath:(NSString *)keyPath;
- (id)_minForKeyPath:(NSString *)keyPath;
- (NSSet *)_distinctUnionOfObjectsForKeyPath:(NSString *)keyPath;
- (NSSet *)_distinctUnionOfArraysForKeyPath:(NSString *)keyPath;
- (NSSet *)_distinctUnionOfSetsForKeyPath:(NSString *)keyPath;
@end
