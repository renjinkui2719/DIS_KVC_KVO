//
//  NSKVOSetAndNotify.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueMutatingCollectionMethodSet.h"

void _NSSetCharValueAndNotify(id object,SEL selector, char value);

void _NSSetDoubleValueAndNotify(id object,SEL selector, double value);

void _NSSetFloatValueAndNotify(id object,SEL selector, float value);

void _NSSetIntValueAndNotify(id object,SEL selector, int value);

void _NSSetLongValueAndNotify(id object,SEL selector, long value);

void _NSSetLongLongValueAndNotify(id object,SEL selector, long long value);

void _NSSetShortValueAndNotify(id object,SEL selector, short value);

void _NSSetUnsignedShortValueAndNotify(id object,SEL selector, unsigned short value);

void _NSSetPointValueAndNotify(id object,SEL selector, NSPoint value);

void _NSSetRangeValueAndNotify(id object,SEL selector, NSRange value);

void _NSSetRectValueAndNotify(id object,SEL selector, NSRect value);

void _NSSetSizeValueAndNotify(id object,SEL selector, NSSize value);

void _NSSetBoolValueAndNotify(id object,SEL selector, BOOL value);

void _NSSetUnsignedCharValueAndNotify(id object,SEL selector, unsigned char value);

void _NSSetUnsignedIntValueAndNotify(id object,SEL selector, unsigned int value);

void _NSSetUnsignedLongValueAndNotify(id object,SEL selector, unsigned long value);

void _NSSetUnsignedLongLongValueAndNotify(id object,SEL selector, unsigned long long value);

void _NSSetObjectValueAndNotify(id object,SEL selector, id value);



void NSKVOInsertObjectAtIndexAndNotify(id object,SEL selector, id value, NSUInteger idx);

void NSKVOInsertObjectsAtIndexesAndNotify(id object,SEL selector, id values, NSIndexSet *indexes);

void NSKVORemoveObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx);

void NSKVORemoveObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes);

void NSKVOReplaceObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx, id value);

void NSKVOReplaceObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes, id values);

void NSKVOAddObjectAndNotify(id object, SEL selector, id value);

void NSKVORemoveObjectAndNotify(id object, SEL selector, id value);

void NSKVOIntersectSetAndNotify(id object, SEL selector, id values);

void NSKVOMinusSetAndNotify(id object, SEL selector, id values);

void NSKVOUnionSetAndNotify(id object, SEL selector, id values);
