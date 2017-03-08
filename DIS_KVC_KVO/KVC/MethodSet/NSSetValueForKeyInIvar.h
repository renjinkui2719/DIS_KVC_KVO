//
//  NSSetValueForKeyInIvar.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/10.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueSetter.h"
#import <objc/runtime.h>

void _NSSetCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar) ;
void _NSSetDoubleValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetFloatValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetUnsignedLongLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetUnsignedLongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetBoolValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetUnsignedCharValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetUnsignedIntValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetUnsignedShortValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);

void _NSSetPointValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetRangeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetRectValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetSizeValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);

void _NSSetValueInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);

void _NSSetObjectSetIvarValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetObjectSetManualValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetObjectSetStrongValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetObjectSetWeakValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
void _NSSetObjectSetAssignValueForKeyInIvar(id object, SEL selector, id value, NSString *key, Ivar ivar);
