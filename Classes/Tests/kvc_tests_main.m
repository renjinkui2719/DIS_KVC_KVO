#import "tests_define.h"

void kvc_tests_main() {
    {
        SEP_LINE
        //==============测试 d_valueForKey:  d_setValue:forKey:  d_valueForKeyPath:  d_setValue:forKeyPath:  ==========
        //======================一级的key======================
        A *a = [A new];
        //BOOL 类型
        //以d_setValue:forKey:设置值, 以get方法取值对比
        TEST_AFTER_EXECUTE(a.BOOL_field == YES, [a d_setValue:@YES forKey:@"BOOL_field"]);
        //以d_valueForKey:取值对比
        TEST([[a d_valueForKey:@"BOOL_field"] isEqual:@YES]);
        //以d_valueForKeyPath:取值对比
        TEST([[a d_valueForKeyPath:@"BOOL_field"] isEqual:@YES]);
        
        //以d_setValue:forKeyPath:设置值, 以get方法取值对比
        TEST_AFTER_EXECUTE(a.BOOL_field == NO, [a d_setValue:@NO forKeyPath:@"BOOL_field"]);
        //以d_valueForKey:取值对比
        TEST([[a d_valueForKey:@"BOOL_field"] isEqual:@NO]);
        //以d_valueForKeyPath:取值对比
        TEST([[a d_valueForKeyPath:@"BOOL_field"] isEqual:@NO]);
        
        NEW_LINE
        //char 类型
        TEST_AFTER_EXECUTE(a.char_field == CHAR_MAX, [a d_setValue:@CHAR_MAX forKey:@"char_field"]);
        TEST([[a d_valueForKey:@"char_field"] isEqual:@CHAR_MAX]);
        TEST([[a d_valueForKeyPath:@"char_field"] isEqual:@CHAR_MAX]);
        
        TEST_AFTER_EXECUTE(a.char_field == CHAR_MIN, [a d_setValue:@CHAR_MIN forKeyPath:@"char_field"]);
        TEST([[a d_valueForKey:@"char_field"] isEqual:@CHAR_MIN]);
        TEST([[a d_valueForKeyPath:@"char_field"] isEqual:@CHAR_MIN]);
        
        NEW_LINE
        
        //unsigned char 类型
        TEST_AFTER_EXECUTE(a.unsigned_char_field == UCHAR_MAX, [a d_setValue:@UCHAR_MAX forKey:@"unsigned_char_field"]);
        TEST([[a d_valueForKey:@"unsigned_char_field"] isEqual:@UCHAR_MAX]);
        TEST([[a d_valueForKeyPath:@"unsigned_char_field"] isEqual:@UCHAR_MAX]);
        
        TEST_AFTER_EXECUTE(a.unsigned_char_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_char_field"]);
        TEST([[a d_valueForKey:@"unsigned_char_field"] isEqual:@0]);
        TEST([[a d_valueForKeyPath:@"unsigned_char_field"] isEqual:@0]);
        
        NEW_LINE
        //short 类型
        TEST_AFTER_EXECUTE(a.short_field == SHRT_MAX, [a d_setValue:@SHRT_MAX forKey:@"short_field"]);
        TEST([[a d_valueForKey:@"short_field"] isEqual:@SHRT_MAX]);
        TEST([[a d_valueForKeyPath:@"short_field"] isEqual:@SHRT_MAX]);
        
        TEST_AFTER_EXECUTE(a.short_field == SHRT_MIN, [a d_setValue:@SHRT_MIN forKeyPath:@"short_field"]);
        TEST([[a d_valueForKey:@"short_field"] isEqual:@SHRT_MIN]);
        TEST([[a d_valueForKeyPath:@"short_field"] isEqual:@SHRT_MIN]);
        
        NEW_LINE
        //unsigned short 类型
        TEST_AFTER_EXECUTE(a.unsigned_short_field == USHRT_MAX, [a d_setValue:@USHRT_MAX forKey:@"unsigned_short_field"]);
        TEST([[a d_valueForKey:@"unsigned_short_field"] isEqual:@USHRT_MAX]);
        TEST([[a d_valueForKeyPath:@"unsigned_short_field"] isEqual:@USHRT_MAX]);
        
        TEST_AFTER_EXECUTE(a.unsigned_short_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_short_field"]);
        TEST([[a d_valueForKey:@"unsigned_short_field"] isEqual:@0]);
        TEST([[a d_valueForKeyPath:@"unsigned_short_field"] isEqual:@0]);
        
        NEW_LINE
        //int 类型
        TEST_AFTER_EXECUTE(a.int_field == INT_MAX, [a d_setValue:@INT_MAX forKey:@"int_field"]);
        TEST([[a d_valueForKey:@"int_field"] isEqual:@INT_MAX]);
        TEST([[a d_valueForKeyPath:@"int_field"] isEqual:@INT_MAX]);
        
        TEST_AFTER_EXECUTE(a.int_field == INT_MIN, [a d_setValue:@INT_MIN forKeyPath:@"int_field"]);
        TEST([[a d_valueForKey:@"int_field"] isEqual:@INT_MIN]);
        TEST([[a d_valueForKeyPath:@"int_field"] isEqual:@INT_MIN]);
        
        NEW_LINE
        //unsigned int 类型
        TEST_AFTER_EXECUTE(a.unsigned_int_field == UINT_MAX, [a d_setValue:@UINT_MAX forKey:@"unsigned_int_field"]);
        TEST([[a d_valueForKey:@"unsigned_int_field"] isEqual:@UINT_MAX]);
        TEST([[a d_valueForKeyPath:@"unsigned_int_field"] isEqual:@UINT_MAX]);
        
        TEST_AFTER_EXECUTE(a.unsigned_int_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_int_field"]);
        TEST([[a d_valueForKey:@"unsigned_int_field"] isEqual:@0]);
        TEST([[a d_valueForKeyPath:@"unsigned_int_field"] isEqual:@0]);
        
        NEW_LINE
        //long 类型
        TEST_AFTER_EXECUTE(a.long_field == LONG_MAX, [a d_setValue:@LONG_MAX forKey:@"long_field"]);
        TEST([[a d_valueForKey:@"long_field"] isEqual:@LONG_MAX]);
        TEST([[a d_valueForKeyPath:@"long_field"] isEqual:@LONG_MAX]);
        
        TEST_AFTER_EXECUTE(a.long_field == LONG_MIN, [a d_setValue:@LONG_MIN forKeyPath:@"long_field"]);
        TEST([[a d_valueForKey:@"long_field"] isEqual:@LONG_MIN]);
        TEST([[a d_valueForKeyPath:@"long_field"] isEqual:@LONG_MIN]);
        
        NEW_LINE
        //unsigned long 类型
        TEST_AFTER_EXECUTE(a.unsigned_long_field == ULONG_MAX, [a d_setValue:@ULONG_MAX forKey:@"unsigned_long_field"]);
        TEST([[a d_valueForKey:@"unsigned_long_field"] isEqual:@ULONG_MAX]);
        TEST([[a d_valueForKeyPath:@"unsigned_long_field"] isEqual:@ULONG_MAX]);
        
        TEST_AFTER_EXECUTE(a.unsigned_long_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_long_field"]);
        TEST([[a d_valueForKey:@"unsigned_long_field"] isEqual:@0]);
        TEST([[a d_valueForKeyPath:@"unsigned_long_field"] isEqual:@0]);
        
        NEW_LINE
        //long long 类型
        TEST_AFTER_EXECUTE(a.long_long_field == LLONG_MAX, [a d_setValue:@LLONG_MAX forKey:@"long_long_field"]);
        TEST([[a d_valueForKey:@"long_long_field"] isEqual:@LLONG_MAX]);
        TEST([[a d_valueForKeyPath:@"long_long_field"] isEqual:@LLONG_MAX]);
        
        TEST_AFTER_EXECUTE(a.long_long_field == LLONG_MIN, [a d_setValue:@LLONG_MIN forKeyPath:@"long_long_field"]);
        TEST([[a d_valueForKey:@"long_long_field"] isEqual:@LLONG_MIN]);
        TEST([[a d_valueForKeyPath:@"long_long_field"] isEqual:@LLONG_MIN]);
        
        NEW_LINE
        //unsigned long long 类型
        TEST_AFTER_EXECUTE(a.unsigned_long_long_field == ULLONG_MAX, [a d_setValue:@ULLONG_MAX forKey:@"unsigned_long_long_field"]);
        TEST([[a d_valueForKey:@"unsigned_long_long_field"] isEqual:@ULLONG_MAX]);
        TEST([[a d_valueForKeyPath:@"unsigned_long_long_field"] isEqual:@ULLONG_MAX]);
        
        TEST_AFTER_EXECUTE(a.unsigned_long_long_field == 0, [a d_setValue:@0 forKeyPath:@"unsigned_long_long_field"]);
        TEST([[a d_valueForKey:@"unsigned_long_long_field"] isEqual:@0]);
        TEST([[a d_valueForKeyPath:@"unsigned_long_long_field"] isEqual:@0]);
        
        NEW_LINE
        //float 类型
        TEST_AFTER_EXECUTE(a.float_field == MAXFLOAT, [a d_setValue:@MAXFLOAT forKey:@"float_field"]);
        TEST([[a d_valueForKey:@"float_field"] isEqual:@MAXFLOAT]);
        TEST([[a d_valueForKeyPath:@"float_field"] isEqual:@MAXFLOAT]);
        
        TEST_AFTER_EXECUTE(a.float_field == 12.0, [a d_setValue:@12.0 forKeyPath:@"float_field"]);
        TEST([[a d_valueForKey:@"float_field"] isEqual:@12.0]);
        TEST([[a d_valueForKeyPath:@"float_field"] isEqual:@12.0]);
        
        NEW_LINE
        //double 类型
        TEST_AFTER_EXECUTE(a.double_field == MAXFLOAT, [a d_setValue:@MAXFLOAT forKey:@"double_field"]);
        TEST([[a d_valueForKey:@"double_field"] isEqual:@MAXFLOAT]);
        TEST([[a d_valueForKeyPath:@"double_field"] isEqual:@MAXFLOAT]);
        
        TEST_AFTER_EXECUTE(a.double_field == 13.0, [a d_setValue:@13.0 forKeyPath:@"double_field"]);
        TEST([[a d_valueForKey:@"double_field"] isEqual:@13.0]);
        TEST([[a d_valueForKeyPath:@"double_field"] isEqual:@13.0]);
        
        NEW_LINE
#if TARGET_OS_OSX
        //NSPoint 类型
        TEST_AFTER_EXECUTE(a.NSPoint_field.x == 10 && a.NSPoint_field.y == 20, [a d_setValue:[NSValue valueWithPoint:NSMakePoint(10, 20)] forKey:@"NSPoint_field"]);
        TEST([[a d_valueForKey:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(10, 20)]]);
        TEST([[a d_valueForKeyPath:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(10, 20)]]);
        
        TEST_AFTER_EXECUTE(a.NSPoint_field.x == 100 && a.NSPoint_field.y == 200, [a d_setValue:[NSValue valueWithPoint:NSMakePoint(100, 200)] forKey:@"NSPoint_field"]);
        TEST([[a d_valueForKey:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(100, 200)]]);
        TEST([[a d_valueForKeyPath:@"NSPoint_field"] isEqual:[NSValue valueWithPoint:NSMakePoint(100, 200)]]);

        NEW_LINE
#endif
        //NSRange 类型
        TEST_AFTER_EXECUTE(a.NSRange_field.location == 10 && a.NSRange_field.length == 20, [a d_setValue:[NSValue valueWithRange:NSMakeRange(10, 20)] forKey:@"NSRange_field"]);
        TEST([[a d_valueForKey:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(10, 20)]]);
        TEST([[a d_valueForKeyPath:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(10, 20)]]);
        
        TEST_AFTER_EXECUTE(a.NSRange_field.location == 100 && a.NSRange_field.length == 200, [a d_setValue:[NSValue valueWithRange:NSMakeRange(100, 200)] forKey:@"NSRange_field"]);
        TEST([[a d_valueForKey:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(100, 200)]]);
        TEST([[a d_valueForKeyPath:@"NSRange_field"] isEqual:[NSValue valueWithRange:NSMakeRange(100, 200)]]);
        
        NEW_LINE
#if TARGET_OS_OSX
        //NSRect 类型
        TEST_AFTER_EXECUTE(a.NSRect_field.origin.x == 10 && a.NSRect_field.origin.y == 20 && a.NSRect_field.size.width == 30 && a.NSRect_field.size.height == 40, [a d_setValue:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)] forKey:@"NSRect_field"]);
        TEST([[a d_valueForKey:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)]]);
        TEST([[a d_valueForKeyPath:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)]]);
        
        TEST_AFTER_EXECUTE(a.NSRect_field.origin.x == 100 && a.NSRect_field.origin.y == 200 && a.NSRect_field.size.width == 300 && a.NSRect_field.size.height == 400, [a d_setValue:[NSValue valueWithRect:NSMakeRect(100, 200, 300, 400)] forKeyPath:@"NSRect_field"]);
        TEST([[a d_valueForKey:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(100, 200, 300, 400)]]);
        TEST([[a d_valueForKeyPath:@"NSRect_field"] isEqual:[NSValue valueWithRect:NSMakeRect(100, 200, 300, 400)]]);
        
        NEW_LINE
#endif

#if TARGET_OS_IPHONE
        //CGPoint 类型
        TEST_AFTER_EXECUTE(a.CGPoint_field.x == 10 && a.CGPoint_field.y == 20, [a d_setValue:[NSValue valueWithCGPoint:CGPointMake(10, 20)] forKey:@"CGPoint_field"]);
        TEST([[a d_valueForKey:@"CGPoint_field"] isEqual:[NSValue valueWithCGPoint:CGPointMake(10, 20)]]);
        TEST([[a d_valueForKeyPath:@"CGPoint_field"] isEqual:[NSValue valueWithCGPoint:CGPointMake(10, 20)]]);
        
        TEST_AFTER_EXECUTE(a.CGPoint_field.x == 100 && a.CGPoint_field.y == 200, [a d_setValue:[NSValue valueWithCGPoint:CGPointMake(100, 200)] forKey:@"CGPoint_field"]);
        TEST([[a d_valueForKey:@"CGPoint_field"] isEqual:[NSValue valueWithCGPoint:CGPointMake(100, 200)]]);
        TEST([[a d_valueForKeyPath:@"CGPoint_field"] isEqual:[NSValue valueWithCGPoint:CGPointMake(100, 200)]]);
        
        NEW_LINE
        //CGRect 类型
        TEST_AFTER_EXECUTE(a.CGRect_field.origin.x == 10 && a.CGRect_field.origin.y == 20 && a.CGRect_field.size.width == 30 && a.CGRect_field.size.height == 40, [a d_setValue:[NSValue valueWithCGRect:CGRectMake(10, 20, 30, 40)] forKey:@"CGRect_field"]);
        TEST([[a d_valueForKey:@"CGRect_field"] isEqual:[NSValue valueWithCGRect:CGRectMake(10, 20, 30, 40)]]);
        TEST([[a d_valueForKeyPath:@"CGRect_field"] isEqual:[NSValue valueWithCGRect:CGRectMake(10, 20, 30, 40)]]);
        
        TEST_AFTER_EXECUTE(a.CGRect_field.origin.x == 100 && a.CGRect_field.origin.y == 200 && a.CGRect_field.size.width == 300 && a.CGRect_field.size.height == 400, [a d_setValue:[NSValue valueWithCGRect:CGRectMake(100, 200, 300, 400)] forKeyPath:@"CGRect_field"]);
        TEST([[a d_valueForKey:@"CGRect_field"] isEqual:[NSValue valueWithCGRect:CGRectMake(100, 200, 300, 400)]]);
        TEST([[a d_valueForKeyPath:@"CGRect_field"] isEqual:[NSValue valueWithCGRect:CGRectMake(100, 200, 300, 400)]]);
        NEW_LINE
#else
        //CGPoint 类型
        TEST_AFTER_EXECUTE(a.CGPoint_field.x == 10 && a.CGPoint_field.y == 20, [a d_setValue:[NSValue valueWithPoint:CGPointMake(10, 20)] forKey:@"CGPoint_field"]);
        TEST([[a d_valueForKey:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(10, 20)]]);
        TEST([[a d_valueForKeyPath:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(10, 20)]]);
        
        TEST_AFTER_EXECUTE(a.CGPoint_field.x == 100 && a.CGPoint_field.y == 200, [a d_setValue:[NSValue valueWithPoint:CGPointMake(100, 200)] forKey:@"CGPoint_field"]);
        TEST([[a d_valueForKey:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(100, 200)]]);
        TEST([[a d_valueForKeyPath:@"CGPoint_field"] isEqual:[NSValue valueWithPoint:CGPointMake(100, 200)]]);
        
        NEW_LINE
        //CGRect 类型
        TEST_AFTER_EXECUTE(a.CGRect_field.origin.x == 10 && a.CGRect_field.origin.y == 20 && a.CGRect_field.size.width == 30 && a.CGRect_field.size.height == 40, [a d_setValue:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)] forKey:@"CGRect_field"]);
        TEST([[a d_valueForKey:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)]]);
        TEST([[a d_valueForKeyPath:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)]]);
        
        TEST_AFTER_EXECUTE(a.CGRect_field.origin.x == 100 && a.CGRect_field.origin.y == 200 && a.CGRect_field.size.width == 300 && a.CGRect_field.size.height == 400, [a d_setValue:[NSValue valueWithRect:CGRectMake(100, 200, 300, 400)] forKeyPath:@"CGRect_field"]);
        TEST([[a d_valueForKey:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(100, 200, 300, 400)]]);
        TEST([[a d_valueForKeyPath:@"CGRect_field"] isEqual:[NSValue valueWithRect:CGRectMake(100, 200, 300, 400)]]);
        NEW_LINE
#endif
        //对象类型
        A *A_field = [A random];
        TEST_AFTER_EXECUTE(a.A_field == A_field, [a d_setValue:A_field forKey:@"A_field"]);
        TEST([[a d_valueForKey:@"A_field"] isEqual:A_field]);
        TEST([[a d_valueForKeyPath:@"A_field"] isEqual:A_field]);
        
        A_field = [A random];
        TEST_AFTER_EXECUTE(a.A_field == A_field, [a d_setValue:A_field forKeyPath:@"A_field"]);
        TEST([[a d_valueForKey:@"A_field"] isEqual:A_field]);
        TEST([[a d_valueForKeyPath:@"A_field"] isEqual:A_field]);
        
        
        NEW_LINE
        NSArray<A *> *NSArray_field = @[[A random], [A random], [A random], [A random], [A random], [A random]];
        TEST_AFTER_EXECUTE(a.NSArray_field == NSArray_field, [a d_setValue:NSArray_field forKey:@"NSArray_field"]);
        TEST([[a d_valueForKey:@"NSArray_field"] isEqualToArray:NSArray_field]);
        TEST([[a d_valueForKeyPath:@"NSArray_field"] isEqualToArray:NSArray_field]);
        
        NSArray_field = @[[A random], [A random], [A random], [A random], [A random], [A random]];
        TEST_AFTER_EXECUTE(a.NSArray_field == NSArray_field, [a d_setValue:NSArray_field forKeyPath:@"NSArray_field"]);
        TEST([[a d_valueForKey:@"NSArray_field"] isEqualToArray:NSArray_field]);
        TEST([[a d_valueForKeyPath:@"NSArray_field"] isEqualToArray:NSArray_field]);
        
        
        NEW_LINE
        NSSet<A *> *NSSet_field = [NSSet setWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_AFTER_EXECUTE(a.NSSet_field == NSSet_field, [a d_setValue:NSSet_field forKey:@"NSSet_field"]);
        TEST([[a d_valueForKey:@"NSSet_field"] isEqualToSet:NSSet_field]);
        TEST([[a d_valueForKeyPath:@"NSSet_field"] isEqualToSet:NSSet_field]);
        
        NSSet_field = [NSSet setWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_AFTER_EXECUTE(a.NSSet_field == NSSet_field, [a d_setValue:NSSet_field forKeyPath:@"NSSet_field"]);
        TEST([[a d_valueForKey:@"NSSet_field"] isEqualToSet:NSSet_field]);
        TEST([[a d_valueForKeyPath:@"NSSet_field"] isEqualToSet:NSSet_field]);
        
        
        NEW_LINE
        NSOrderedSet<A *> *NSOrderedSet_field = [NSOrderedSet orderedSetWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_AFTER_EXECUTE(a.NSOrderedSet_field == NSOrderedSet_field, [a d_setValue:NSOrderedSet_field forKey:@"NSOrderedSet_field"]);
        TEST([[a d_valueForKey:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        TEST([[a d_valueForKeyPath:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        
        NSOrderedSet_field = [NSOrderedSet orderedSetWithArray:@[[A random], [A random], [A random], [A random], [A random], [A random]]];
        TEST_AFTER_EXECUTE(a.NSOrderedSet_field == NSOrderedSet_field, [a d_setValue:NSOrderedSet_field forKeyPath:@"NSOrderedSet_field"]);
        TEST([[a d_valueForKey:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        TEST([[a d_valueForKeyPath:@"NSOrderedSet_field"] isEqual:NSOrderedSet_field]);
        
        NEW_LINE
        
        //======================多级的keyPath======================

        TEST_AFTER_EXECUTE(a.A_field.unsigned_long_field == ULONG_MAX, [a d_setValue:@ULONG_MAX forKeyPath:@"A_field.unsigned_long_field"]);
        TEST([[a d_valueForKeyPath:@"A_field.unsigned_long_field"] isEqual:@ULONG_MAX]);
        NEW_LINE
        a.A_field.A_field = [A random];

        TEST_AFTER_EXECUTE(a.A_field.A_field.unsigned_long_field == ULONG_MAX, [a d_setValue:@ULONG_MAX forKeyPath:@"A_field.A_field.unsigned_long_field"]);
        TEST([[a d_valueForKeyPath:@"A_field.A_field.unsigned_long_field"] isEqual:@ULONG_MAX]);
        
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
                TEST([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            catchException = nil;
            @try {
                [a d_setValue:@1 forKey:@"xxx"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST([catchException.name isEqualToString:NSUnknownKeyException])
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
                TEST([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            catchException = nil;
            @try {
                [a d_setValue:@1 forKeyPath:@"xxx.yyy.zzz"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST([catchException.name isEqualToString:NSUnknownKeyException])
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
                TEST([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            TEST([[a.A_field d_valueForKey:@"char_field"] isEqual: @(a.A_field.char_field)]);
            
            catchException = nil;
            @try {
                [a d_setValue:@(10) forKey:@"A_field.char_field"];
            } @catch (NSException *exception) {
                catchException = exception;
            } @finally {
                TEST([catchException.name isEqualToString:NSUnknownKeyException])
            }
            
            TEST_AFTER_EXECUTE(a.A_field.char_field == 10, [a.A_field d_setValue:@(10) forKey:@"char_field"];);
        }
        //以keyPath去调用d_valueForKeyPath:与调用d_valueForKey:相同
        {
            TEST_AFTER_EXECUTE(a.A_field.char_field == 10, [a d_setValue:@(10) forKeyPath:@"A_field.char_field"];);
            TEST_AFTER_EXECUTE(a.A_field.char_field == 10, [a.A_field d_setValue:@(10) forKeyPath:@"char_field"];);
            
            TEST([@(a.A_field.char_field) isEqual: [a d_valueForKeyPath:@"A_field.char_field"]]);
            TEST([@(a.A_field.char_field) isEqual: [a.A_field d_valueForKeyPath:@"char_field"]]);
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
        TEST([char_field_Array isEqualToArray:[array valueForKeyPath:@"char_field"]]);
        
        //每个对象的char_field都被设置为11
        [array setValue:@11 forKeyPath:@"char_field"];
        BOOL allSet_to_11 = YES;
        for (A *a in array) {
            if (a.char_field != 11) {
                allSet_to_11 = NO;
                break;
            }
        }
        TEST(allSet_to_11);
        
        //测试集合运算符
        //NSArray支持:@count,@sum,@avg,@max,@min,@unionOfObjects,@distinctUnionOfObjects,@unionOfArrays,@distinctUnionOfArrays,@unionOfSets,@distinctUnionOfSets
        id result = [array d_valueForKeyPath:@"@count"];
        TEST([result isEqual:[array valueForKeyPath:@"@count"]]);
        
        result = [array d_valueForKeyPath:@"@sum.float_field"];
        TEST([result isEqual:[array valueForKeyPath:@"@sum.float_field"]]);
        
        result = [array d_valueForKeyPath:@"@avg.float_field"];
        TEST([result isEqual:[array valueForKeyPath:@"@avg.float_field"]]);
        
        result = [array d_valueForKeyPath:@"@max.float_field"];
        TEST([result isEqual:[array valueForKeyPath:@"@max.float_field"]]);
        
        result = [array d_valueForKeyPath:@"@min.float_field"];
        TEST([result isEqual:[array valueForKeyPath:@"@min.float_field"]]);
        
        //每个对象identifier字段组成的数组
        result = [array d_valueForKeyPath:@"@unionOfObjects.identifier"];
        TEST([result isEqualToArray:[array valueForKeyPath:@"@unionOfObjects.identifier"]]);
        
        //每个对象identifier字段组成的数组 & 去重复
        result = [array d_valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
        TEST([result isEqualToArray:[array valueForKeyPath:@"@distinctUnionOfObjects.identifier"]]);
        
        
        //每个对象的NSArray_field字段的各个对象组成的数组
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,1,3,4,3,6,7,8,8]
        result = [array d_valueForKeyPath:@"@unionOfArrays.NSArray_field"];
        TEST([result isEqualToArray:[array valueForKeyPath:@"@unionOfArrays.NSArray_field"]]);
        
        //每个对象的NSArray_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8,9]
        result = [array d_valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"];
        TEST([result isEqualToArray:[array valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"]]);
        
        
        //每个对象的NSSet_field字段的各个对象组成的数组
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,3,6,7,8]
        result = [array d_valueForKeyPath:@"@unionOfSets.NSSet_field"];
        TEST([result isEqualToArray:[array valueForKeyPath:@"@unionOfSets.NSSet_field"]]);
        
        //每个对象的NSSet_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8]
        result = [array d_valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"];
        TEST([result isEqualToArray:[array valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"]]);
        
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
        TEST([char_field_Set isEqualToSet:[set valueForKeyPath:@"char_field"]]);
        
        //每个对象的char_field都被设置为11
        [set setValue:@11 forKeyPath:@"char_field"];
        BOOL allSet_to_11 = YES;
        for (A *a in set) {
            if (a.char_field != 11) {
                allSet_to_11 = NO;
                break;
            }
        }
        TEST(allSet_to_11);
        
        //测试集合运算符
        //NSSet支持:@count,@sum,@avg,@max,@min,@distinctUnionOfObjects,@distinctUnionOfArrays,@distinctUnionOfSets
        id result = [set d_valueForKeyPath:@"@count"];
        TEST([result isEqual:[set valueForKeyPath:@"@count"]]);
        
        result = [set d_valueForKeyPath:@"@sum.float_field"];
        TEST([result isEqual:[set valueForKeyPath:@"@sum.float_field"]]);
        
        result = [set d_valueForKeyPath:@"@avg.float_field"];
        TEST([result isEqual:[set valueForKeyPath:@"@avg.float_field"]]);
        
        result = [set d_valueForKeyPath:@"@max.float_field"];
        TEST([result isEqual:[set valueForKeyPath:@"@max.float_field"]]);
        
        result = [set d_valueForKeyPath:@"@min.float_field"];
        TEST([result isEqual:[set valueForKeyPath:@"@min.float_field"]]);
        
        //每个对象identifier字段组成的数组 & 去重复
        result = [set d_valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
        TEST([result isEqual:[set valueForKeyPath:@"@distinctUnionOfObjects.identifier"]]);
        
        //每个对象的NSArray_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8,9]
        result = [set d_valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"];
        TEST([result isEqual:[set valueForKeyPath:@"@distinctUnionOfArrays.NSArray_field"]]);

        //每个对象的NSSet_field字段的各个对象组成的数组 & 去重复
        //eg. [1,1,3][4,3,6][7,8,8] ==> [1,3,4,6,7,8]
        result = [set d_valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"];
        TEST([result isEqual:[set valueForKeyPath:@"@distinctUnionOfSets.NSSet_field"]]);
        
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
        TEST([char_field_OrderedSet isEqualToOrderedSet:[orderSet valueForKeyPath:@"char_field"]]);
        
        //每个对象的char_field都被设置为11
        [orderSet setValue:@11 forKeyPath:@"char_field"];
        BOOL allSet_to_11 = YES;
        for (A *a in orderSet) {
            if (a.char_field != 11) {
                allSet_to_11 = NO;
                break;
            }
        }
        TEST(allSet_to_11);
        
        //测试集合运算符
        //NSOrderedSet支持:@count,@sum,@avg,@max,@min
        id result = [orderSet d_valueForKeyPath:@"@count"];
        TEST([result isEqual:[orderSet valueForKeyPath:@"@count"]]);
        
        result = [orderSet d_valueForKeyPath:@"@sum.float_field"];
        TEST([result isEqual:[orderSet valueForKeyPath:@"@sum.float_field"]]);
        
        result = [orderSet d_valueForKeyPath:@"@avg.float_field"];
        TEST([result isEqual:[orderSet valueForKeyPath:@"@avg.float_field"]]);
        
        result = [orderSet d_valueForKeyPath:@"@max.float_field"];
        TEST([result isEqual:[orderSet valueForKeyPath:@"@max.float_field"]]);
        
        result = [orderSet d_valueForKeyPath:@"@min.float_field"];
        TEST([result isEqual:[orderSet valueForKeyPath:@"@min.float_field"]]);
        
        
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
        TEST([result isEqual: [dict valueForKey:@"key1"]])
        
        result = [dict d_valueForKey:@"key2"];
        TEST([result isEqual: [dict valueForKey:@"key2"]])
        
        result = [dict d_valueForKey:@"key3"];
        TEST([result isEqual: [dict valueForKey:@"key3"]])
        
        result = [dict d_valueForKeyPath:@"key4.key5.key6"];
        TEST([result isEqual: [dict d_valueForKeyPath:@"key4.key5.key6"]])
        
        result = [dict d_valueForKeyPath:@"key4.key7"];
        TEST([result isEqual: [dict d_valueForKeyPath:@"key4.key7"]])

        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
        [mutDict d_setValue:@"v1" forKey:@"key1"];
        TEST([mutDict[@"key1"] isEqual: @"v1"]);
        [mutDict d_setValue:[NSMutableDictionary dictionary] forKey:@"key2"];
        [mutDict d_setValue:@"v3" forKeyPath:@"key2.key3"];
        TEST([mutDict[@"key2"][@"key3"] isEqual: @"v3"]);
        [mutDict d_setValue:nil forKeyPath:@"key2.key3"];
        TEST(mutDict[@"key2"][@"key3"] == nil);
        SEP_LINE
    }
    
    {
        SEP_LINE
        //=========================测试NSUserDefaults=========================
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults d_setValue:@"v1" forKey:@"key1"];
        TEST([[defaults d_valueForKey:@"key1"] isEqual: [defaults valueForKey:@"key1"]]);
        [defaults d_setValue:nil forKey:@"key1"];
        TEST([defaults d_valueForKey:@"key1"] == nil);
        SEP_LINE
    }
    
    
    {
#if NSARRAY_MUTE_BY_CONTAINER
        {
            SEP_LINE
            
            A *a = A.random;
            A *b = A.random;
            
            
            NSMutableArray *mutArray_a = [a d_mutableArrayValueForKey:@"NSArray_field"];
            NSMutableArray *mutArray_b = [b mutableArrayValueForKey:@"NSArray_field"];
            
            TEST((mutArray_a.class == NSClassFromString(@"DSKeyValueFastMutableArray2")) && (mutArray_b.class == NSClassFromString(@"NSKeyValueFastMutableArray2")));
            
            a.NSArray_field = @[];
            b.NSArray_field = @[];
            
            {
                NSException *catchException = nil;
                @try {
                    [mutArray_a addObject:NextRandomA_1];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
                
                catchException = nil;
                @try {
                    [mutArray_b addObject:NextRandomA_2];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
            }
            
            a.NSArray_field = [NSMutableArray array];
            b.NSArray_field = [NSMutableArray array];
            
            [mutArray_a addObject:NextRandomA_1];
            [mutArray_b addObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObject:NextRandomA_1 atIndex:0];
            [mutArray_b insertObject:NextRandomA_2 atIndex:0];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObject:NextRandomA_1 atIndex:2];
            [mutArray_b insertObject:NextRandomA_2 atIndex:2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 9)]];
            [mutArray_b insertObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 9)]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectAtIndex:0];
            [mutArray_b removeObjectAtIndex:0];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectAtIndex:mutArray_a.count - 1];
            [mutArray_b removeObjectAtIndex:mutArray_b.count - 1];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
            [mutArray_b removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeLastObject];
            [mutArray_b removeLastObject];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:0 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:0 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:mutArray_a.count - 1 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:mutArray_b.count - 1 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:3 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:3 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)] withObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutArray_b replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)] withObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            SEP_LINE
        }
#else
        {
            SEP_LINE
            
            A *a = A.random;
            A *b = A.random;
            
            //以属性名获取代理Array
            NSMutableArray *mutArray_a = [a d_mutableArrayValueForKey:@"NSArray_field"];
            NSMutableArray *mutArray_b = [b mutableArrayValueForKey:@"NSArray_field"];
            
            TEST((mutArray_a.class == NSClassFromString(@"DSKeyValueSlowMutableArray")) && (mutArray_b.class == NSClassFromString(@"NSKeyValueSlowMutableArray")))
            
            {
                //NSArray_field为nil，代理Array找不到原Array，应当报异常
                
                NSException *catchException = nil;
                @try {
                    [mutArray_a addObject:NextRandomA_1];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInternalInconsistencyException])
                }
                
                catchException = nil;
                @try {
                    [mutArray_b addObject:NextRandomA_2];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInternalInconsistencyException])
                }
            }
            
            a.NSArray_field = @[];
            b.NSArray_field = @[];
            
            [mutArray_a addObject:NextRandomA_1];
            [mutArray_b addObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            //在代理Array的操作下, NSArray_field 由原来的NSArray对象变为 NSMutableArray对象
            TEST([a.NSArray_field isKindOfClass:NSMutableArray.self] && [b.NSArray_field isKindOfClass:NSMutableArray.self])
            
            [mutArray_a insertObject:NextRandomA_1 atIndex:0];
            [mutArray_b insertObject:NextRandomA_2 atIndex:0];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObject:NextRandomA_1 atIndex:2];
            [mutArray_b insertObject:NextRandomA_2 atIndex:2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 9)]];
            [mutArray_b insertObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 9)]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectAtIndex:0];
            [mutArray_b removeObjectAtIndex:0];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectAtIndex:mutArray_a.count - 1];
            [mutArray_b removeObjectAtIndex:mutArray_b.count - 1];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
            [mutArray_b removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeLastObject];
            [mutArray_b removeLastObject];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:0 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:0 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:mutArray_a.count - 1 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:mutArray_b.count - 1 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:3 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:3 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)] withObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutArray_b replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)] withObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            SEP_LINE
        }
        
        
#endif
        
        {
            SEP_LINE
            
            A *a = A.random;
            A *b = A.random;
            
            a.NSArray_field = @[];
            b.NSArray_field = @[];
            
            //以实例变量名获取代理Array
            NSMutableArray *mutArray_a = [a d_mutableArrayValueForKey:@"_NSArray_field"];
            NSMutableArray *mutArray_b = [b mutableArrayValueForKey:@"_NSArray_field"];
            
            TEST((mutArray_a.class == NSClassFromString(@"DSKeyValueIvarMutableArray")) && (mutArray_b.class == NSClassFromString(@"NSKeyValueIvarMutableArray")))
            
            {
                //代理Array不会把NSArray替换为NSMutableArray,因此报NSInvalidArgumentException异常
                NSException *catchException = nil;
                @try {
                    [mutArray_a addObject:NextRandomA_1];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
                
                catchException = nil;
                @try {
                    [mutArray_b addObject:NextRandomA_2];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
            }
            
            a.NSArray_field = nil;
            b.NSArray_field = nil;
            mutArray_a = [a d_mutableArrayValueForKey:@"_NSArray_field"];
            mutArray_b = [b mutableArrayValueForKey:@"_NSArray_field"];
            
            [mutArray_a addObject:NextRandomA_1];
            [mutArray_b addObject:NextRandomA_2];
            
            //如果原Array为nil，代理Array会创建NSMUtableArray替换原Array
            TEST([a.NSArray_field isKindOfClass:NSMutableArray.self] && [b.NSArray_field isKindOfClass:NSMutableArray.self])
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            a.NSArray_field = [NSMutableArray array];
            b.NSArray_field = [NSMutableArray array];
            
            mutArray_a = [a d_mutableArrayValueForKey:@"_NSArray_field"];
            mutArray_b = [b mutableArrayValueForKey:@"_NSArray_field"];
            
            [mutArray_a addObject:NextRandomA_1];
            [mutArray_b addObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObject:NextRandomA_1 atIndex:0];
            [mutArray_b insertObject:NextRandomA_2 atIndex:0];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObject:NextRandomA_1 atIndex:2];
            [mutArray_b insertObject:NextRandomA_2 atIndex:2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a insertObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 9)]];
            [mutArray_b insertObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 9)]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectAtIndex:0];
            [mutArray_b removeObjectAtIndex:0];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectAtIndex:mutArray_a.count - 1];
            [mutArray_b removeObjectAtIndex:mutArray_b.count - 1];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
            [mutArray_b removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a removeLastObject];
            [mutArray_b removeLastObject];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:0 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:0 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:mutArray_a.count - 1 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:mutArray_b.count - 1 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectAtIndex:3 withObject:NextRandomA_1];
            [mutArray_b replaceObjectAtIndex:3 withObject:NextRandomA_2];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            [mutArray_a replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)] withObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutArray_b replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)] withObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutArray_a isEqualToArray:mutArray_b] && [a.NSArray_field isEqualToArray:b.NSArray_field]);
            
            SEP_LINE
        }
        
    }
    
    
    
    {
#if NSSET_MUTE_BY_CONTAINER
        {
            SEP_LINE
            A *a = A.random;
            A *b = A.random;
            NSMutableSet *mutSet_a = [a d_mutableSetValueForKey:@"NSSet_field"];
            NSMutableSet *mutSet_b = [b mutableSetValueForKey:@"NSSet_field"];
            
            TEST(mutSet_a.class == NSClassFromString(@"DSKeyValueFastMutableSet2") && mutSet_b.class == NSClassFromString(@"NSKeyValueFastMutableSet2"))
            
            a.NSSet_field = [NSSet set];
            b.NSSet_field = [NSSet set];
            
            {
                //NSSet_field为不可变，修改应当报异常
                NSException *catchException = nil;
                @try {
                    [mutSet_a addObject:NextRandomA_1];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
                
                catchException = nil;
                @try {
                    [mutSet_b addObject:NextRandomA_2];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
            }
            
            a.NSSet_field = [NSMutableSet set];
            b.NSSet_field = [NSMutableSet set];
            
            [mutSet_a addObject:NextRandomA_1];
            [mutSet_b addObject:NextRandomA_2];
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            [mutSet_a addObjectsFromArray:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutSet_b addObjectsFromArray:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            TEST(mutSet_a.count == mutSet_b.count);
            
            {
                id finder_a = NextRandomA_1;
                id finder_b = NextRandomA_2;
                
                [mutSet_a addObject:finder_a];
                [mutSet_b addObject:finder_b];
                
                TEST([[mutSet_a member:finder_a] isEqual: [mutSet_b member:finder_b]]);
            }
            
            {
                NSEnumerator *enumerator_a = mutSet_a.objectEnumerator;
                NSEnumerator *enumerator_b = mutSet_b.objectEnumerator;
                
                TEST([enumerator_a.allObjects isEqualToArray:enumerator_b.allObjects]);
            }
            
            {
                id remove_a = NextRandomA_1;
                id remove_b = NextRandomA_2;
                
                [mutSet_a addObject:remove_a];
                [mutSet_b addObject:remove_b];
                
                TEST([mutSet_a member:remove_a] == remove_a && [mutSet_b member:remove_b] == remove_b);
                
                NSUInteger c = mutSet_a.count;
                assert(c == mutSet_b.count);
                
                [mutSet_a removeObject:remove_a];
                [mutSet_b removeObject:remove_b];
                
                assert(mutSet_b.count == mutSet_a.count && mutSet_a.count == c - 1);
                
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                TEST([mutSet_a member:remove_a] == nil && [mutSet_b member:remove_b] == nil);
            }
            
            [mutSet_a removeAllObjects];
            [mutSet_b removeAllObjects];
            TEST(mutSet_a.count == 0 && mutSet_b.count == 0);
            
            [mutSet_a setSet:[NSMutableSet setWithArray:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]]];
            [mutSet_b setSet:[NSMutableSet setWithArray:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]]];
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            {
                NSSet *set = [NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"007"]]];
                
                [mutSet_a setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                //设置 mutSet_a 为 mutSet_a 与 set的交集
                [mutSet_a intersectSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的交集
                [mutSet_b intersectSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                [mutSet_a setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                
                //设置 mutSet_a 为 mutSet_a 与 set的差集
                [mutSet_a minusSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的差集
                [mutSet_b minusSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                [mutSet_a setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                
                //设置 mutSet_a 为 mutSet_a 与 set的并集
                [mutSet_a unionSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的并集
                [mutSet_b unionSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
            }
            
            SEP_LINE
        }
#else
        {
            SEP_LINE
            A *a = A.random;
            A *b = A.random;
            NSMutableSet *mutSet_a = [a d_mutableSetValueForKey:@"NSSet_field"];
            NSMutableSet *mutSet_b = [b mutableSetValueForKey:@"NSSet_field"];
            
            TEST(mutSet_a.class == NSClassFromString(@"DSKeyValueSlowMutableSet") && mutSet_b.class == NSClassFromString(@"NSKeyValueSlowMutableSet"))
            
            {
                //NSSet_field为nil，代理Array找不到原Array，应当报异常
                
                NSException *catchException = nil;
                @try {
                    [mutSet_a addObject:NextRandomA_1];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInternalInconsistencyException])
                }
                
                catchException = nil;
                @try {
                    [mutSet_b addObject:NextRandomA_2];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInternalInconsistencyException])
                }
            }
            
            a.NSSet_field = [NSSet set];
            b.NSSet_field = [NSSet set];
            
            [mutSet_a addObject:NextRandomA_1];
            [mutSet_b addObject:NextRandomA_2];
            //代理将NSSet_field 由NSSet 变更为 NSMutableSet
            TEST([a.NSSet_field isKindOfClass:NSMutableSet.self] && [b.NSSet_field isKindOfClass:NSMutableSet.self]);
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            [mutSet_a addObjectsFromArray:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutSet_b addObjectsFromArray:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            TEST(mutSet_a.count == mutSet_b.count);
            
            {
                id finder_a = NextRandomA_1;
                id finder_b = NextRandomA_2;
                
                [mutSet_a addObject:finder_a];
                [mutSet_b addObject:finder_b];
                
                TEST([[mutSet_a member:finder_a] isEqual: [mutSet_b member:finder_b]]);
            }
            
            {
                NSEnumerator *enumerator_a = mutSet_a.objectEnumerator;
                NSEnumerator *enumerator_b = mutSet_b.objectEnumerator;
                
                TEST([enumerator_a.allObjects isEqualToArray:enumerator_b.allObjects]);
            }
            
            {
                id remove_a = NextRandomA_1;
                id remove_b = NextRandomA_2;
                
                [mutSet_a addObject:remove_a];
                [mutSet_b addObject:remove_b];
                
                TEST([mutSet_a member:remove_a] == remove_a && [mutSet_b member:remove_b] == remove_b);
                
                NSUInteger c = mutSet_a.count;
                assert(c == mutSet_b.count);
                
                [mutSet_a removeObject:remove_a];
                [mutSet_b removeObject:remove_b];
                
                assert(mutSet_b.count == mutSet_a.count && mutSet_a.count == c - 1);
                
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                TEST([mutSet_a member:remove_a] == nil && [mutSet_b member:remove_b] == nil);
            }
            
            [mutSet_a removeAllObjects];
            [mutSet_b removeAllObjects];
            TEST(mutSet_a.count == 0 && mutSet_b.count == 0);
            
            [mutSet_a setSet:[NSSet setWithArray:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]]];
            [mutSet_b setSet:[NSSet setWithArray:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]]];
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            {
                NSSet *set = [NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"007"]]];
                
                [mutSet_a setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                //设置 mutSet_a 为 mutSet_a 与 set的交集
                [mutSet_a intersectSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的交集
                [mutSet_b intersectSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                [mutSet_a setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                
                //设置 mutSet_a 为 mutSet_a 与 set的差集
                [mutSet_a minusSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的差集
                [mutSet_b minusSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                [mutSet_a setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                
                //设置 mutSet_a 为 mutSet_a 与 set的并集
                [mutSet_a unionSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的并集
                [mutSet_b unionSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
            }
            
            SEP_LINE
        }
        
#endif
        {
            SEP_LINE
            A *a = A.random;
            A *b = A.random;
            NSMutableSet *mutSet_a = [a d_mutableSetValueForKey:@"_NSSet_field"];
            NSMutableSet *mutSet_b = [b mutableSetValueForKey:@"_NSSet_field"];
            
            TEST(mutSet_a.class == NSClassFromString(@"DSKeyValueIvarMutableSet") && mutSet_b.class == NSClassFromString(@"NSKeyValueIvarMutableSet"))
            
            a.NSSet_field = [NSSet set];
            b.NSSet_field = [NSSet set];
            
            {
                //NSSet_field为不可变类型，修改报异常
                
                NSException *catchException = nil;
                @try {
                    [mutSet_a addObject:NextRandomA_1];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
                
                catchException = nil;
                @try {
                    [mutSet_b addObject:NextRandomA_2];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
            }
            
            
            a.NSSet_field = nil;
            b.NSSet_field = nil;
            
            [mutSet_a addObject:NextRandomA_1];
            [mutSet_b addObject:NextRandomA_2];
            //代理会主动为NSSet_field创建NSMutableSet
            TEST([a.NSSet_field isKindOfClass:NSMutableSet.self] && [a.NSSet_field  isEqualToSet:b.NSSet_field]);
            
            [mutSet_a addObject:NextRandomA_1];
            [mutSet_b addObject:NextRandomA_2];
            //代理将NSSet_field 由NSSet 变更为 NSMutableSet
            TEST([a.NSSet_field isKindOfClass:NSMutableSet.self] && [b.NSSet_field isKindOfClass:NSMutableSet.self]);
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            [mutSet_a addObjectsFromArray:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutSet_b addObjectsFromArray:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            TEST(mutSet_a.count == mutSet_b.count);
            
            {
                id finder_a = NextRandomA_1;
                id finder_b = NextRandomA_2;
                
                [mutSet_a addObject:finder_a];
                [mutSet_b addObject:finder_b];
                
                TEST([[mutSet_a member:finder_a] isEqual: [mutSet_b member:finder_b]]);
            }
            
            {
                NSEnumerator *enumerator_a = mutSet_a.objectEnumerator;
                NSEnumerator *enumerator_b = mutSet_b.objectEnumerator;
                
                TEST([enumerator_a.allObjects isEqualToArray:enumerator_b.allObjects]);
            }
            
            {
                id remove_a = NextRandomA_1;
                id remove_b = NextRandomA_2;
                
                [mutSet_a addObject:remove_a];
                [mutSet_b addObject:remove_b];
                
                TEST([mutSet_a member:remove_a] == remove_a && [mutSet_b member:remove_b] == remove_b);
                
                NSUInteger c = mutSet_a.count;
                assert(c == mutSet_b.count);
                
                [mutSet_a removeObject:remove_a];
                [mutSet_b removeObject:remove_b];
                
                assert(mutSet_b.count == mutSet_a.count && mutSet_a.count == c - 1);
                
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                TEST([mutSet_a member:remove_a] == nil && [mutSet_b member:remove_b] == nil);
            }
            
            [mutSet_a removeAllObjects];
            [mutSet_b removeAllObjects];
            TEST(mutSet_a.count == 0 && mutSet_b.count == 0);
            
            [mutSet_a setSet:[NSSet setWithArray:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]]];
            [mutSet_b setSet:[NSSet setWithArray:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]]];
            TEST([mutSet_a isEqualToSet:mutSet_b]);
            
            {
                NSSet *set = [NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"007"]]];
                
                [mutSet_a setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                //设置 mutSet_a 为 mutSet_a 与 set的交集
                [mutSet_a intersectSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的交集
                [mutSet_b intersectSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                [mutSet_a setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                
                //设置 mutSet_a 为 mutSet_a 与 set的差集
                [mutSet_a minusSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的差集
                [mutSet_b minusSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
                [mutSet_a setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                [mutSet_b setSet:[NSSet setWithArray:@[[A randomWithIdentifier:@"001"],[A randomWithIdentifier:@"002"],[A randomWithIdentifier:@"003"],[A randomWithIdentifier:@"004"],[A randomWithIdentifier:@"006"],[A randomWithIdentifier:@"008"],[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"]]]];
                
                
                //设置 mutSet_a 为 mutSet_a 与 set的并集
                [mutSet_a unionSet:set];
                //设置 mutSet_a 为 mutSet_a 与 set的并集
                [mutSet_b unionSet:set];
                //操作结果相等
                TEST([mutSet_a isEqualToSet:mutSet_b]);
                
            }
            
            SEP_LINE
        }
    }
    
    
    {
#if NSORDEDSET_MUTE_BY_CONTAINER
        {
            SEP_LINE
            
            A *a = A.random;
            A *b = A.random;
            
            NSMutableOrderedSet *mutOrderSet_a = [a d_mutableOrderedSetValueForKey:@"NSOrderedSet_field"];
            NSMutableOrderedSet *mutOrderSet_b = [b mutableOrderedSetValueForKey:@"NSOrderedSet_field"];
            
            TEST((mutOrderSet_a.class == NSClassFromString(@"DSKeyValueFastMutableOrderedSet2")) && (mutOrderSet_b.class == NSClassFromString(@"NSKeyValueFastMutableOrderedSet2")));
            
            [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
            [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
            //NSOrderedSet_field为nil，insertObject无影响
            TEST(a.NSOrderedSet_field == nil && b.NSOrderedSet_field == nil);
            
            {
                a.NSOrderedSet_field = [NSOrderedSet orderedSet];
                b.NSOrderedSet_field = [NSOrderedSet orderedSet];
                
                //NSSet_field为不可变，修改报异常
                
                NSException *catchException = nil;
                @try {
                    [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
                
                catchException = nil;
                @try {
                    [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
            }
            
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSet];
            b.NSOrderedSet_field = [NSMutableOrderedSet orderedSet];
            
            [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
            [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a insertObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 15)]];
            [mutOrderSet_b insertObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 15)]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            TEST(mutOrderSet_a.count == mutOrderSet_b.count);
            
            [mutOrderSet_a removeObjectAtIndex:0];
            [mutOrderSet_b removeObjectAtIndex:0];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a removeObjectAtIndex:mutOrderSet_a.count - 1];
            [mutOrderSet_b removeObjectAtIndex:mutOrderSet_b.count - 1];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)]];
            [mutOrderSet_b removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a replaceObjectAtIndex:2 withObject:NextRandomA_1];
            [mutOrderSet_b replaceObjectAtIndex:2 withObject:NextRandomA_2];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 5)] withObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutOrderSet_b replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 5)] withObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            {
                id objs_a[5];
                id objs_b[5];
                
                [mutOrderSet_a getObjects:objs_a range:NSMakeRange(3, 5)];
                [mutOrderSet_b getObjects:objs_b range:NSMakeRange(3, 5)];
                
                BOOL all_equal_in_range = YES;
                for (NSInteger i=0; i < 5; ++i) {
                    if (![objs_a[i] isEqual:objs_b[i]]) {
                        all_equal_in_range = NO;
                        break;
                    }
                }
                
                TEST(all_equal_in_range);
            }
            
            {
                id finder_a = NextRandomA_1;
                id finder_b = NextRandomA_2;
                
                [mutOrderSet_a insertObject:finder_a atIndex:4];
                [mutOrderSet_b insertObject:finder_b atIndex:4];
                
                TEST([mutOrderSet_a indexOfObject:finder_a] == 4 && [mutOrderSet_b indexOfObject:finder_a] == 4);
            }
            
            TEST([[mutOrderSet_a objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 8)]] isEqualToArray:[mutOrderSet_b objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 8)]]])
            
            SEP_LINE
        }
#else
        
        {
            SEP_LINE
            
            A *a = A.random;
            A *b = A.random;
            
            NSMutableOrderedSet *mutOrderSet_a = [a d_mutableOrderedSetValueForKey:@"NSOrderedSet_field"];
            NSMutableOrderedSet *mutOrderSet_b = [b mutableOrderedSetValueForKey:@"NSOrderedSet_field"];
            
            TEST((mutOrderSet_a.class == NSClassFromString(@"DSKeyValueSlowMutableOrderedSet")) && (mutOrderSet_b.class == NSClassFromString(@"NSKeyValueSlowMutableOrderedSet")));
            
            {
                //NSSet_field为nil，代理找不到原对象报异常
                
                NSException *catchException = nil;
                @try {
                    [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInternalInconsistencyException])
                }
                
                catchException = nil;
                @try {
                    [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInternalInconsistencyException])
                }
            }
            
            a.NSOrderedSet_field = [NSOrderedSet orderedSet];
            b.NSOrderedSet_field = [NSOrderedSet orderedSet];
            
            [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
            [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
            
            //代理将NSOrderedSet_field 由不可变类型更改为可变类型
            TEST([a.NSOrderedSet_field isKindOfClass:NSMutableOrderedSet.self] && [b.NSOrderedSet_field isKindOfClass:NSMutableOrderedSet.self] && [mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a insertObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 15)]];
            [mutOrderSet_b insertObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 15)]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            TEST(mutOrderSet_a.count == mutOrderSet_b.count);
            
            [mutOrderSet_a removeObjectAtIndex:0];
            [mutOrderSet_b removeObjectAtIndex:0];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a removeObjectAtIndex:mutOrderSet_a.count - 1];
            [mutOrderSet_b removeObjectAtIndex:mutOrderSet_b.count - 1];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)]];
            [mutOrderSet_b removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a replaceObjectAtIndex:2 withObject:NextRandomA_1];
            [mutOrderSet_b replaceObjectAtIndex:2 withObject:NextRandomA_2];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 5)] withObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutOrderSet_b replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 5)] withObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            {
                id objs_a[5];
                id objs_b[5];
                
                [mutOrderSet_a getObjects:objs_a range:NSMakeRange(3, 5)];
                [mutOrderSet_b getObjects:objs_b range:NSMakeRange(3, 5)];
                
                BOOL all_equal_in_range = YES;
                for (NSInteger i=0; i < 5; ++i) {
                    if (![objs_a[i] isEqual:objs_b[i]]) {
                        all_equal_in_range = NO;
                        break;
                    }
                }
                
                TEST(all_equal_in_range);
            }
            
            {
                id finder_a = NextRandomA_1;
                id finder_b = NextRandomA_2;
                
                [mutOrderSet_a insertObject:finder_a atIndex:4];
                [mutOrderSet_b insertObject:finder_b atIndex:4];
                
                TEST([mutOrderSet_a indexOfObject:finder_a] == 4 && [mutOrderSet_b indexOfObject:finder_a] == 4);
            }
            
            TEST([[mutOrderSet_a objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 8)]] isEqualToArray:[mutOrderSet_b objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 8)]]])
            
            SEP_LINE
        }
#endif
        {
            SEP_LINE
            
            A *a = A.random;
            A *b = A.random;
            
            NSMutableOrderedSet *mutOrderSet_a = [a d_mutableOrderedSetValueForKey:@"_NSOrderedSet_field"];
            NSMutableOrderedSet *mutOrderSet_b = [b mutableOrderedSetValueForKey:@"_NSOrderedSet_field"];
            
            TEST((mutOrderSet_a.class == NSClassFromString(@"DSKeyValueIvarMutableOrderedSet")) && (mutOrderSet_b.class == NSClassFromString(@"NSKeyValueIvarMutableOrderedSet")));
            
            [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
            [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
            //NSOrderedSet_field为nil， 代理为NSOrderedSet_field创建新的NSMutableOrderedSet
            TEST([a.NSOrderedSet_field isKindOfClass:NSMutableOrderedSet.self] && [b.NSOrderedSet_field isKindOfClass:NSMutableOrderedSet.self] && [mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            {
                a.NSOrderedSet_field  = [NSOrderedSet orderedSet];
                b.NSOrderedSet_field  = [NSOrderedSet orderedSet];
                
                //NSOrderedSet_field为不可变类型，更改报异常
                
                NSException *catchException = nil;
                @try {
                    [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
                
                catchException = nil;
                @try {
                    [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
                } @catch (NSException *exception) {
                    catchException = exception;
                } @finally {
                    TEST([catchException.name isEqualToString:NSInvalidArgumentException])
                }
            }
            
            a.NSOrderedSet_field  = [NSMutableOrderedSet orderedSet];
            b.NSOrderedSet_field  = [NSMutableOrderedSet orderedSet];
            
            [mutOrderSet_a insertObject:NextRandomA_1 atIndex:0];
            [mutOrderSet_b insertObject:NextRandomA_2 atIndex:0];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a insertObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 15)]];
            [mutOrderSet_b insertObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 15)]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            TEST(mutOrderSet_a.count == mutOrderSet_b.count);
            
            [mutOrderSet_a removeObjectAtIndex:0];
            [mutOrderSet_b removeObjectAtIndex:0];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a removeObjectAtIndex:mutOrderSet_a.count - 1];
            [mutOrderSet_b removeObjectAtIndex:mutOrderSet_b.count - 1];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)]];
            [mutOrderSet_b removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a replaceObjectAtIndex:2 withObject:NextRandomA_1];
            [mutOrderSet_b replaceObjectAtIndex:2 withObject:NextRandomA_2];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            [mutOrderSet_a replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 5)] withObjects:@[NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1,NextRandomA_1]];
            [mutOrderSet_b replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 5)] withObjects:@[NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2,NextRandomA_2]];
            TEST([mutOrderSet_a isEqualToOrderedSet:mutOrderSet_b]);
            
            {
                id objs_a[5];
                id objs_b[5];
                
                [mutOrderSet_a getObjects:objs_a range:NSMakeRange(3, 5)];
                [mutOrderSet_b getObjects:objs_b range:NSMakeRange(3, 5)];
                
                BOOL all_equal_in_range = YES;
                for (NSInteger i=0; i < 5; ++i) {
                    if (![objs_a[i] isEqual:objs_b[i]]) {
                        all_equal_in_range = NO;
                        break;
                    }
                }
                
                TEST(all_equal_in_range);
            }
            
            {
                id finder_a = NextRandomA_1;
                id finder_b = NextRandomA_2;
                
                [mutOrderSet_a insertObject:finder_a atIndex:4];
                [mutOrderSet_b insertObject:finder_b atIndex:4];
                
                TEST([mutOrderSet_a indexOfObject:finder_a] == 4 && [mutOrderSet_b indexOfObject:finder_a] == 4);
            }
            
            TEST([[mutOrderSet_a objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 8)]] isEqualToArray:[mutOrderSet_b objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 8)]]])
            
            SEP_LINE
        }
    }

}
