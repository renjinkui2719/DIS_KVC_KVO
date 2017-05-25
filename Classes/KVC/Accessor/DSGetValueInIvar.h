//
//  DSGetValueInIvar.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/27.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


NSNumber * _DSGetUnsignedCharValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _DSGetCharValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _DSGetBoolValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _DSGetDoubleValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _DSGetFloatValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _DSGetIntValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _DSGetUnsignedIntValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _DSGetLongValueInIvar(id object, SEL selector, Ivar ivar);

NSNumber * _DSGetUnsignedLongValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _DSGetLongLongValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _DSGetUnsignedLongLongValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _DSGetShortValueInIvar(id object, SEL selector, Ivar ivar);
NSNumber * _DSGetUnsignedShortValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _DSGetPointValueInIvar(id object, SEL selector, Ivar ivar);
NSValue * _DSGetRangeValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _DSGetRectValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _DSGetSizeValueInIvar(id object, SEL selector, Ivar ivar);

NSValue * _DSGetValueInIvar(id object, SEL selector, Ivar ivar);

id _DSGetObjectGetWeakValueInIvar(id object, SEL selector, Ivar ivar);
id _DSGetObjectGetAssignValueInIvar(id object, SEL selector, Ivar ivar);
id _DSGetObjectGetIvarValueInIvar(id object, SEL selector, Ivar ivar) ;
