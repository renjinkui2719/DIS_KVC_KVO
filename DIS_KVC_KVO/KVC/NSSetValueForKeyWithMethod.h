//
//  NSSetValueForKeyWithMethod.h
//  KVOIMP
//
//  Created by JK on 2017/1/9.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueSetter.h"
#import <objc/runtime.h>

void _NSSetUnsignedIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetBoolValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetUnsignedCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetUnsignedLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetUnsignedLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetCharValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetDoubleValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetFloatValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetIntValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetLongLongValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetShortValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);

void _NSSetPointValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetRangeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetRectValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetSizeValueForKeyWithMethod(id object, SEL selector,id value, NSString *key, Method method);
void _NSSetValueWithMethod(id object, SEL selector,id value, NSString *key, Method method);
