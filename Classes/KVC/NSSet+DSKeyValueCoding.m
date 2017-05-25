//
//  NSSet+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSSet+DSKeyValueCoding.h"
#import "DSKeyValueCodingCommon.h"
#import "NSObject+DSKeyValueCoding.h"
#import "NSObject+DSKeyValueCodingPrivate.h"

@implementation NSSet (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    NSString *operationKey = nil;
    if (key.length && [key characterAtIndex:0] == '@' && (operationKey = [key substringWithRange:NSMakeRange(1, key.length - 1)])) {
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
        
        NSSet *value = [[[NSSet alloc] initWithObjects:objectsBuff count:self.count] autorelease];
        
        NSFreeObjectArray(objectsBuff);
        
        return value;
    }
}

- (id)d_valueForKeyPath:(NSString *)keyPath {
    if(keyPath.length && [keyPath characterAtIndex:0] == '@') {
        NSRange dotRange = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
        if(dotRange.length) {
            NSString *operator = [keyPath substringWithRange:NSMakeRange(1, dotRange.location - 1)];
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
                    id value = ((id (*)(id,Method,NSString *))method_invoke)(self,operatorMethod,keyPathForOperator);
                    return value;
                }
                else {
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
            NSString *key = [keyPath substringWithRange:NSMakeRange(1, keyPath.length - 1)];
            id value = [super d_valueForKey:key];
            return value;
        }
    }
    else {
        return [super d_valueForKeyPath: keyPath];
    }
}

- (void)d_setValue:(id)value forKey:(NSString *)key {
    for (id object in self) {
        [object d_setValue:value forKey:key];
    }
}

- (NSNumber *)_d_sumForKeyPath:(NSString *)keyPath {
    NSDecimal resultDecimal = {0};
    NSDecimalNumber *zero = [NSDecimalNumber zero];
    if (zero) {
        resultDecimal = [zero decimalValue];
    }
    
    NSDecimal eachDecimal = {0};
    for (id object in self) {
        id eachValue = [object d_valueForKeyPath:keyPath];
        if (eachValue) {
            eachDecimal = [eachValue decimalValue];
            NSDecimalAdd(&resultDecimal, &resultDecimal, &eachDecimal, NSRoundBankers);
        }
    }
    
    return [NSDecimalNumber decimalNumberWithDecimal:resultDecimal];
}

- (NSNumber *)_d_avgForKeyPath:(NSString *)keyPath {
    if (self.count) {
        return [(NSDecimalNumber*)[self _d_sumForKeyPath:keyPath]  decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithUnsignedInteger:self.count]];
    }
    return 0;
}

- (NSNumber *)_d_countForKeyPath:(NSString *)keyPath {
    return [NSNumber numberWithInteger:self.count];
}

- (id)_d_maxForKeyPath:(NSString *)keyPath {
    id maxValue = nil;
    for (id object in self) {
        id eachValue = [object d_valueForKeyPath:keyPath];
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

- (id)_d_minForKeyPath:(NSString *)keyPath {
    id minValue = nil;
    for (id object in self) {
        id eachValue = [object d_valueForKeyPath:keyPath];
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

- (NSSet *)_d_distinctUnionOfObjectsForKeyPath:(NSString *)keyPath {
    NSMutableSet *unionSet = [NSMutableSet setWithCapacity:self.count];
    for (id object in self) {
        [unionSet addObject:[object d_valueForKeyPath:keyPath]];
    }
    return unionSet;
}

- (NSSet *)_d_distinctUnionOfArraysForKeyPath:(NSString *)keyPath {
    NSMutableSet *unionSet = [NSMutableSet setWithCapacity:self.count];
    for (id object in self) {
        NSArray *arrayValue = [object d_valueForKeyPath:keyPath];
        if(arrayValue) {
            [unionSet addObjectsFromArray:arrayValue];
        }
    }
    return unionSet;
}

- (NSSet *)_d_distinctUnionOfSetsForKeyPath:(NSString *)keyPath {
    NSMutableSet *unionSet = [NSMutableSet setWithCapacity:self.count];
    for (id object in self) {
        id eachValue = [object d_valueForKeyPath:keyPath];
        if (eachValue) {
            [unionSet unionSet:eachValue];
        }
    }
    return unionSet;
}


@end
