//
//  NSOrderedSet+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSOrderedSet+DSKeyValueCoding.h"
#import "NSOrderedSet+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "DSKeyValueCodingCommon.h"

@implementation NSOrderedSet (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    NSString *subKey = nil;
    if (key.length && [key characterAtIndex:0] == '@' && (subKey = [[key substringWithRange:NSMakeRange(1, key.length - 1)] retain])) {
        id value =  [super valueForKey:subKey];
        return value;
    }
    else {
        id *objectsBuff = NSAllocateObjectArray(self.count);
        NSUInteger cnt = 0;
        
        for (id object in self) {
            id eachValue = [object valueForKey:key];
            if (eachValue) {
                objectsBuff[cnt++] = eachValue;
            }
        }
        
        NSOrderedSet *valueSet = [[[NSOrderedSet alloc] initWithObjects:objectsBuff count:cnt] autorelease];
        
        NSFreeObjectArray(objectsBuff);
        
        return valueSet;
    }
}

- (id)d_valueForKeyPath:(NSString *)keyPath {
    if(keyPath.length && [keyPath characterAtIndex:0] == '@') {
        NSRange dotRange = [keyPath rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(0, keyPath.length)];
        if(dotRange.length) {
            NSString *subKeyBeforDot = [keyPath substringWithRange:NSMakeRange(1, dotRange.location - 1)];
            NSString *subKeyPathAfterDot = [keyPath substringWithRange:NSMakeRange(dotRange.location + 1, keyPath.length - (dotRange.location + 1))];
            
            if(subKeyPathAfterDot) {
                NSUInteger subKeyBeforDotCStrLength = [subKeyBeforDot lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                char subKeyBeforDotCStr[subKeyBeforDotCStrLength + 1];
                
                [subKeyBeforDot getCString:subKeyBeforDotCStr maxLength:subKeyBeforDotCStrLength + 1 encoding:NSUTF8StringEncoding];
                
                Method valueForKeyPathMethod = DSKeyValueMethodForPattern(self.class, "%sForKeyPath:", subKeyBeforDotCStr);
                if(!valueForKeyPathMethod) {
                    valueForKeyPathMethod = DSKeyValueMethodForPattern(self.class, "_%sForKeyPath:", subKeyBeforDotCStr);
                }
                if (valueForKeyPathMethod) {
                    id computedValue = ((id (*)(id,Method,NSString *))method_invoke)(self,valueForKeyPathMethod,subKeyPathAfterDot);
                    return computedValue;
                }
                else {
                    [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> valueForKeyPath:]: this class does not implement the %@ operation.", self.class,self,subKeyBeforDot];
                    
                    return nil;
                }
            }
            else {
                id value = [super valueForKey:subKeyBeforDot];
                return value;
            }
        }
        else {
            NSString *subKey = [keyPath substringWithRange:NSMakeRange(1, keyPath.length - 1)];
            id value = [super valueForKey:subKey];
            return value;
        }
    }
    else {
        return [super valueForKeyPath: keyPath];
    }
}

- (void)d_setValue:(id)value forKey:(NSString *)key {
    for (id object in self) {
        [object setValue:value forKey:key];
    }
}

- (NSNumber *)_d_sumForKeyPath:(NSString *)keyPath {
    NSDecimal resultDecimal = {0};
    NSDecimalNumber *zero = [NSDecimalNumber zero];
    if (zero) {
        ((void (*)(NSDecimal *, id, SEL))objc_msgSend_stret)(&resultDecimal, zero, @selector(decimalValue));
    }
    
    NSDecimal eachDecimal = {0};
    for (id object in self) {
        id eachValue = [object valueForKeyPath:keyPath];
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
    for (id object in self) {
        id eachValue = [object valueForKeyPath:keyPath];
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
        id eachValue = [object valueForKeyPath:keyPath];
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


@end
