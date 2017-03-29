//
//  NSKeyValueContainerClass.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <pthread.h>

@class NSKeyValueContainerClass;
@class NSKeyValueObservationInfo;

typedef struct NSKeyValueNotifyingInfo {
    Class originalClass;
    Class containerClass;
    CFMutableSetRef keys;
    CFMutableDictionaryRef selKeyMap;
    pthread_mutex_t mutex;
    BOOL flag;
}NSKeyValueNotifyingInfo;

#define ISKVOASelector NSSelectorFromString(@"_isKVOA")

NSKeyValueNotifyingInfo *_NSKeyValueContainerClassGetNotifyingInfo(NSKeyValueContainerClass *containerClass);

void NSKVONotifyingSetMethodImplementation(NSKeyValueNotifyingInfo *info, SEL sel, IMP imp, NSString *key);

NSKeyValueNotifyingInfo *_NSKVONotifyingCreateInfoWithOriginalClass(Class originalClass);

BOOL _NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key);

NSKeyValueContainerClass * _NSKeyValueContainerClassForIsa(Class isa);

void _NSKVONotifyingEnableForInfoAndKey(NSKeyValueNotifyingInfo *info, NSString *key);

NSKeyValueObservationInfo *_NSKeyValueRetainedObservationInfoForObject(id object, NSKeyValueContainerClass *containerClass) ;

Class _NSKVONotifyingOriginalClassForIsa(Class isa);

BOOL NSKVOIsAutonotifying();

@interface NSKeyValueContainerClass : NSObject

@property (nonatomic, assign) Class originalClass;
@property (nonatomic, assign) void * (*cachedObservationInfoImplementation)(id, SEL);
@property (nonatomic, assign) void (*cachedSetObservationInfoImplementation)(id,SEL,void *);
@property (nonatomic, assign) BOOL cachedSetObservationInfoTakesAnObject;
@property (nonatomic, assign) NSKeyValueNotifyingInfo * notifyingInfo;

- (id)initWithOriginalClass:(Class)originalClass;

@end

