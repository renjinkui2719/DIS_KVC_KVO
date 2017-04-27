//
//  NSSet+DSKeyValueCoding.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (DSKeyValueCoding)

- (NSNumber *)_d_sumForKeyPath:(NSString *)keyPath;
- (NSNumber *)_d_avgForKeyPath:(NSString *)keyPath;
- (NSNumber *)_d_countForKeyPath:(NSString *)keyPath;
- (id)_d_maxForKeyPath:(NSString *)keyPath;
- (id)_d_minForKeyPath:(NSString *)keyPath;
- (NSSet *)_d_distinctUnionOfObjectsForKeyPath:(NSString *)keyPath;
- (NSSet *)_d_distinctUnionOfArraysForKeyPath:(NSString *)keyPath;
- (NSSet *)_d_distinctUnionOfSetsForKeyPath:(NSString *)keyPath;
@end
