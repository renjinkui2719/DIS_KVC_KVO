//
//  DSKeyValueNotifyingMutableArray.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueMutableArray.h"

@interface DSKeyValueNotifyingMutableArray : DSKeyValueMutableArray
@property (nonatomic, strong) NSMutableArray *mutableArray;

@end
