//
//  NSGetValueInIvar.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


NSNumber * _NSGetUnsignedCharValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _NSGetCharValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _NSGetBoolValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _NSGetDoubleValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _NSGetFloatValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _NSGetIntValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _NSGetUnsignedIntValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _NSGetLongValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _NSGetUnsignedLongValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _NSGetLongLongValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _NSGetUnsignedLongLongValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _NSGetShortValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _NSGetUnsignedShortValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _NSGetPointValueInIvar(id object, SEL selector, Ivar ivar);
NSValue * _NSGetRangeValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _NSGetRectValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _NSGetSizeValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _NSGetValueInIvar(id object, SEL selector, Ivar ivar);

id _NSGetObjectGetWeakValueInIvar(id object, SEL selector, Ivar ivar);
id _NSGetObjectGetAssignValueInIvar(id object, SEL selector, Ivar ivar);
id _NSGetObjectGetIvarValueInIvar(id object, SEL selector, Ivar ivar) ;
