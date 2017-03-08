//
//  NSArray+NSKeyValueCoding.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/8.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSKeyValueCoding)
- (id)valueForKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKey:(NSString *)key;
@end
