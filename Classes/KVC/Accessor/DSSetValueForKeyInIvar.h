//
//  DSSetValueForKeyInIvar.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSetter.h"
#import <objc/runtime.h>

void _DSSetCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) ;
void _DSSetDoubleValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetFloatValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetUnsignedLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetUnsignedLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetBoolValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetUnsignedCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetUnsignedIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetUnsignedShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);

void _DSSetPointValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetRangeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetRectValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetSizeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);

void _DSSetValueInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);

void _DSSetObjectSetIvarValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetObjectSetManualValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetObjectSetStrongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetObjectSetWeakValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _DSSetObjectSetAssignValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
