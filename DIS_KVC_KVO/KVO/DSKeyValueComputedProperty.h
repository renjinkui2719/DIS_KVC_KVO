//
//  DSKeyValueComputedProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//


#import "DSKeyValueProperty.h"

@interface DSKeyValueComputedProperty : DSKeyValueProperty

@property(nonatomic, copy) NSString *operationName;
@property(nonatomic, copy) NSString *operationArgumentKeyPath;
@property(nonatomic, strong) DSKeyValueProperty *operationArgumentProperty;

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties;
- (void)_addDependentValueKey:(id)valueKey;

@end

