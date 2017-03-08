//
//  NSKeyValueNestedProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProperty.h"

@class NSKeyValueUnnestedProperty;

@interface NSKeyValueNestedProperty : NSKeyValueProperty

@property (nonatomic, copy) NSString *relationshipKey;
@property (nonatomic, copy) NSString *keyPathFromRelatedObject;
@property (nonatomic, strong) NSKeyValueUnnestedProperty *relationshipProperty;
@property (nonatomic, copy) NSString *keyPathWithoutOperatorComponents;
@property (nonatomic, assign) char isAllowedToResultInForwarding;
@property (nonatomic, strong) id dependentValueKeyOrKeys;
@property (nonatomic, assign) char dependentValueKeyOrKeysIsASet;

- (NSKeyValueNestedProperty *)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath firstDotIndex:(NSUInteger)firstDotIndex propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;
- (void)_givenPropertiesBeingInitialized:(CFSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties;
- (void)_addDependentValueKey:(id)valueKey;

@end
