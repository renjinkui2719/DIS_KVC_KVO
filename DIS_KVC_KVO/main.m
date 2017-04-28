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
#import "NSArray+DSKeyValueCoding.h"
#import <limits.h>

#define TEST_0(condition, test_expressions...) {\
    test_expressions;    printf("%s [%s:%d] => %s\n",(condition) ? "✅" : "❌", __FUNCTION__, __LINE__, #test_expressions);\
}\

#define TEST_1(condition) {\
  printf("%s [%s:%d] => %s\n",(condition) ? "✅" : "❌", __FUNCTION__, __LINE__, #condition);\
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

@interface BankCard : NSObject
{
    @public
    double _money;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, copy) NSString *ID;

+ (BankCard *)random;

@end

@implementation BankCard
+ (BankCard *)random {
    BankCard *c = [BankCard new];
    c.name = [NSString random:10];
    c.createDate = [NSDate new];
    c.ID = [NSString random:18];
    c->_money = arc4random() % 100000;
    return c;
}

- (BOOL)isEqual:(id)object {
    if (object == self) { return YES; }
    if (![object isKindOfClass:self.class]) { return NO; }
    BankCard *other = (BankCard *)object;
    return [_ID isEqualToString:other.ID];
}

- (NSUInteger)hash {
    return _ID.hash;
}

@end

@interface Body : NSObject
@property (nonatomic, assign) char gender;
@property (nonatomic, assign) BOOL isHandsome;
@property (nonatomic, assign) unsigned char handsomeLevel;
@property (nonatomic, assign) short toothCount;
@property (nonatomic, assign) unsigned short fingerCount;
@property (nonatomic, assign) int eyelashCount;
@property (nonatomic, assign) unsigned int haireCount;
@property (nonatomic, assign) long brainCellCount;
@property (nonatomic, assign) unsigned long bloodCellCount;
@property (nonatomic, assign) long long totalCellCount;
@property (nonatomic, assign) unsigned long long moleculeCount;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) NSPoint ns_nosePosition;
@property (nonatomic, assign) NSRange ns_bloodPressureRange;
@property (nonatomic, assign) NSRect ns_faceRect;
@property (nonatomic, assign) CGPoint cg_nosePosition;
@property (nonatomic, assign) CGRect cg_faceRect;

+ (Body *)random;

@end

@implementation Body
+ (Body *)random {
    Body *body = [Body new];
    body.gender = ((arc4random() % 2) ? -1 : 1);
    body.isHandsome = ((arc4random() % 2) ? YES : NO);
    body.toothCount = arc4random();
    body.fingerCount = arc4random();
    body.eyelashCount = arc4random();
    body.haireCount = arc4random();
    body.brainCellCount = arc4random();
    body.bloodCellCount = arc4random();
    body.totalCellCount = arc4random();
    body.moleculeCount = arc4random();
    body.weight = arc4random();
    body.height = arc4random();
    body.ns_nosePosition = NSMakePoint(arc4random(), arc4random());
    body.ns_bloodPressureRange = NSMakeRange(arc4random(), arc4random());
    body.ns_faceRect = NSMakeRect(arc4random(), arc4random(), arc4random(), arc4random());
    body.cg_nosePosition = CGPointMake(arc4random(), arc4random());
    body.cg_faceRect = CGRectMake(arc4random(), arc4random(), arc4random(), arc4random());
    return body;
}
@end

@interface Person : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, strong) NSMutableArray<BankCard *> *cards;
@property (nonatomic, strong) Body *body;
@property (nonatomic, strong) Person *bestFriend;

+ (Person *)random;

@end

@implementation Person
+ (Person *)random {
    Person *p = [Person new];
    p.name = [NSString random:10];
    p.age = arc4random() % 100;
    p.cards = [NSMutableArray arrayWithObjects:[BankCard random], [BankCard random], [BankCard random],nil];
    p.body = [Body random];
    return p;
}

- (BOOL)isEqual:(id)object {
    if (object == self) { return YES; }
    if (![object isKindOfClass:self.class]) { return NO; }
    Person *other = (Person *)object;
    return [_name isEqualToString:other.name];
}

- (NSUInteger)hash {
    return _name.hash;
}

@end


void TestKVC();

int main(int argc, const char * argv[]) {
    
    NSMutableArray<Person *> *persons = [NSMutableArray array];
    [persons addObject:({
        Person *p = [Person random];
        p.name = @"01";
        p;
    })];
    [persons addObject:({
        Person *p = [Person random];
        p.name = @"02";
        p;
    })];
    [persons addObject:({
        Person *p = [Person random];
        p.name = @"03";
        p;
    })];
    [persons addObject:({
        Person *p = [Person random];
        p.name = @"01";
        p;
    })];
    
    persons[0].cards[0].ID = @"00001";
    persons[0].cards[1].ID = @"00001";
    persons[0].cards[2].ID = @"00001";
    
    id v = [persons d_valueForKeyPath:@"@lastObject"];

    //NSArray *array = @[@1,@2,@3,@4,@5,@6,@1,@3,@5];
    //id v = [array d_valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    //v = [array valueForKeyPath:@"@unionOfObjects.intValue"];
    
    //NSArray *cards = @[BankCard.random, BankCard.random, BankCard.random, BankCard.random, BankCard.random];
    //NSArray *cards1 = @[BankCard.random, BankCard.random, BankCard.random, BankCard.random, BankCard.random];
    //[cards isEqualToArray:cards1];
    
    //id v = [cards d_valueForKeyPath:@"@sum._money"];
    //v = [cards valueForKeyPath:@"@sum._money"];
    
    //Person *person = [Person random];
    
    //[person d_setValue:@123 forKeyPath:@"cards.money"];
    
    NSLog(@"");
    
    TestKVC();
}


void TestKVC() {
    
    Body *body = [Body new];
    SEP_LINE
    TEST_0(body.gender == CHAR_MAX, [body d_setValue:@CHAR_MAX forKey:@"gender"]);
    TEST_1([[body d_valueForKey:@"gender"] isEqual:@CHAR_MAX]);
    TEST_0(body.gender == CHAR_MAX, [body d_setValue:@CHAR_MAX forKeyPath:@"gender"]);
    TEST_1([[body d_valueForKeyPath:@"gender"] isEqual:@CHAR_MAX]);
    NEW_LINE
    TEST_0(body.isHandsome == YES, [body d_setValue:@YES forKey:@"isHandsome"]);
    TEST_1([[body d_valueForKey:@"isHandsome"] isEqual:@YES]);
    TEST_0(body.isHandsome == YES, [body d_setValue:@YES forKeyPath:@"isHandsome"]);
    TEST_1([[body d_valueForKeyPath:@"isHandsome"] isEqual:@YES]);
    TEST_0(body.isHandsome == YES, [body d_setValue:@YES forKey:@"handsome"]);
    TEST_1([[body d_valueForKey:@"handsome"] isEqual:@YES]);
    TEST_0(body.isHandsome == YES, [body d_setValue:@YES forKeyPath:@"handsome"]);
    TEST_1([[body d_valueForKeyPath:@"handsome"] isEqual:@YES]);
    NEW_LINE
    TEST_0(body.handsomeLevel == UCHAR_MAX, [body d_setValue:@UCHAR_MAX forKey:@"handsomeLevel"]);
    TEST_1([[body d_valueForKey:@"handsomeLevel"] isEqual:@UCHAR_MAX]);
    TEST_0(body.handsomeLevel == UCHAR_MAX, [body d_setValue:@UCHAR_MAX forKeyPath:@"handsomeLevel"]);
    TEST_1([[body d_valueForKeyPath:@"handsomeLevel"] isEqual:@UCHAR_MAX]);
    NEW_LINE
    TEST_0(body.toothCount == SHRT_MAX, [body d_setValue:@SHRT_MAX forKey:@"toothCount"]);
    TEST_1([[body d_valueForKey:@"toothCount"] isEqual:@SHRT_MAX]);
    TEST_0(body.toothCount == SHRT_MAX, [body d_setValue:@SHRT_MAX forKeyPath:@"toothCount"]);
    TEST_1([[body d_valueForKeyPath:@"toothCount"] isEqual:@SHRT_MAX]);
    NEW_LINE
    TEST_0(body.fingerCount == USHRT_MAX, [body d_setValue:@USHRT_MAX forKey:@"fingerCount"]);
    TEST_1([[body d_valueForKey:@"fingerCount"] isEqual:@USHRT_MAX]);
    TEST_0(body.fingerCount == USHRT_MAX, [body d_setValue:@USHRT_MAX forKeyPath:@"fingerCount"]);
    TEST_1([[body d_valueForKeyPath:@"fingerCount"] isEqual:@USHRT_MAX]);
    NEW_LINE
    TEST_0(body.eyelashCount == INT_MAX , [body d_setValue:@INT_MAX forKey:@"eyelashCount"]);
    TEST_1([[body d_valueForKey:@"eyelashCount"] isEqual:@INT_MAX]);
    TEST_0(body.eyelashCount == INT_MAX , [body d_setValue:@INT_MAX forKeyPath:@"eyelashCount"]);
    TEST_1([[body d_valueForKeyPath:@"eyelashCount"] isEqual:@INT_MAX]);
    NEW_LINE
    TEST_0(body.haireCount == UINT_MAX, [body d_setValue:@UINT_MAX forKey:@"haireCount"]);
    TEST_1([[body d_valueForKey:@"haireCount"] isEqual:@UINT_MAX]);
    TEST_0(body.haireCount == UINT_MAX, [body d_setValue:@UINT_MAX forKeyPath:@"haireCount"]);
    TEST_1([[body d_valueForKeyPath:@"haireCount"] isEqual:@UINT_MAX]);
    NEW_LINE
    TEST_0(body.brainCellCount == LONG_MAX, [body d_setValue:@LONG_MAX forKey:@"brainCellCount"]);
    TEST_1([[body d_valueForKey:@"brainCellCount"] isEqual:@LONG_MAX]);
    TEST_0(body.brainCellCount == LONG_MAX, [body d_setValue:@LONG_MAX forKeyPath:@"brainCellCount"]);
    TEST_1([[body d_valueForKeyPath:@"brainCellCount"] isEqual:@LONG_MAX]);
    NEW_LINE
    TEST_0(body.bloodCellCount == ULONG_MAX, [body d_setValue:@ULONG_MAX forKey:@"bloodCellCount"]);
    TEST_1([[body d_valueForKey:@"bloodCellCount"] isEqual:@ULONG_MAX]);
    TEST_0(body.bloodCellCount == ULONG_MAX, [body d_setValue:@ULONG_MAX forKeyPath:@"bloodCellCount"]);
    TEST_1([[body d_valueForKeyPath:@"bloodCellCount"] isEqual:@ULONG_MAX]);
    NEW_LINE
    TEST_0(body.totalCellCount == LONG_LONG_MAX, [body d_setValue:@LONG_LONG_MAX forKey:@"totalCellCount"]);
    TEST_1([[body d_valueForKey:@"totalCellCount"] isEqual:@LONG_LONG_MAX]);
    TEST_0(body.totalCellCount == LONG_LONG_MAX, [body d_setValue:@LONG_LONG_MAX forKeyPath:@"totalCellCount"]);
    TEST_1([[body d_valueForKeyPath:@"totalCellCount"] isEqual:@LONG_LONG_MAX]);
    NEW_LINE
    TEST_0(body.moleculeCount == ULONG_LONG_MAX, [body d_setValue:@ULONG_LONG_MAX forKey:@"moleculeCount"]);
    TEST_1([[body d_valueForKey:@"moleculeCount"] isEqual:@ULONG_LONG_MAX]);
    TEST_0(body.moleculeCount == ULONG_LONG_MAX, [body d_setValue:@ULONG_LONG_MAX forKeyPath:@"moleculeCount"]);
    TEST_1([[body d_valueForKeyPath:@"moleculeCount"] isEqual:@ULONG_LONG_MAX]);
    NEW_LINE
    TEST_0(body.weight == MAXFLOAT, [body d_setValue:@MAXFLOAT forKey:@"weight"]);
    TEST_1([[body d_valueForKey:@"weight"] isEqual:@MAXFLOAT]);
    TEST_0(body.weight == MAXFLOAT, [body d_setValue:@MAXFLOAT forKeyPath:@"weight"]);
    TEST_1([[body d_valueForKeyPath:@"weight"] isEqual:@MAXFLOAT]);
    NEW_LINE
    TEST_0(body.height == MAXFLOAT, [body d_setValue:@MAXFLOAT forKey:@"height"]);
    TEST_1([[body d_valueForKey:@"height"] isEqual:@MAXFLOAT]);
    TEST_0(body.height == MAXFLOAT, [body d_setValue:@MAXFLOAT forKeyPath:@"height"]);
    TEST_1([[body d_valueForKeyPath:@"height"] isEqual:@MAXFLOAT]);
    NEW_LINE
    TEST_0(body.ns_nosePosition.x == 10 && body.ns_nosePosition.y == 20, [body d_setValue:[NSValue valueWithPoint:NSMakePoint(10, 20)] forKey:@"ns_nosePosition"]);
    TEST_1([[body d_valueForKey:@"ns_nosePosition"] isEqual:[NSValue valueWithPoint:NSMakePoint(10, 20)]]);
    TEST_0(body.ns_nosePosition.x == 10 && body.ns_nosePosition.y == 20, [body d_setValue:[NSValue valueWithPoint:NSMakePoint(10, 20)] forKeyPath:@"ns_nosePosition"]);
    TEST_1([[body d_valueForKeyPath:@"ns_nosePosition"] isEqual:[NSValue valueWithPoint:NSMakePoint(10, 20)]]);
    NEW_LINE
    TEST_0(body.ns_bloodPressureRange.location == 10 && body.ns_bloodPressureRange.length == 20, [body d_setValue:[NSValue valueWithRange:NSMakeRange(10, 20)] forKey:@"ns_bloodPressureRange"]);
    TEST_1([[body d_valueForKey:@"ns_bloodPressureRange"] isEqual:[NSValue valueWithRange:NSMakeRange(10, 20)]]);
    TEST_0(body.ns_bloodPressureRange.location == 10 && body.ns_bloodPressureRange.length == 20, [body d_setValue:[NSValue valueWithRange:NSMakeRange(10, 20)] forKeyPath:@"ns_bloodPressureRange"]);
    TEST_1([[body d_valueForKeyPath:@"ns_bloodPressureRange"] isEqual:[NSValue valueWithRange:NSMakeRange(10, 20)]]);
    NEW_LINE
    TEST_0(body.ns_faceRect.origin.x == 10 && body.ns_faceRect.origin.y == 20 && body.ns_faceRect.size.width == 30 && body.ns_faceRect.size.height == 40, [body d_setValue:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)] forKey:@"ns_faceRect"]);
    TEST_1([[body d_valueForKey:@"ns_faceRect"] isEqual:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)]]);
    TEST_0(body.ns_faceRect.origin.x == 10 && body.ns_faceRect.origin.y == 20 && body.ns_faceRect.size.width == 30 && body.ns_faceRect.size.height == 40, [body d_setValue:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)] forKeyPath:@"ns_faceRect"]);
    TEST_1([[body d_valueForKeyPath:@"ns_faceRect"] isEqual:[NSValue valueWithRect:NSMakeRect(10, 20, 30, 40)]]);
    NEW_LINE
    TEST_0(body.cg_nosePosition.x == 10 && body.cg_nosePosition.y == 20, [body d_setValue:[NSValue valueWithPoint:CGPointMake(10, 20)] forKey:@"cg_nosePosition"]);
    TEST_1([[body d_valueForKey:@"cg_nosePosition"] isEqual:[NSValue valueWithPoint:CGPointMake(10, 20)]]);
    TEST_0(body.cg_nosePosition.x == 10 && body.cg_nosePosition.y == 20, [body d_setValue:[NSValue valueWithPoint:CGPointMake(10, 20)] forKeyPath:@"cg_nosePosition"]);
    TEST_1([[body d_valueForKeyPath:@"cg_nosePosition"] isEqual:[NSValue valueWithPoint:CGPointMake(10, 20)]]);
    NEW_LINE
    TEST_0(body.cg_faceRect.origin.x == 10 && body.cg_faceRect.origin.y == 20 && body.cg_faceRect.size.width == 30 && body.cg_faceRect.size.height == 40, [body d_setValue:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)] forKey:@"cg_faceRect"]);
    TEST_1([[body d_valueForKey:@"cg_faceRect"] isEqual:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)]]);
    TEST_0(body.cg_faceRect.origin.x == 10 && body.cg_faceRect.origin.y == 20 && body.cg_faceRect.size.width == 30 && body.cg_faceRect.size.height == 40, [body d_setValue:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)] forKeyPath:@"cg_faceRect"]);
    TEST_1([[body d_valueForKeyPath:@"cg_faceRect"] isEqual:[NSValue valueWithRect:CGRectMake(10, 20, 30, 40)]]);
    
    SEP_LINE
    {
        NSException *catchException = nil;
        @try {
            [body d_valueForKey:@"wtf"];
        } @catch (NSException *exception) {
            catchException = exception;
        } @finally {
            TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
        }
        catchException = nil;
        @try {
            [body d_setValue:@1 forKey:@"wtf"];
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
            [body d_valueForKeyPath:@"wtf.x.y"];
        } @catch (NSException *exception) {
            catchException = exception;
        } @finally {
            TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
        }
        catchException = nil;
        @try {
            [body d_setValue:@1 forKeyPath:@"wtf.x.y"];
        } @catch (NSException *exception) {
            catchException = exception;
        } @finally {
            TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
        }
    }
    SEP_LINE
    
    BankCard *CCBCard = [BankCard new];
    
    NEW_LINE
    TEST_0([CCBCard.name isEqualToString:@"CCB?"], [CCBCard d_setValue:@"CCB?" forKey:@"name"]);
    TEST_1([[CCBCard d_valueForKey:@"name"] isEqualToString:@"CCB?"]);
    TEST_0([CCBCard.name isEqualToString:@"CCB"], [CCBCard d_setValue:@"CCB" forKeyPath:@"name"]);
    TEST_1([[CCBCard d_valueForKeyPath:@"name"] isEqualToString:@"CCB"]);
    NEW_LINE
    {
        NSDate *date = [NSDate new];
        TEST_0([CCBCard.createDate isEqual:date], [CCBCard d_setValue:date forKey:@"createDate"]);
        TEST_1([[CCBCard d_valueForKey:@"createDate"] isEqual:date]);
        TEST_0([CCBCard.createDate isEqual:date], [CCBCard d_setValue:date forKeyPath:@"createDate"]);
        TEST_1([[CCBCard d_valueForKeyPath:@"createDate"] isEqual:date]);
    }
    NEW_LINE
    TEST_0([CCBCard.ID isEqualToString:@"012564534563776"], [CCBCard d_setValue:@"012564534563776" forKey:@"ID"]);
    TEST_1([[CCBCard d_valueForKey:@"ID"] isEqualToString:@"012564534563776"]);
    TEST_0([CCBCard.ID isEqualToString:@"012564534563776"], [CCBCard d_setValue:@"012564534563776" forKeyPath:@"ID"]);
    TEST_1([[CCBCard d_valueForKeyPath:@"ID"] isEqualToString:@"012564534563776"]);
    NEW_LINE
    TEST_0(CCBCard->_money == 999.0, [CCBCard d_setValue:@999.0 forKey:@"_money"]);
    TEST_1([[CCBCard d_valueForKey:@"_money"] isEqual:@999.0]);
    TEST_0(CCBCard->_money == 888.0, [CCBCard d_setValue:@888.0 forKeyPath:@"_money"]);
    TEST_1([[CCBCard d_valueForKeyPath:@"_money"] isEqual:@888.0]);
    TEST_0(CCBCard->_money == 777.0, [CCBCard d_setValue:@777.0 forKey:@"money"]);
    TEST_1([[CCBCard d_valueForKey:@"money"] isEqual:@777.0]);
    TEST_0(CCBCard->_money == 666.0, [CCBCard d_setValue:@666.0 forKeyPath:@"money"]);
    TEST_1([[CCBCard d_valueForKeyPath:@"money"] isEqual:@666.0]);
    SEP_LINE
    
    BankCard *ICBCCard = [BankCard new];
    ICBCCard.name = @"ICB";
    ICBCCard.createDate = [NSDate new];
    ICBCCard->_money = 5678.0;
    ICBCCard.ID = @"73647854345235627";
    BankCard *BOCCard = [BankCard new];
    BOCCard.name = @"BOC";
    BOCCard.createDate = [NSDate new];
    BOCCard->_money = 5324.0;
    BOCCard.ID = @"78764357576346789";
    
    NSMutableArray<BankCard *> *cards = [NSMutableArray arrayWithObjects:CCBCard, ICBCCard, BOCCard, nil];
    
    Person *person = [Person new];
    person.name = @"Jack";
    person.age = 27;
    person.bestFriend = [Person random];
    person.bestFriend.bestFriend = [Person random];
    
    NEW_LINE
    TEST_0(person.cards == cards, [person d_setValue:cards forKey:@"cards"]);
    TEST_1([person d_valueForKey:@"cards"] == cards);
    TEST_0(person.cards == cards, [person d_setValue:cards forKeyPath:@"cards"]);
    TEST_1([person d_valueForKeyPath:@"cards"] == cards);
    NEW_LINE
    TEST_0(person.body == body, [person d_setValue:body forKey:@"body"]);
    TEST_1([person d_valueForKey:@"body"] == body);
    TEST_0(person.body == body, [person d_setValue:body forKeyPath:@"body"]);
    TEST_1([person d_valueForKeyPath:@"body"] == body);
    NEW_LINE
    {
        NSException *catchException = nil;
        @try {
            [person d_valueForKey:@"body.weight"];
        } @catch (NSException *exception) {
            catchException = exception;
        } @finally {
            TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
        }
    }
    
    TEST_1([[person d_valueForKeyPath:@"body.weight"] isEqual: @(person.body.weight)])
    
    NEW_LINE
    {
        NSException *catchException = nil;
        @try {
            [person d_setValue:@(87.5) forKey:@"body.weight"];
        } @catch (NSException *exception) {
            catchException = exception;
        } @finally {
            TEST_1([catchException.name isEqualToString:NSUnknownKeyException])
        }
    }
    NEW_LINE
    TEST_0(person.body.weight == 87.5, [person d_setValue:@87.5 forKeyPath:@"body.weight"]);
    TEST_1([@(person.body.weight) isEqual: [person d_valueForKeyPath:@"body.weight"]]);
    NEW_LINE
    TEST_0(person.bestFriend.body.weight == 87.5, [person d_setValue:@87.5 forKeyPath:@"bestFriend.body.weight"]);
    TEST_1([@(person.bestFriend.body.weight) isEqual: [person d_valueForKeyPath:@"bestFriend.body.weight"]]);
    NEW_LINE
    TEST_0(person.bestFriend.bestFriend.body.weight == 87.5, [person d_setValue:@87.5 forKeyPath:@"bestFriend.bestFriend.body.weight"]);
    TEST_1([@(person.bestFriend.bestFriend.body.weight) isEqual: [person d_valueForKeyPath:@"bestFriend.bestFriend.body.weight"]]);
    SEP_LINE
    
    NEW_LINE
    
    TEST_1([[person d_valueForKeyPath:@"cards.money"] isEqualToArray:[person valueForKeyPath:@"cards.money"]])
    TEST_1([[person d_valueForKeyPath:@"bestFriend.bestFriend.cards.money"] isEqualToArray:[person valueForKeyPath:@"bestFriend.bestFriend.cards.money"]])
    NEW_LINE
    {
        [person d_setValue:@789 forKeyPath:@"cards.money"];
        BOOL allSet_to_789 = YES;
        for (BankCard *card in person.cards) {
            if (card->_money != 789.0) {
                allSet_to_789 = NO;
                break;
            }
        }
        TEST_1(allSet_to_789);
    }
    NEW_LINE
    //测试NSArray集合运算符, 和系统方法的值相同，则认为测试通过
    TEST_1([[person d_valueForKeyPath:@"cards.@count"] isEqual: [person valueForKeyPath:@"cards.@count"]]);
    TEST_1([[person d_valueForKeyPath:@"cards.@sum.money"] isEqual: [person valueForKeyPath:@"cards.@sum.money"]]);
    TEST_1([[person d_valueForKeyPath:@"cards.@avg.money"] isEqual: [person valueForKeyPath:@"cards.@avg.money"]]);
    TEST_1([[person d_valueForKeyPath:@"cards.@max.money"] isEqual: [person valueForKeyPath:@"cards.@max.money"]]);
    TEST_1([[person d_valueForKeyPath:@"cards.@min.money"] isEqual: [person valueForKeyPath:@"cards.@min.money"]]);
    NEW_LINE
    TEST_1([[person d_valueForKeyPath:@"bestFriend.bestFriend.cards.@count"] isEqual: [person valueForKeyPath:@"bestFriend.bestFriend.cards.@count"]]);
    TEST_1([[person d_valueForKeyPath:@"bestFriend.bestFriend.cards.@sum.money"] isEqual: [person valueForKeyPath:@"bestFriend.bestFriend.cards.@sum.money"]]);
    TEST_1([[person d_valueForKeyPath:@"bestFriend.bestFriend.cards.@avg.money"] isEqual: [person valueForKeyPath:@"bestFriend.bestFriend.cards.@avg.money"]]);
    TEST_1([[person d_valueForKeyPath:@"bestFriend.bestFriend.cards.@max.money"] isEqual: [person valueForKeyPath:@"bestFriend.bestFriend.cards.@max.money"]]);
    TEST_1([[person d_valueForKeyPath:@"bestFriend.bestFriend.cards.@min.money"] isEqual: [person valueForKeyPath:@"bestFriend.bestFriend.cards.@min.money"]]);
    SEP_LINE
}
