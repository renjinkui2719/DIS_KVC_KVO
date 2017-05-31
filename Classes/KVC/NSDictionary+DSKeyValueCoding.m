//
//  NSDictionary+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSDictionary+DSKeyValueCoding.h"
#import "NSObject+DSKeyValueCoding.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "DSKeyValueCodingCommon.h"

@implementation NSDictionary (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    NSString *operationKey = nil;
    if(key.length && [key characterAtIndex:0] == '@' && (operationKey = [key substringWithRange:NSMakeRange(1, key.length - 1)])) {
        return [super d_valueForKey:operationKey];
    }
    else {
        return [self objectForKey:key];
    }
}

- (id)d_valueForKeyPath:(NSString *)keyPath {
    if(keyPath.length) {
        if([keyPath characterAtIndex:0] == '@') {
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
                    if(operatorMethod) {
                        return ((id (*)(id,Method,NSString *))method_invoke)(self, operatorMethod, keyPathForOperator);
                    }
                    else {
                        [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> valueForKeyPath:]: this class does not implement the %@ operation.", self.class, self, operator];
                        return nil;
                    }
                }
                else {
                    //loc_45CDD
                    return [super d_valueForKey: operator];
                }
            }
            else {
                //loc_45CBF
                NSString *key = [keyPath substringWithRange:NSMakeRange(1, keyPath.length - 1)];
                return [super d_valueForKey: key];
            }
        }
    }
    
    id value = [self objectForKey:keyPath];
    if(!value) {
        value = [super d_valueForKeyPath:keyPath];
    }
    return value;
}

@end
