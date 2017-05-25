//
//  DSKeyValueUnnestedProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import "DSKeyValueProperty.h"

@interface DSKeyValueUnnestedProperty : DSKeyValueProperty
//当前keyPath在KVO中依赖的其他property
@property (nonatomic, strong) NSArray<DSKeyValueProperty *> *affectingProperties;
@property (nonatomic, assign) BOOL cachedIsaForAutonotifyingIsValid;
@property (nonatomic, assign) Class cachedIsaForAutonotifying;

- (id)_initWithContainerClass:(DSKeyValueContainerClass *)containerClass key:(NSString *)key propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;

@end

