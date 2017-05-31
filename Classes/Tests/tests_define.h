#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "KVC.h"
#import "KVO.h"

#import <limits.h>
#import <objc/runtime.h>
#import "Log.h"

#pragma mark - utilities

#define ABORT_IF_FAILURE 1

#define TEST(condition) {\
BOOL pass = (condition); printf("%s [%s:%d] => %s\n",pass ? "✅" : "❌", __FUNCTION__, __LINE__, #condition); if(ABORT_IF_FAILURE && !pass) abort(); \
}\

#define TEST_AFTER_EXECUTE(condition, test_expressions...) {\
test_expressions; { BOOL pass = (condition);  printf("%s [%s:%d] => %s\n",pass ? "✅" : "❌", __FUNCTION__, __LINE__, #test_expressions); if(ABORT_IF_FAILURE && !pass) abort(); }\
}\

#define NEW_LINE printf("\n");

#define SEP_LINE printf("==========================================================================================================\n");

static inline NSString *random_string(size_t len) {
    NSMutableString *string = [NSMutableString string];
    NSString *CHARATCERS = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    for (NSUInteger i = 0; i < len; ++i) {
        [string appendFormat:@"%c", CHARATCERS.UTF8String[arc4random() % CHARATCERS.length]];
    }
    return  string;
}

#define random_string_20 random_string(20)


#pragma mark - class

#define NSARRAY_MUTE_BY_CONTAINER       1
#define NSSET_MUTE_BY_CONTAINER         1
#define NSORDEDSET_MUTE_BY_CONTAINER  1

#define AFFECTING_KEY_PATH_TEST_ON   1

#define AUTO_NOTIFY_ON               1

#define CUSTOMER_WILL_OR_DID_CHANGE 0

@class B;
@class C;
@class D;
@class E;
@class F;

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
#if TARGET_OS_OSX
@property (nonatomic, assign) NSPoint NSPoint_field;
@property (nonatomic, assign) NSRect NSRect_field;
#endif
@property (nonatomic, assign) NSRange NSRange_field;
@property (nonatomic, assign) CGPoint CGPoint_field;
@property (nonatomic, assign) CGRect CGRect_field;

@property (nonatomic, strong) A *A_field;
@property (nonatomic, strong) NSMutableArray<A *> *NSArray_field;
@property (nonatomic, strong) NSMutableSet<A *> *NSSet_field;
@property (nonatomic, strong) NSMutableOrderedSet<A *> *NSOrderedSet_field;

@property (nonatomic, strong) B *B_field;
@property (nonatomic, strong) C *C_field;
@property (nonatomic, strong) D *D_field;
@property (nonatomic, strong) E *E_field;
@property (nonatomic, strong) F *F_field;

+ (instancetype)random;
+ (instancetype)randomWithIdentifier:(NSString *)identifier;
#if NSARRAY_MUTE_BY_CONTAINER
- (void)insertObject:(A *)object inNSArray_fieldAtIndex:(NSUInteger)index;
- (void)removeObjectFromNSArray_fieldAtIndex:(NSUInteger)index ;
- (void)replaceObjectInNSArray_fieldAtIndex:(NSUInteger)index withObject:(id)object ;
- (void)insertNSArray_field:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeNSArray_fieldAtIndexes:(NSIndexSet *)indexes;
- (void)replaceNSArray_fieldAtIndexes:(NSIndexSet *)indexes withNSArray_field:(NSArray *)array;
#endif
#if NSSET_MUTE_BY_CONTAINER
- (void)addNSSet_fieldObject:(A *)object;
- (void)removeNSSet_fieldObject:(A *)object;
-(void)intersectNSSet_field:(NSSet *)objects;
- (void)removeNSSet_field:(NSSet *)objects;
- (void)addNSSet_field:(NSSet *)objects;
#endif
#if NSORDEDSET_MUTE_BY_CONTAINER
- (void)insertObject:(A *)object inNSOrderedSet_fieldAtIndex:(NSUInteger)index;
- (void)removeObjectFromNSOrderedSet_fieldAtIndex:(NSUInteger)index;
- (void)replaceObjectInNSOrderedSet_fieldAtIndex:(NSUInteger)index withObject:(id)object;
- (void)insertNSOrderedSet_field:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeNSOrderedSet_fieldAtIndexes:(NSIndexSet *)indexes;
- (void)replaceNSOrderedSet_fieldAtIndexes:(NSIndexSet *)indexes withNSOrderedSet_field:(NSArray *)array;
#endif
@end

@interface B : A
@end

@interface C : A
@end

@interface D : A
@end

@interface E : A
@end

@interface F : A
@end

static inline A * nextRandomA_1() {static int index = 0; return [A randomWithIdentifier:[NSString stringWithFormat:@"%06d", index++]];}
static inline A * nextRandomA_2() {static int index = 0; return [A randomWithIdentifier:[NSString stringWithFormat:@"%06d", index++]];}
#define NextRandomA_1 nextRandomA_1()
#define NextRandomA_2 nextRandomA_2()

#pragma mark - notify result

@interface _KVONotifyItem : NSObject
@property (nonatomic, strong) id observer;
@property (nonatomic, strong) id keyPath;
@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSDictionary *change;
@property (nonatomic, assign) void * context;
@end

@interface KVONotifyResult : NSObject
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSMutableArray *items;
- (void)appendWithObserver:(id)observer KeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@end

#define KVONotifyResultKey @"KVONotifyResult"

static inline KVONotifyResult *PICK_NOTIFY_RESULT_PERTHREAD() {
    NSThread *currentThread = [NSThread currentThread];
    KVONotifyResult *result = [currentThread.threadDictionary[KVONotifyResultKey] retain];
    currentThread.threadDictionary[KVONotifyResultKey] = nil;
    return result.autorelease;
}

static inline KVONotifyResult *GET_NOTIFY_RESULT_PERTHREAD() {
    NSThread *currentThread = [NSThread currentThread];
    KVONotifyResult *result = [currentThread.threadDictionary[KVONotifyResultKey] retain];
    if (!result) {
        result = [KVONotifyResult new];
        currentThread.threadDictionary[KVONotifyResultKey] = result;
    }
    return result.autorelease;
}




#pragma mark - Observer
@interface Observer : NSObject

@end

@interface ObserverA : Observer
@end

@interface ObserverB : Observer
@end

@interface ObserverC : Observer
@end

@interface ObserverD : Observer
@end

@interface ObserverE : Observer
@end

@interface ObserverF : Observer
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
