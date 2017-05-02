//
//  main.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/1.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueCodingCommon.h"
#import "NSObject+DSKeyValueCoding.h"
#import <limits.h>

#define TEST_1(condition) {\
    printf("%s [%s:%d] => %s\n",(condition) ? "✅" : "❌", __FUNCTION__, __LINE__, #condition);\
}\


#define TEST_2(condition, test_expressions...) {\
    test_expressions;    printf("%s [%s:%d] => %s\n",(condition) ? "✅" : "❌", __FUNCTION__, __LINE__, #test_expressions);\
}\


#define NEW_LINE printf("\n");
#define SEP_LINE printf("==========================================================================================================\n");

@interface NSString(Random)
+ (NSString *)random:(NSUInteger)len;
@end
@implementation NSString(Random)
+ (NSString *)random:(NSUInteger)len {
    NSMutableString *string = [NSMutableString string];
    NSString *CHARATCERS = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    for (NSUInteger i = 0; i < len; ++i) {
        [string appendFormat:@"%c", CHARATCERS.UTF8String[arc4random() % CHARATCERS.length]];
    }
    return  string;
}
@end

@interface A : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) BOOL BOOL_field;
@property (nonatomic, assign) char char_field;
@property (nonatomic, assign) unsigned char unsigned_char_field;
@property (nonatomic, assign) short short_field;
@property (nonatomic, assign) unsigned short unsigned_short_field;
@property (nonatomic, assign) int int_field;
@property (nonatomic, assign) unsigned int unsigned_int_field;
@property (nonatomic, assign) long long_field;
@property (nonatomic, assign) unsigned long unsigned_long_field;
@property (nonatomic, assign) long long long_long_field;
@property (nonatomic, assign) unsigned long long unsigned_long_long_field;
@property (nonatomic, assign) float float_field;
@property (nonatomic, assign) double double_field;
@property (nonatomic, assign) NSPoint NSPoint_field;
@property (nonatomic, assign) NSRange NSRange_field;
@property (nonatomic, assign) NSRect NSRect_field;
@property (nonatomic, assign) CGPoint CGPoint_field;
@property (nonatomic, assign) CGRect CGRect_field;

@property (nonatomic, strong) A *A_field;
@property (nonatomic, strong) NSArray<A *> *NSArray_field;
@property (nonatomic, strong) NSSet<A *> *NSSet_field;
@property (nonatomic, strong) NSOrderedSet<A *> *NSOrderedSet_field;

@end
@implementation A

- (BOOL)isEqual:(id)object {
    if (object == self) { return YES; }
    if (![object isKindOfClass:self.class]) { return NO; }
    A *other = (A *)object;
    return [_identifier isEqualToString:other.identifier];
}

- (NSUInteger)hash {
    return _identifier.hash;
}

@end

@interface A(Random)
+ (instancetype)random;
+ (instancetype)randomWithIdentifier:(NSString *)identifier;
@end
@implementation A(Random)
+ (instancetype)random {
    return [self randomWithIdentifier:[NSString random:20]];
}

+ (instancetype)randomWithIdentifier:(NSString *)identifier {
    A *a = [A new];
    a.identifier = identifier;
    a.char_field = arc4random();
    a.BOOL_field = arc4random() % 2 == 0;
    a.unsigned_char_field = arc4random();
    a.short_field = arc4random();
    a.unsigned_short_field = arc4random();
    a.int_field = arc4random();
    a.unsigned_int_field = arc4random();
    a.long_field = arc4random();
    a.unsigned_long_field = arc4random();
    a.long_long_field = arc4random();
    a.unsigned_long_long_field = arc4random();
    a.float_field = arc4random()/100.0;
    a.double_field = arc4random()/100.0;
    a.NSPoint_field = NSMakePoint(arc4random()/100.0, arc4random()/100.0);
    a.NSRange_field = NSMakeRange(arc4random()/100.0, arc4random()/100.0);
    a.NSRect_field = NSMakeRect(arc4random()/100.0, arc4random()/100.0, arc4random()/100.0, arc4random()/100.0);
    a.CGPoint_field = CGPointMake(arc4random()/100.0, arc4random()/100.0);
    a.CGRect_field = CGRectMake(arc4random()/100.0, arc4random()/100.0, arc4random()/100.0, arc4random()/100.0);
    return a;
}
@end

void TestKVC();

int main(int argc, const char * argv[]) {
    
    
    NSLog(@"");
    
    TestKVC();
}



void TestKVC() {
    {
        SEP_LINE
        //==============测试 d_valueForKey:  d_setValue:forKey:  d_valueForKeyPath:  d_setValue:forKeyPath:  ==========
        //======================一级的key======================
        A *a = [A new];
        //BOOL 类型
        //以d_setValue:forKey:设置值, 以点.运算符取值对比
        TEST_2(a.BOOL_field == YES, [a d_setValue:@YES forKey:@"BOOL_field"]);
        //以d_valueForKey:取值对比
        TEST_1([[a d_valueForKey:@"BOOL_field"] isEqual:@YES]);
        //以d_valueForKeyPath:取值对比
        TEST_1([[a d_valueForKeyPath:@"BOOL_field"] isEqual:@YES]);
        
        //以d_setValue:forKeyPath:设置值, 以点.运算符取值对比
        TEST_2(a.BOOL_field == NO, [a d_setValue:@NO forKeyPath:@"BOOL_field"]);
        //以d_valueForKey:取值对比
        TEST_1([[a d_valueForKey:@"BOOL_field"] isEqual:@NO]);
        //以d_valueForKeyPath:取值对比
        TEST_1([[a d_valueForKeyPath:@"BOOL_field"] isEqual:@NO]);
        
        NEW_LINE
        //char 类型
        TEST_2(a.char_field == CHAR_MAX, [a d_setValue:@CHAR_MAX forKey:@"char_field"]);
        TEST_1([[a d_valueForKey:@"char_field"] isEqual:@CHAR_MAX]);
        TEST_1([[a d_valueForKeyPath:@"char_field"] isEqual:@CHAR_MAX]);
        
        TEST_2(a.char_field == CHAR_MIN, [a d_setValue:@CHAR_MIN forKeyPath:@"char_field"]);
        TEST_1([[a d_valueForKey:@"char_field"] isEqual:@CHAR_MIN]);
        TEST_1([[a d_valueForKeyPath:@"char_field"] isEqual:@CHAR_MIN]);
        
        NEW_LINE
        
        //unsigned char 类型
        TEST_2(a.unsigned_char_field == UCHAR_MAX, [a d_setValue:@UCHAR_MAX forKey:@"unsigned_char_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_char_field"] isEqual:@UCHAR_MAX]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_char_field"] isEqual:@UCHAR_MAX]);
        
        TEST_2(a.unsigned_char_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_char_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_char_field"] isEqual:@0]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_char_field"] isEqual:@0]);
        
        NEW_LINE
        //short 类型
        TEST_2(a.short_field == SHRT_MAX, [a d_setValue:@SHRT_MAX forKey:@"short_field"]);
        TEST_1([[a d_valueForKey:@"short_field"] isEqual:@SHRT_MAX]);
        TEST_1([[a d_valueForKeyPath:@"short_field"] isEqual:@SHRT_MAX]);
        
        TEST_2(a.short_field == SHRT_MIN, [a d_setValue:@SHRT_MIN forKeyPath:@"short_field"]);
        TEST_1([[a d_valueForKey:@"short_field"] isEqual:@SHRT_MIN]);
        TEST_1([[a d_valueForKeyPath:@"short_field"] isEqual:@SHRT_MIN]);
        
        NEW_LINE
        //unsigned short 类型
        TEST_2(a.unsigned_short_field == USHRT_MAX, [a d_setValue:@USHRT_MAX forKey:@"unsigned_short_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_short_field"] isEqual:@USHRT_MAX]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_short_field"] isEqual:@USHRT_MAX]);
        
        TEST_2(a.unsigned_short_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_short_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_short_field"] isEqual:@0]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_short_field"] isEqual:@0]);
        
        NEW_LINE
        //int 类型
        TEST_2(a.int_field == INT_MAX, [a d_setValue:@INT_MAX forKey:@"int_field"]);
        TEST_1([[a d_valueForKey:@"int_field"] isEqual:@INT_MAX]);
        TEST_1([[a d_valueForKeyPath:@"int_field"] isEqual:@INT_MAX]);
        
        TEST_2(a.int_field == INT_MIN, [a d_setValue:@INT_MIN forKeyPath:@"int_field"]);
        TEST_1([[a d_valueForKey:@"int_field"] isEqual:@INT_MIN]);
        TEST_1([[a d_valueForKeyPath:@"int_field"] isEqual:@INT_MIN]);
        
        NEW_LINE
        //unsigned int 类型
        TEST_2(a.unsigned_int_field == UINT_MAX, [a d_setValue:@UINT_MAX forKey:@"unsigned_int_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_int_field"] isEqual:@UINT_MAX]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_int_field"] isEqual:@UINT_MAX]);
        
        TEST_2(a.unsigned_int_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_int_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_int_field"] isEqual:@0]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_int_field"] isEqual:@0]);
        
        NEW_LINE
        //long 类型
        TEST_2(a.long_field == LONG_MAX, [a d_setValue:@LONG_MAX forKey:@"long_field"]);
        TEST_1([[a d_valueForKey:@"long_field"] isEqual:@LONG_MAX]);
        TEST_1([[a d_valueForKeyPath:@"long_field"] isEqual:@LONG_MAX]);
        
        TEST_2(a.long_field == LONG_MIN, [a d_setValue:@LONG_MIN forKeyPath:@"long_field"]);
        TEST_1([[a d_valueForKey:@"long_field"] isEqual:@LONG_MIN]);
        TEST_1([[a d_valueForKeyPath:@"long_field"] isEqual:@LONG_MIN]);
        
        NEW_LINE
        //unsigned long 类型
        TEST_2(a.unsigned_long_field == ULONG_MAX, [a d_setValue:@ULONG_MAX forKey:@"unsigned_long_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_long_field"] isEqual:@ULONG_MAX]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_long_field"] isEqual:@ULONG_MAX]);
        
        TEST_2(a.unsigned_long_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_long_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_long_field"] isEqual:@0]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_long_field"] isEqual:@0]);
        
        NEW_LINE
        //long long 类型
        TEST_2(a.long_long_field == LLONG_MAX, [a d_setValue:@LLONG_MAX forKey:@"long_long_field"]);
        TEST_1([[a d_valueForKey:@"long_long_field"] isEqual:@LLONG_MAX]);
        TEST_1([[a d_valueForKeyPath:@"long_long_field"] isEqual:@LLONG_MAX]);
        
        TEST_2(a.long_long_field == LLONG_MIN, [a d_setValue:@LLONG_MIN forKeyPath:@"long_long_field"]);
        TEST_1([[a d_valueForKey:@"long_long_field"] isEqual:@LLONG_MIN]);
        TEST_1([[a d_valueForKeyPath:@"long_long_field"] isEqual:@LLONG_MIN]);
        
        NEW_LINE
        //unsigned long long 类型
        TEST_2(a.unsigned_long_long_field == ULLONG_MAX, [a d_setValue:@ULLONG_MAX forKey:@"unsigned_long_long_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_long_long_field"] isEqual:@ULLONG_MAX]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_long_long_field"] isEqual:@ULLONG_MAX]);
        
        TEST_2(a.unsigned_long_long_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_long_long_field"]);
        TEST_1([[a d_valueForKey:@"unsigned_long_long_field"] isEqual:@0]);
        TEST_1([[a d_valueForKeyPath:@"unsigned_long_long_field"] isEqual:@0]);
        
        NEW_LINE
        //float 类型
        TEST_2(a.float_field == MAXFLOAT, [a d_setValue:@MAXFLOAT forKey:@"float_field"]);
        TEST_1([[a d_valueForKey:@"float_field"] isEqual:@MAXFLOAT]);
        TEST_1([[a d_valueForKeyPath:@"float_field"] isEqual:@MAXFLOAT]);
        
        TEST_2(a.float_field == 12.0, [a d_setValue:@12.0 forKeyPath:@"float_field"]);
        TEST_1([[a d_valueForKey:@"float_field"] isEqual:@12.0]);
        TEST_1([[a d_valueForKeyPath:@"float_field"] isEqual:@12.0]);
        
        NEW_LINE
        //double 类型
        TEST_2(a.double_field == MAXFLOAT, [a d_setValue:@MAXFLOAT forKey:@"double_field"]);
        TEST_1([[a d_valueForKey:@"double_field"] isEqual:@MAXFLOAT]);
        TEST_1([[a d_valueForKeyPath:@"double_field"] isEqual:@MAXFLOAT]);
        
        TEST_2(a.double_field == 13.0, [a d_setValue:@13.0 forKeyPath:@"double_field"]);
        TEST_1([[a d_valueForKey:@"double_field"] isEqual:@13.0]);
        TEST_1([[a d_valueForKeyPath:@"double_field"] isEqual:@13.0]);
        
        NEW_LINE

        //NSPoint 类型
        TEST_2(a.NSPoint_field.x == 10 && a.NSPoint_field.y == 20, [a d_setValue:[NSValue valueWithPoint:NSMakePoint(10, 20)] forKey:@"NSPoint_field"]);
        TEST_1([[a d_valueForKey:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(10, 20)]]);
        TEST_1([[a d_valueForKeyPath:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(10, 20)]]);
        
        TEST_2(a.NSPoint_field.x == 100 && a.NSPoint_field.y == 200, [a d_setValue:[NSValue valueWithPoint:NSMakePoint(100, 200)] forKey:@"NSPoint_field"]);
        TEST_1([[a d_valueForKey:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(100, 200)]]);
        TEST_1([[a d_valueForKeyPath:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(100, 200)]]);
        
        NEW_LINE
        //NSRange 类型
        TEST_2(a.NSRange_field.location == 10 && a.NSRange_field.length == 20, [a d_setValue:[NSValue valueWithRange:NSMakeRange(10, 20)] forKey:@"NSRange_field"]);
        TEST_1([[a d_valueForKey:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(10, 20)]]);
        TEST_1([[a d_valueForKeyPath:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(10, 20)]]);
        
        TEST_2(a.NSRange_field.location == 100 && a.NSRange_field.length == 200, [a d_setValue:[NSValue valueWithRange:NSMakeRange(100, 200)] forKey:@"NSRange_field"]);
        TEST_1([[a d_valueForKey:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(100, 200)]]);
        TEST_1([[a d_valueForKeyPath:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(100, 200)]]);
        
        NEW_LINE
        
        //NSRect 类型
        TEST_2(a.NSRect_field.origin.x == 10 && a.NSRect_field.origin.y == 20 && a.NSRect_field.size.width == 30 && a.NSRect_field.size.height == 40, [a d_setValue:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)] forKey:@"NSRect_field"]);
        TEST_1([[a d_valueForKey:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)]]);
        TEST_1([[a d_valueForKeyPath:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)]]);
        
        TEST_2(a.NSRect_field.origin.x == 100 && a.NSRect_field.origin.y == 200 && a.NSRect_field.size.width == 300 && a.NSRect_field.size.height == 400, [a d_setValue:[NSValue valueWithRect:NSMakeRect(100, 200, 300, 400)] forKeyPath:@"NSRect_field"]);
        TEST_1([[a d_valueForKey:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(100, 200, 300, 400)]]);
        TEST_1([[a d_valueForKeyPath:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(100, 200, 300, 400)]]);
        
        NEW_LINE
        //CGPoint 类型
        TEST_2(a.CGPoint_field.x == 10 && a.CGPoint_field.y == 20, [a d_setValue:[NSValue valueWithPoint:CGPointMake(10, 20)] forKey:@"CGPoint_field"]);
        TEST_1([[a d_valueForKey:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(10, 20)]]);
        TEST_1([[a d_valueForKeyPath:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(10, 20)]]);
        
        TEST_2(a.CGPoint_field.x == 100 && a.CGPoint_field.y == 200, [a d_setValue:[NSValue valueWithPoint:CGPointMake(100, 200)] forKey:@"CGPoint_field"]);
        TEST_1([[a d_valueForKey:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(100, 200)]]);
        TEST_1([[a d_valueForKeyPath:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(100, 200)]]);
        
        NEW_LINE
        //CGRect 类型
        TEST_2(a.CGRect_field.origin.x == 10 && a.CGRect_field.origin.y == 20 && a.CGRect_field.size.width == 30 && a.CGRect_field.size.height == 40, [a d_setValue:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)] forKey:@"CGRect_field"]);
        TEST_1([[a d_valueForKey:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)]]);
        TEST_1([[a d_valueForKeyPath:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)]]);
        
        TEST_2(a.CGRect_field.origin.x == 100 && a.CGRect_field.origin.y == 200 && a.CGRect_field.size.width == 300 && a.CGRect_field.size.height == 400, [a d_setValue:[NSValue valueWithRect:CGRectMake(100, 200, 300, 400)] forKeyPath:@"CGRect_field"]);
        TEST_1([[a d_valueForKey:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(100, 200, 300, 400)]]);
        TEST_1([[a d_valueForKeyPath:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(100, 200, 300, 400)]]);
        NEW_LINE
        //对象类型
        A *A_field = [A random];
        TEST_2(a.A_field == A_field, [a d_setValue:A_field forKey:@"A_field"]);
        TEST_1([[a d_valueForKey:@"A_field"] isEqual:A_field]);
        TEST_1([[a d_valueForKeyPath:@"A_field"] isEqual:A_field]);
        
        A_field = [A random];
        TEST_2(a.A_field == A_field, [a d_setValue:A_field forKeyPath:@"A_field"]);
        TEST_1([[a d_valueForKey:@"A_field"] isEqual:A_field]);
        TEST_1([[a d_valueForKeyPath:@"A_field"] isEqual:A_field]);
        
        
        NEW_LINE
        NSArray<A *> *NSArray_field = @[[A random], [A random], [A random], [A random], [A random], [A random]];
        TEST_2(a.NSArray_field == NSArray_field, [a d_setValue:NSArray_field forKey:@"NSArray_field"]);
        TEST_1([[a d_valueForKey:@"NSArray_field"] isEqualToArray:NSArray_field]);
        TEST_1([[a d_valueForKeyPath:@"NSArray_field"] isEqualToArray:NSArray_field]);
        
        NSArray_field = @[[A random], [A random], [A random], [A random], [A random], [A random]];
        TEST_2(a.NSArray_field == NSArray_field, [a d_setValue:NSArray_field forKeyPath:@"NSArray_field"]);
        TEST_1([[a d_valueForKey:@"NSArray_field"] isEqualToArray:NSArray_field]);
        TEST_1([[a d_valueForKeyPath:@"NSArray_field"] isEqualToArray:NSArray_field]);
        
        
        NEW_LINE
        NSSet<A *> *NSSet_field = [NSSet setWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_2(a.NSSet_field == NSSet_field, [a d_setValue:NSSet_field forKey:@"NSSet_field"]);
        TEST_1([[a d_valueForKey:@"NSSet_field"] isEqualToSet:NSSet_field]);
        TEST_1([[a d_valueForKeyPath:@"NSSet_field"] isEqualToSet:NSSet_field]);
        
        NSSet_field = [NSSet setWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_2(a.NSSet_field == NSSet_field, [a d_setValue:NSSet_field forKeyPath:@"NSSet_field"]);
        TEST_1([[a d_valueForKey:@"NSSet_field"] isEqualToSet:NSSet_field]);
        TEST_1([[a d_valueForKeyPath:@"NSSet_field"] isEqualToSet:NSSet_field]);
        
        
        NEW_LINE
        NSOrderedSet<A *> *NSOrderedSet_field = [NSOrderedSet orderedSetWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_2(a.NSOrderedSet_field == NSOrderedSet_field, [a d_setValue:NSOrderedSet_field forKey:@"NSOrderedSet_field"]);
        TEST_1([[a d_valueForKey:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        TEST_1([[a d_valueForKeyPath:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        
        NSOrderedSet_field = [NSOrderedSet orderedSetWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_2(a.NSOrderedSet_field == NSOrderedSet_field, [a d_setValue:NSOrderedSet_field forKeyPath:@"NSOrderedSet_field"]);
        TEST_1([[a d_valueForKey:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        TEST_1([[a d_valueForKeyPath:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        
        NEW_LINE
        
        //======================多级的keyPath======================

        TEST_2(a.A_field.unsigned_long_field == ULONG_MAX, [a d_setValue:@ULONG_MAX forKeyPath:@"A_field.unsigned_long_field"]);
        TEST_1([[a d_valueForKeyPath:@"A_field.unsigned_long_field"] isEqual:@ULONG_MAX]);
        NEW_LINE
        a.A_field.A_field = [A random];

        TEST_2(a.A_field.A_field.unsigned_long_field == ULONG_MAX, [a d_setValue:@ULONG_MAX forKeyPath:@"A_field.A_field.unsigned_long_field"]);
        TEST_1([[a d_valueForKeyPath:@"A_field.A_field.unsigned_long_field"] isEqual:@ULONG_MAX]);
        
        SEP_LINE
    }
    
    {
        SEP_LINE
        A *a = [A random];
        //==============测试不识别的key(Path)==========
        //应当抛出NSUnknownKeyException异常
        {
            NSException *catchException = nil;
            @try {
                [a d_valueForKey:@"xxx"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            catchException = nil;
            @try {
                [a d_setValue:@1 forKey:@"xxx"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
            }
        }
        NEW_LINE
        {
            NSException *catchException = nil;
            @try {
                [a d_valueForKeyPath:@"xxx.yyy.zzz"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            catchException = nil;
            @try {
                [a d_setValue:@1 forKeyPath:@"xxx.yyy.zzz"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
            }
        }
        SEP_LINE
    }
    
    {
        SEP_LINE
        A *a = [A random];
        a.A_field = [A random];
        //=====================测试key与keyPath的区别,key可以当keyPath用，keyPath不可以当key用=====================
        //key只支持一级的路径("xxx")，keyPath支持多级路径("xxx.yyy.zzz")
        //以keyPath去调用d_valueForKey:， 内部不会解析keyPath，而直接当一级的key， 故抛出NSUnknownKeyException
        {
            NSException *catchException = nil;
            @try {
                [a d_valueForKey:@"A_field.char_field"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            TEST_1([[a.A_field d_valueForKey:@"char_field"] isEqual: @(a.A_field.char_field)]);
            
            catchException = nil;
            @try {
                [a d_setValue:@(10) forKey:@"A_field.char_field"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            TEST_2(a.A_field.char_field == 10, [a.A_field d_setValue:@(10) forKey:@"char_field"];);
        }
        //以keyPath去调用d_valueForKeyPath:与调用d_valueForKey:相同
        {
            TEST_2(a.A_field.char_field == 10, [a d_setValue:@(10) forKeyPath:@"A_field.char_field"];);
            TEST_2(a.A_field.char_field == 10, [a.A_field d_setValue:@(10) forKeyPath:@"char_field"];);
            
            TEST_1([@(a.A_field.char_field) isEqual: [a d_valueForKeyPath:@"A_field.char_field"]]);
            TEST_1([@(a.A_field.char_field) isEqual: [a.A_field d_valueForKeyPath:@"char_field"]]);
        }
        
        SEP_LINE
    }
    
    {
        SEP_LINE
        
        NSArray *array = @[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],
                           [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"004"],
                           [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"007"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"003"]];
        for (A *a in array) {
            NSArray *testArray = @[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],
                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"004"],
                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"007"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"003"]];
            a.NSArray_field = testArray;
            a.NSSet_field = [NSSet setWithArray:testArray];
        }
        //=========================测试NSArray=========================
        //每个对象的char_field组成的新数组
        NSArray *char_field_Array = [array d_valueForKeyPath:@"char_field"];
        //和系统方法返回值做比较，相同则认为通过，下面很多处测试采用这种方法
        TEST_1([char_field_Array isEqualToArray:[array valueForKeyPath:@"char_field"]]);
        
        //每个对象的char_field都被设置为11
        [array setValue:@11 forKeyPath:@"char_field"];
        BOOL allSet_to_11 = YES;
        for (A *a in array) {
            if (a.char_field != 11) {
                allSet_to_11 = NO;
                break;
            }
        }
        TEST_1(allSet_to_11);
        
        //测试集合运算符
        //NSArray支持:@count,@sum,@avg,@max,@min,@unionOfObjects,@distinctUnionOfObjects,@unionOfArrays,@distinctUnionOfArrays,@unionOfSets,@distinctUnionOfSets
        id result = [array d_valueForKeyPath:@"@count"];
        TEST_1([result isEqual:[array valueForKeyPath:@"@count"]]);
        
        result = [array d_valueForKeyPath:@"@sum.float_field"];
        TEST_1([result isEqual:[array valueForKeyPath:@"@sum.float_field"]]);
        
        result = [array d_valueForKeyPath:@"@avg.float_field"];
        TEST_1([result isEqual:[array valueForKeyPath:@"@avg.float_field"]]);
        
        result = [array d_valueForKeyPath:@"@max.float_field"];
        TEST_1([result isEqual:[array valueForKeyPath:@"@max.float_field"]]);
        
        result = [array d_valueForKeyPath:@"@min.float_field"];
        TEST_1([result isEqual:[array valueForKeyPath:@"@min.float_field"]]);
        
        //每个对象identifier字段组成的数组
        result = [array d_valueForKeyPath:@"@unionOfObjects.identifier"];
        TEST_1([result isEqualToArray:[array valueForKeyPath:@"@unionOfObjects.identifier"]]);
        
        //每个对象identifier字段组成的数组 & 去重复
        result = [array d_valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
        TEST_1([result isEqualToArray:[array valueForKeyPath:@"@distinctUnionOfObjects.identifier"]]);
        
        
        //每个对象的NSArray_field字段的各个对象组成的数组
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,1,3,4,3,6,7,8,8]
        result = [array d_valueForKeyPath:@"@unionOfArrays.NSArray_field"];
        TEST_1([result isEqualToArray:[array valueForKeyPath:@"@unionOfArrays.NSArray_field"]]);
        
        //每个对象的NSArray_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8,9]
        result = [array d_valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"];
        TEST_1([result isEqualToArray:[array valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"]]);
        
        
        //每个对象的NSSet_field字段的各个对象组成的数组
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,3,6,7,8]
        result = [array d_valueForKeyPath:@"@unionOfSets.NSSet_field"];
        TEST_1([result isEqualToArray:[array valueForKeyPath:@"@unionOfSets.NSSet_field"]]);
        
        //每个对象的NSSet_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8]
        result = [array d_valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"];
        TEST_1([result isEqualToArray:[array valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"]]);
        
        SEP_LINE
        
    }
    
    {
        SEP_LINE
        
        NSSet *set = [NSSet setWithArray: @[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],
                                            [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"004"],
                                            [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"007"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"003"]]];
        for (A *a in set) {
            NSArray *testArray = @[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],
                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"004"],
                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"007"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"003"]];
            a.NSArray_field = testArray;
            a.NSSet_field = [NSSet setWithArray:testArray];
        }
        //=========================测试NSSet=========================
        //每个对象的char_field组成的新数组
        NSSet *char_field_Set = [set d_valueForKeyPath:@"char_field"];
        //和系统方法返回值做比较，相同则认为通过，下面很多处测试采用这种方法
        TEST_1([char_field_Set isEqualToSet:[set valueForKeyPath:@"char_field"]]);
        
        //每个对象的char_field都被设置为11
        [set setValue:@11 forKeyPath:@"char_field"];
        BOOL allSet_to_11 = YES;
        for (A *a in set) {
            if (a.char_field != 11) {
                allSet_to_11 = NO;
                break;
            }
        }
        TEST_1(allSet_to_11);
        
        //测试集合运算符
        //NSSet支持:@count,@sum,@avg,@max,@min,@distinctUnionOfObjects,@distinctUnionOfArrays,@distinctUnionOfSets
        id result = [set d_valueForKeyPath:@"@count"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@count"]]);
        
        result = [set d_valueForKeyPath:@"@sum.float_field"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@sum.float_field"]]);
        
        result = [set d_valueForKeyPath:@"@avg.float_field"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@avg.float_field"]]);
        
        result = [set d_valueForKeyPath:@"@max.float_field"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@max.float_field"]]);
        
        result = [set d_valueForKeyPath:@"@min.float_field"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@min.float_field"]]);
        
        //每个对象identifier字段组成的数组 & 去重复
        result = [set d_valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@distinctUnionOfObjects.identifier"]]);
        
        //每个对象的NSArray_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8,9]
        result = [set d_valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"]]);

        //每个对象的NSSet_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8]
        result = [set d_valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"];
        TEST_1([result isEqual:[set valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"]]);
        
        SEP_LINE
    }
    
    {
        SEP_LINE
        NSOrderedSet *orderSet = [NSOrderedSet orderedSetWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],
                                                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"004"],
                                                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"007"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"003"]]] ;
        for (A *a in orderSet) {
            NSArray *testArray = @[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],
                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"004"],
                                   [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"007"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"003"]];
            a.NSArray_field = testArray;
            a.NSSet_field = [NSSet setWithArray:testArray];
        }
        //=========================测试NSOrderedSet=========================
        //每个对象的char_field组成的新数组
        NSOrderedSet *char_field_OrderedSet = [orderSet d_valueForKeyPath:@"char_field"];
        //和系统方法返回值做比较，相同则认为通过，下面很多处测试采用这种方法
        TEST_1([char_field_OrderedSet isEqualToOrderedSet:[orderSet valueForKeyPath:@"char_field"]]);
        
        //每个对象的char_field都被设置为11
        [orderSet setValue:@11 forKeyPath:@"char_field"];
        BOOL allSet_to_11 = YES;
        for (A *a in orderSet) {
            if (a.char_field != 11) {
                allSet_to_11 = NO;
                break;
            }
        }
        TEST_1(allSet_to_11);
        
        //测试集合运算符
        //NSOrderedSet支持:@count,@sum,@avg,@max,@min
        id result = [orderSet d_valueForKeyPath:@"@count"];
        TEST_1([result isEqual:[orderSet valueForKeyPath:@"@count"]]);
        
        result = [orderSet d_valueForKeyPath:@"@sum.float_field"];
        TEST_1([result isEqual:[orderSet valueForKeyPath:@"@sum.float_field"]]);
        
        result = [orderSet d_valueForKeyPath:@"@avg.float_field"];
        TEST_1([result isEqual:[orderSet valueForKeyPath:@"@avg.float_field"]]);
        
        result = [orderSet d_valueForKeyPath:@"@max.float_field"];
        TEST_1([result isEqual:[orderSet valueForKeyPath:@"@max.float_field"]]);
        
        result = [orderSet d_valueForKeyPath:@"@min.float_field"];
        TEST_1([result isEqual:[orderSet valueForKeyPath:@"@min.float_field"]]);
        
        
        SEP_LINE
    }
    
    {
        SEP_LINE
        NSDictionary *dict = @{@"key1":@"v1",
                               @"key2":@[@"v2",@"v3"],
                               @"key3":[A random],
                               @"key4":@{@"key5":@{@"key6":@"v4", @"key7":@"v5"}, @"key7":@"v6"}
                               };
        //=========================测试NS(Mutable)Dictionary=========================
        id result = [dict d_valueForKey:@"key1"];
        TEST_1([result isEqual: [dict valueForKey:@"key1"]])
        
        result = [dict d_valueForKey:@"key2"];
        TEST_1([result isEqual: [dict valueForKey:@"key2"]])
        
        result = [dict d_valueForKey:@"key3"];
        TEST_1([result isEqual: [dict valueForKey:@"key3"]])
        
        result = [dict d_valueForKeyPath:@"key4.key5.key6"];
        TEST_1([result isEqual: [dict d_valueForKeyPath:@"key4.key5.key6"]])
        
        result = [dict d_valueForKeyPath:@"key4.key7"];
        TEST_1([result isEqual: [dict d_valueForKeyPath:@"key4.key7"]])

        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
        [mutDict d_setValue:@"v1" forKey:@"key1"];
        TEST_1([mutDict[@"key1"] isEqual: @"v1"]);
        [mutDict d_setValue:[NSMutableDictionary dictionary] forKey:@"key2"];
        [mutDict d_setValue:@"v3" forKeyPath:@"key2.key3"];
        TEST_1([mutDict[@"key2"][@"key3"] isEqual: @"v3"]);
        [mutDict d_setValue:nil forKeyPath:@"key2.key3"];
        TEST_1(mutDict[@"key2"][@"key3"] == nil);
        SEP_LINE
    }
    
    {
        SEP_LINE
        //=========================测试NSUserDefaults=========================
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults d_setValue:@"v1" forKey:@"key1"];
        TEST_1([[defaults d_valueForKey:@"key1"] isEqual: [defaults valueForKey:@"key1"]]);
        [defaults d_setValue:nil forKey:@"key1"];
        TEST_1([defaults d_valueForKey:@"key1"] == nil);
        SEP_LINE
    }
}
