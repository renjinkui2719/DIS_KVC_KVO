//
//  NSKeyValueUnnestedProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import "NSKeyValueProperty.h"

@interface NSKeyValueUnnestedProperty : NSKeyValueProperty
//当前keyPath依赖的其他property
@property (nonatomic, strong) NSArray *affectingProperties;
@property (nonatomic, assign) BOOL cachedIsaForAutonotifyingIsValid;
@property (nonatomic, assign) Class cachedIsaForAutonotifying;

- (void)_addDependentValueKey:(id)arg1;
- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties;
- (id)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass key:(NSString *)key propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;

@end

