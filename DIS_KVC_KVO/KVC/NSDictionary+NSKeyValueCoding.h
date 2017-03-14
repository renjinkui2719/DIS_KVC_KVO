//
//  NSDictionary+NSKeyValueCoding.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSKeyValueCoding)
- (id)valueForKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;
@end
