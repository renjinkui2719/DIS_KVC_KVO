//
//  DSKVOSetAndNotify.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSKeyValueMutatingCollectionMethodSet.h"

void _DSSetCharValueAndNotify(id object,SEL selector, char value);

void _DSSetDoubleValueAndNotify(id object,SEL selector, double value);

void _DSSetFloatValueAndNotify(id object,SEL selector, float value);

void _DSSetIntValueAndNotify(id object,SEL selector, int value);

void _DSSetLongValueAndNotify(id object,SEL selector, long value);

void _DSSetLongLongValueAndNotify(id object,SEL selector, long long value);

void _DSSetShortValueAndNotify(id object,SEL selector, short value);

void _DSSetUnsignedShortValueAndNotify(id object,SEL selector, unsigned short value);

void _DSSetPointValueAndNotify(id object,SEL selector, CGPoint value);

void _DSSetRangeValueAndNotify(id object,SEL selector, NSRange value);

void _DSSetRectValueAndNotify(id object,SEL selector, CGRect value);

void _DSSetSizeValueAndNotify(id object,SEL selector, CGSize value);

void _DSSetBoolValueAndNotify(id object,SEL selector, BOOL value);

void _DSSetUnsignedCharValueAndNotify(id object,SEL selector, unsigned char value);

void _DSSetUnsignedIntValueAndNotify(id object,SEL selector, unsigned int value);

void _DSSetUnsignedLongValueAndNotify(id object,SEL selector, unsigned long value);

void _DSSetUnsignedLongLongValueAndNotify(id object,SEL selector, unsigned long long value);

void _DSSetObjectValueAndNotify(id object,SEL selector, id value);



void DSKVOInsertObjectAtIndexAndNotify(id object,SEL selector, id value, NSUInteger idx);

void DSKVOInsertObjectsAtIndexesAndNotify(id object,SEL selector, id values, NSIndexSet *indexes);

void DSKVORemoveObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx);

void DSKVORemoveObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes);

void DSKVOReplaceObjectAtIndexAndNotify(id object,SEL selector, NSUInteger idx, id value);

void DSKVOReplaceObjectsAtIndexesAndNotify(id object, SEL selector, NSIndexSet *indexes, id values);

void DSKVOAddObjectAndNotify(id object, SEL selector, id value);

void DSKVORemoveObjectAndNotify(id object, SEL selector, id value);

void DSKVOIntersectSetAndNotify(id object, SEL selector, id values);

void DSKVOMinusSetAndNotify(id object, SEL selector, id values);

void DSKVOUnionSetAndNotify(id object, SEL selector, id values);
