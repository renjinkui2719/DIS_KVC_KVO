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
#import "DSKeyValueCodingCommon.h"

@implementation NSArray (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    NSString *subKey = nil;
    if (key.length && [key characterAtIndex:0] == '@' && (subKey = [key substringWithRange:NSMakeRange(1, key.length - 1)])) {
        id value =  [super d_valueForKey:subKey];
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
    if(keyPath.length && [keyPath characterAtIndex:0] == '@') {
        NSRange dotRange = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
        if(dotRange.length) {
            NSString *subKeyBeforDot = [[keyPath substringWithRange:NSMakeRange(1, dotRange.location - 1)] retain];
            NSString *subKeyPathAfterDot = [[keyPath substringWithRange:NSMakeRange(dotRange.location + 1, keyPath.length - (dotRange.location + 1))] retain];
            if(subKeyPathAfterDot) {
                NSUInteger subKeyBeforDotCStrLength = [subKeyBeforDot lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                char subKeyBeforDotCStr[subKeyBeforDotCStrLength + 1];
                
                [subKeyBeforDot getCString:subKeyBeforDotCStr maxLength:subKeyBeforDotCStrLength + 1 encoding:NSUTF8StringEncoding];
                
                Method valueForKeyPathMethod = DSKeyValueMethodForPattern(self.class, "d_%sForKeyPath:", subKeyBeforDotCStr);
                if(!valueForKeyPathMethod) {
                    valueForKeyPathMethod = DSKeyValueMethodForPattern(self.class, "_d_%sForKeyPath:", subKeyBeforDotCStr);
                }
                if (valueForKeyPathMethod) {
                    //loc_471D6
                    id computedValue = ((id (*)(id,Method,NSString *))method_invoke)(self,valueForKeyPathMethod,subKeyPathAfterDot);
                    [subKeyPathAfterDot release];
                    [subKeyBeforDot release];
                    return computedValue;
                }
                else {
                    //loc_4729D
                    [subKeyPathAfterDot release];
                    [subKeyBeforDot autorelease];
                    
                    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> valueForKeyPath:]: this class does not implement the %@ operation.", self.class,self,subKeyBeforDot];
                    
                    return nil;
                }
            }
            else {
                //loc_4724A
                id value = [super d_valueForKeyPath:subKeyBeforDot];
                [subKeyBeforDot release];
                return value;
            }
        }
        else {
            //loc_4722E
            NSString *subKey = [[keyPath substringWithRange:NSMakeRange(1, keyPath.length - 1)] retain];
            id value = [super d_valueForKeyPath:subKey];
            [subKey release];
            return value;
        }
    }
    else {
        //loc_47205
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
        ((void (*)(NSDecimal *, id, SEL))objc_msgSend_stret)(&resultDecimal, zero, @selector(decimalValue));
    }
    
    NSDecimal eachDecimal = {0};
    for (NSUInteger i=0; i<self.count; ++i) {
        id eachValue = [self _d_valueForKeyPath:keyPath ofObjectAtIndex:i];
        if (eachValue) {
            ((void (*)(NSDecimal *, id, SEL))objc_msgSend_stret)(&eachDecimal, zero, @selector(decimalValue));
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

- (NSArray *)_d_distinctUnionOfObjectsForKeyPath:(NSString *)keyPath {
    NSArray *unionArray = [self _d_unionOfObjectsForKeyPath:keyPath];
    return [NSSet setWithArray:unionArray].allObjects;
}

- (NSArray *)_d_distinctUnionOfArraysForKeyPath:(NSString *)keyPath {
    NSArray *unionArray = [self _d_unionOfArraysForKeyPath:keyPath];
    return [NSSet setWithArray:unionArray].allObjects;
}

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
