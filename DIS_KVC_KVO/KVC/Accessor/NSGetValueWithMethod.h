//
//  NSGetValueWithMethod.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NSNumber * _NSGetBoolValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetCharValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetUnsignedCharValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetShortValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetUnsignedShortValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetIntValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetUnsignedIntValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetUnsignedLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetLongLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetUnsignedLongLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetDoubleValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _NSGetFloatValueWithMethod(id object, SEL selctor, Method method);
id  _NSGetVoidValueWithMethod(id object, SEL selctor, Method method);
NSValue * _NSGetRangeValueWithMethod(id object, SEL selctor, Method method);
NSValue * _NSGetRectValueWithMethod(id object, SEL selctor, Method method);
NSValue * _NSGetSizeValueWithMethod(id object, SEL selctor, Method method);
NSValue * _NSGetPointValueWithMethod(id object, SEL selctor, Method method);
NSValue *  _NSGetValueWithMethod(id object, SEL selctor, Method method);
