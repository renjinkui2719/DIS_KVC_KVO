//
//  NSDictionary+DSKeyValueCoding.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/14.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSDictionary+DSKeyValueCoding.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "DSKeyValueCodingCommon.h"

@implementation NSDictionary (DSKeyValueCoding)

- (id)d_valueForKey:(NSString *)key {
    NSString *subKey = nil;
    if(key.length && [key characterAtIndex:0] == '@' && (subKey = [key substringWithRange:NSMakeRange(1, key.length - 1)])) {
        return [super valueForKey:subKey];
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
                NSString *subKeyBeforeDot = [keyPath substringWithRange:NSMakeRange(1, dotRange.location - 1)];
                NSString *subKeyPathAfterDot = [keyPath substringWithRange:NSMakeRange(dotRange.location + 1, keyPath.length - (dotRange.location + 1))];
                if(subKeyPathAfterDot) {
                    NSUInteger subKeyBeforeDotLen = [subKeyBeforeDot lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                    char subKeyBeforeDotCStr[subKeyBeforeDotLen + 1];
                    [subKeyBeforeDot getCString:subKeyBeforeDotCStr maxLength:subKeyBeforeDotLen + 1 encoding:NSUTF8StringEncoding];
                    Method valueForKeyPathMethod = DSKeyValueMethodForPattern(self.class, "%sForKeyPath:", subKeyBeforeDotCStr);
                    if(!valueForKeyPathMethod) {
                        valueForKeyPathMethod = DSKeyValueMethodForPattern(self.class, "_%sForKeyPath:", subKeyBeforeDotCStr);
                    }
                    if(valueForKeyPathMethod) {
                        return ((id (*)(id,Method,...))method_invoke)(self, valueForKeyPathMethod, subKeyPathAfterDot);
                    }
                    else {
                        [NSException raise:NSInvalidArgumentException format:@"[<%@ %p> valueForKeyPath:]: this class does not implement the %@ operation.", self.class, self, subKeyBeforeDot];
                        return nil;
                    }
                }
                else {
                    //loc_45CDD
                    return [super valueForKey: subKeyBeforeDot];
                }
            }
            else {
                //loc_45CBF
                NSString *subKey = [keyPath substringWithRange:NSMakeRange(1, keyPath.length - 1)];
                return [super valueForKey: subKey];
            }
        }
    }
    
    id value = [self objectForKey:keyPath];
    if(!value) {
        value = [super valueForKeyPath:keyPath];
    }
    return value;
}

@end
