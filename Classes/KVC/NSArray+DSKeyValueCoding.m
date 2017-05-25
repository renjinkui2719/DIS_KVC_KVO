//
//  NSArray+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/8.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSArray+DSKeyValueCoding.h"
#import "NSArray+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueCoding.h"
#import "DSKeyValueCodingCommon.h"

@implementation NSArray (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    NSString *operationKey = nil;
    //比如以@count, @description, @lastObject...调用此方法
    if (key.length && [key characterAtIndex:0] == '@' && (operationKey = [key substringWithRange:NSMakeRange(1, key.length - 1)])) {
        //去掉@，直接调用对应key
        id value =  [super d_valueForKey:operationKey];
        return value;
    }
    else {
        id *objectsBuff = NSAllocateObjectArray(self.count);
        id *p = objectsBuff;
        
        for (id object in self) {
            id eachValue = [object d_valueForKey:key];
            *(p++) = (eachValue ? : [NSNull null]);
        }
        
        NSArray *arrayValue = [[[NSArray alloc] initWithObjects:objectsBuff count:self.count] autorelease];
        
        NSFreeObjectArray(objectsBuff);
        
        return arrayValue;
    }
}

- (id)d_valueForKeyPath:(NSString *)keyPath {
    //以集合运算符开头
    if(keyPath.length && [keyPath characterAtIndex:0] == '@') {
        NSRange dotRange = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
        if(dotRange.length) {
            //运算符名
            NSString *operator = [keyPath substringWithRange:NSMakeRange(1, dotRange.location - 1)];
            //计算每个对象的什么属性
            NSString *keyPathForOperator = [keyPath substringWithRange:NSMakeRange(dotRange.location + 1, keyPath.length - (dotRange.location + 1))];
            if(keyPathForOperator) {
                NSUInteger operatorCStrLength = [operator lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                char operatorCStr[operatorCStrLength + 1];
                
                [operator getCString:operatorCStr maxLength:operatorCStrLength + 1 encoding:NSUTF8StringEncoding];
                
                Method operatorMethod = DSKeyValueMethodForPattern(self.class, "d_%sForKeyPath:", operatorCStr);
                if(!operatorMethod) {
                    operatorMethod = DSKeyValueMethodForPattern(self.class, "_d_%sForKeyPath:", operatorCStr);
                }
                if (operatorMethod) {
                    //调用运算符对应的方法
                    id value = ((id (*)(id,Method,NSString *))method_invoke)(self,operatorMethod,keyPathForOperator);
                    return value;
                }
                else {
                    //不支持的运算符
                    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> valueForKeyPath:]: this class does not implement the %@ operation.", self.class,self,operator];
                    return nil;
                }
            }
            else {
                id value = [super d_valueForKey:operator];
                return value;
            }
        }
        else {
            NSString *key = [[keyPath substringWithRange:NSMakeRange(1, keyPath.length - 1)] retain];
            id value = [super d_valueForKey:key];
            return value;
        }
    }
    else {
        //按照NSObject对d_valueForKeyPath的实现方式取值
        return [super d_valueForKeyPath: keyPath];
    }
}

- (void)d_setValue:(id)value forKey:(NSString *)key {
    for (id object in self) {
        [object d_setValue:value forKey:key];
    }
}


//对 Array中每个对象的keyPath对应值 求和
//@sum.keyPath
- (NSNumber *)_d_sumForKeyPath:(NSString *)keyPath {
    NSDecimal resultDecimal = {0};
    NSDecimalNumber *zero = [NSDecimalNumber zero];
    if (zero) {
        resultDecimal = [zero decimalValue];
    }
    
    NSDecimal eachDecimal = {0};
    for (NSUInteger i=0; i<self.count; ++i) {
        //获取每个对象的keyPath对应值
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            eachDecimal = [eachValue decimalValue];
            //累加
            NSDecimalAdd(&resultDecimal, &resultDecimal, &eachDecimal, NSRoundBankers);
        }
    }
    
    return [NSDecimalNumber decimalNumberWithDecimal:resultDecimal];
}

//对 Array中每个对象的keyPath对应值 求平均值
//@avg.keyPath
- (NSNumber *)_d_avgForKeyPath:(NSString *)keyPath {
    if (self.count) {
        //总和 / 对象数
        return [(NSDecimalNumber*)[self _d_sumForKeyPath:keyPath]  decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithUnsignedInteger:self.count]];
    }
    return 0;
}

//获取对象数目
//@count
- (NSNumber *)_d_countForKeyPath:(NSString *)keyPath {
    return [NSNumber numberWithInteger:self.count];
}

//对 Array中每个对象的keyPath对应值 求最大值
//@max.keyPath
- (id)_d_maxForKeyPath:(NSString *)keyPath {
    id maxValue = nil;
    for (NSUInteger i=0; i<self.count; ++i) {
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            if (!maxValue) {
                maxValue = eachValue;
            }
            else if ([maxValue compare:eachValue] == NSOrderedAscending){
                maxValue = eachValue;
            }
        }
    }
    return maxValue;
}

//对 Array中每个对象的keyPath对应值 求最小值
//@min.keyPath
- (id)_d_minForKeyPath:(NSString *)keyPath {
    id minValue = nil;
    for (NSUInteger i=0; i<self.count; ++i) {
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            if (!minValue) {
                minValue = eachValue;
            }
            else if ([minValue compare:eachValue] == NSOrderedDescending){
                minValue = eachValue;
            }
        }
    }
    return minValue;
}

//返回 Array中每个对象的keyPath对应值 组成的数组
//@unionOfObjects.keyPath
- (NSArray *)_d_unionOfObjectsForKeyPath:(NSString *)keyPath {
    NSMutableArray *unionArray = [NSMutableArray arrayWithCapacity:self.count];
    for (NSUInteger i=0; i<self.count; ++i) {
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            [unionArray addObject:eachValue];
        }
    }
    return unionArray;
}

//返回 Array中每个对象的keyPath对应值 组成的去重复数组
//@distinctUnionOfObjects.keyPath
- (NSArray *)_d_distinctUnionOfObjectsForKeyPath:(NSString *)keyPath {
    NSArray *unionArray = [self _d_unionOfObjectsForKeyPath:keyPath];
    return [NSSet setWithArray:unionArray].allObjects;
}


//返回 Array中每个对象的keyPath对应数组的每个成员 组成的数组. 这里每个keyPath对应值是也是数组，获取的是每个数组展开后组成的总数组
//@unionOfArrays.keyPath
- (NSArray *)_d_unionOfArraysForKeyPath:(NSString *)keyPath {
    NSMutableArray *unionArray = [NSMutableArray arrayWithCapacity:self.count];
    for (NSUInteger i=0; i<self.count; ++i) {
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            [unionArray addObjectsFromArray:eachValue];
        }
    }
    return unionArray;
}
//返回 Array中每个对象的keyPath对应数组的每个成员 组成的去重复数组.
//@distinctUnionOfArrays.keyPath
- (NSArray *)_d_distinctUnionOfArraysForKeyPath:(NSString *)keyPath {
    NSArray *unionArray = [self _d_unionOfArraysForKeyPath:keyPath];
    return [NSSet setWithArray:unionArray].allObjects;
}


//返回 Array中每个对象的keyPath对应集合的每个成员 组成的数组. 这里每个keyPath对应值是是集合，获取的是每个集合展开后组成的总数组
//@unionOfSets.keyPath
- (NSArray *)_d_unionOfSetsForKeyPath:(NSString *)keyPath {
    NSMutableArray *unionArray = [NSMutableArray arrayWithCapacity:self.count];
    for (NSUInteger i=0; i<self.count; ++i) {
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            [unionArray addObjectsFromArray:[eachValue allObjects]];
        }
    }
    return unionArray;
}

//返回 Array中每个对象的keyPath对应集合的每个成员 组成的去重复数组.
//@distinctUnionOfSets.keyPath
- (NSArray *)_d_distinctUnionOfSetsForKeyPath:(NSString *)keyPath {
    NSMutableSet *unionSet = [NSMutableSet setWithCapacity:self.count];
    for (NSUInteger i=0; i<self.count; ++i) {
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            [unionSet unionSet:eachValue];
        }
    }
    return unionSet.allObjects;
}

@end
