//
//  DSGetValueWithMethod.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NSNumber * _DSGetBoolValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetCharValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetUnsignedCharValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetShortValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetUnsignedShortValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetIntValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetUnsignedIntValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetUnsignedLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetLongLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetUnsignedLongLongValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetDoubleValueWithMethod(id object, SEL selctor, Method method);
NSNumber * _DSGetFloatValueWithMethod(id object, SEL selctor, Method method);
id  _DSGetVoidValueWithMethod(id object, SEL selctor, Method method);
NSValue * _DSGetRangeValueWithMethod(id object, SEL selctor, Method method);
NSValue * _DSGetRectValueWithMethod(id object, SEL selctor, Method method);
NSValue * _DSGetSizeValueWithMethod(id object, SEL selctor, Method method);
NSValue * _DSGetPointValueWithMethod(id object, SEL selctor, Method method);
NSValue *  _DSGetValueWithMethod(id object, SEL selctor, Method method);
