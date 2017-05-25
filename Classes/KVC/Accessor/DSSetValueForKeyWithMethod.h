//
//  DSSetValueForKeyWithMethod.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/9.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueSetter.h"
#import <objc/runtime.h>

void _DSSetUnsignedIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetBoolValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetUnsignedCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetUnsignedLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetUnsignedLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetDoubleValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetFloatValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetShortValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);

void _DSSetPointValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetRangeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetRectValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetSizeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _DSSetValueWithMethod(id object, SEL selector,id value, NSString *key, Method method);
