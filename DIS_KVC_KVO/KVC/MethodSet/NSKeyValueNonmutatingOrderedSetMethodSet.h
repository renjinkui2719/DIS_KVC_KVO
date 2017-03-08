//
//  NSKeyValueNonmutatingOrderedSetMethodSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueNonmutatingCollectionMethodSet.h"
#import <objc/runtime.h>

@interface NSKeyValueNonmutatingOrderedSetMethodSet : NSKeyValueNonmutatingCollectionMethodSet
@property (nonatomic, assign) Method count;
@property (nonatomic, assign) Method objectAtIndex;
@property (nonatomic, assign) Method indexOfObject;
@property (nonatomic, assign) Method getObjectsRange;
@property (nonatomic, assign) Method objectsAtIndexes;
@end
