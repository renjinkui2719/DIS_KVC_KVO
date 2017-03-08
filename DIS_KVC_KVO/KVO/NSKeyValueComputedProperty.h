//
//  NSKeyValueComputedProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//


#import "NSKeyValueProperty.h"

@interface NSKeyValueComputedProperty : NSKeyValueProperty

@property(nonatomic, copy) NSString *operationName;
@property(nonatomic, copy) NSString *operationArgumentKeyPath;
@property(nonatomic, strong) NSKeyValueProperty *operationArgumentProperty;

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties;
- (void)_addDependentValueKey:(id)valueKey;

@end

