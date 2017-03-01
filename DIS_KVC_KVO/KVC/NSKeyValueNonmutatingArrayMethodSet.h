//
//  NSKeyValueNonmutatingArrayMethodSet.h
//  KV
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueNonmutatingCollectionMethodSet.h"

@interface NSKeyValueNonmutatingArrayMethodSet : NSKeyValueNonmutatingCollectionMethodSet
@property (nonatomic, assign) Method count;
@property (nonatomic, assign) Method objectAtIndex;
@property (nonatomic, assign) Method getObjectsRange;
@property (nonatomic, assign) Method objectsAtIndexes;
@end
