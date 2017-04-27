//
//  DSKeyValueNonmutatingOrderedSetMethodSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueNonmutatingCollectionMethodSet.h"

@interface DSKeyValueNonmutatingOrderedSetMethodSet : DSKeyValueNonmutatingCollectionMethodSet
@property (nonatomic, assign) struct objc_method * count;
@property (nonatomic, assign) struct objc_method * objectAtIndex;
@property (nonatomic, assign) struct objc_method * indexOfObject;
@property (nonatomic, assign) struct objc_method * getObjectsRange;
@property (nonatomic, assign) struct objc_method * objectsAtIndexes;
@end
