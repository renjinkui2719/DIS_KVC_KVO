//
//  DSKeyValueAccessor.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface DSKeyValueAccessor : NSObject

@property (nonatomic, assign) id containerClassID;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, assign) NSUInteger hashValue;
@property (nonatomic, assign) IMP implementation;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) NSUInteger extraArgumentCount;
@property (nonatomic, assign) void* extraArgument1;
@property (nonatomic, assign) void* extraArgument2;
@property (nonatomic, assign) void* extraArgument3;

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key implementation:(IMP)implementation selector:(SEL)selector extraArguments:(void *[3])extraArguments count:(NSUInteger)count;

@end

NSUInteger DSKeyValueAccessorHash(DSKeyValueAccessor *accrssor);
BOOL DSKeyValueAccessorIsEqual(DSKeyValueAccessor *lhs, DSKeyValueAccessor *rhs);


typedef enum {
    objc_ivar_memoryUnknown,     // unknown / unknown
    objc_ivar_memoryStrong,      // direct access / objc_storeStrong
    objc_ivar_memoryWeak,        // objc_loadWeak[Retained] / objc_storeWeak
    objc_ivar_memoryUnretained   // direct access / direct access
} objc_ivar_memory_management_t;

objc_ivar_memory_management_t _class_getIvarMemoryManagement(Class cls, Ivar ivar);
