//
//  DSKeyValuePropertyCreate.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/24.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DSKeyValueProperty;

BOOL DSKeyValuePropertyIsEqual(DSKeyValueProperty *property1, DSKeyValueProperty *property2);
NSUInteger DSKeyValuePropertyHash(DSKeyValueProperty *property);
DSKeyValueProperty *DSKeyValuePropertyForIsaAndKeyPath(Class isa, NSString *keypath);
DSKeyValueProperty *DSKeyValuePropertyForIsaAndKeyPathInner( Class isa, NSString *keyPath, CFMutableSetRef propertySet);
