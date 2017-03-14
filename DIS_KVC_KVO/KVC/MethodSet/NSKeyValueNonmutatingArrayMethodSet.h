//
//  NSKeyValueNonmutatingArrayMethodSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueNonmutatingCollectionMethodSet.h"

@interface NSKeyValueNonmutatingArrayMethodSet : NSKeyValueNonmutatingCollectionMethodSet
@property (nonatomic, assign) struct objc_method * count;
@property (nonatomic, assign) struct objc_method * objectAtIndex;
@property (nonatomic, assign) struct objc_method * getObjectsRange;
@property (nonatomic, assign) struct objc_method * objectsAtIndexes;
@end
