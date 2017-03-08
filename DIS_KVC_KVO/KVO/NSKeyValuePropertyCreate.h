//
//  NSKeyValuePropertyCreate.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/24.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueProperty;

BOOL NSKeyValuePropertyIsEqual(NSKeyValueProperty *property1, NSKeyValueProperty *property2);
NSUInteger NSKeyValuePropertyHash(NSKeyValueProperty *property);
NSKeyValueProperty *NSKeyValuePropertyForIsaAndKeyPath(Class isa, NSString *keypath);
NSKeyValueProperty *NSKeyValuePropertyForIsaAndKeyPathInner( Class isa, NSString *keyPath, CFMutableSetRef propertySet);
