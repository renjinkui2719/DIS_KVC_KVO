//
//  DSKeyValueMutatingSetMethodSet.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueMutatingCollectionMethodSet.h"

@interface DSKeyValueMutatingSetMethodSet : DSKeyValueMutatingCollectionMethodSet
@property(nonatomic, assign) struct objc_method *addObject;
@property(nonatomic, assign) struct objc_method *removeObject;
@property(nonatomic, assign) struct objc_method *intersectSet;
@property(nonatomic, assign) struct objc_method *minusSet;
@property(nonatomic, assign) struct objc_method *unionSet;
@property(nonatomic, assign) struct objc_method *setSet;
@end
