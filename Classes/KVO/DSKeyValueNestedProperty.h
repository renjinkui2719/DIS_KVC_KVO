//
//  DSKeyValueNestedProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProperty.h"

@class DSKeyValueUnnestedProperty;

@interface DSKeyValueNestedProperty : DSKeyValueProperty

@property (nonatomic, copy) NSString *relationshipKey;
@property (nonatomic, copy) NSString *keyPathFromRelatedObject;
@property (nonatomic, strong) DSKeyValueUnnestedProperty *relationshipProperty;
@property (nonatomic, copy) NSString *keyPathWithoutOperatorComponents;
@property (nonatomic, assign) BOOL isAllowedToResultInForwarding;
//依赖我的其他keyPath
@property (nonatomic, strong) id dependentValueKeyOrKeys;
//dependentValueKeyOrKeys 字段是否是集合
@property (nonatomic, assign) BOOL dependentValueKeyOrKeysIsASet;

- (DSKeyValueNestedProperty *)_initWithContainerClass:(DSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath firstDotIndex:(NSUInteger)firstDotIndex propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;
@end
