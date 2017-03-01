//
//  NSKeyValueContainerClass.h
//  KVOIMP
//
//  Created by JK on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <pthread.h>

typedef struct NSKeyValueNotifyingInfo {
    Class originalClass;
    Class containerClass;
    CFMutableSetRef keys;
    CFMutableDictionaryRef selMap;
    pthread_mutex_t mutex;
    BOOL flag;
}NSKeyValueNotifyingInfo;

@interface NSKeyValueContainerClass : NSObject

@property (nonatomic, assign) Class originalClass;
@property (nonatomic, assign) void * (*cachedObservationInfoImplementation)(id, SEL);
@property (nonatomic, assign) void (*cachedSetObservationInfoImplementation)(id,SEL,void *);
@property (nonatomic, assign) BOOL cachedSetObservationInfoTakesAnObject;
@property (nonatomic, assign) NSKeyValueNotifyingInfo * notifyingInfo;

- (id)initWithOriginalClass:(Class)originalClass;

@end

NSKeyValueNotifyingInfo *_NSKVONotifyingCreateInfoWithOriginalClass(Class originalClass) ;
NSKeyValueNotifyingInfo *_NSKeyValueContainerClassGetNotifyingInfo(NSKeyValueContainerClass *containerClass);
Class _NSKVONotifyingOriginalClassForIsa(Class isa);
NSKeyValueContainerClass * _NSKeyValueContainerClassForIsa(Class isa);
