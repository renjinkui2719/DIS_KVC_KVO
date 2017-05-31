//
//  DSKeyValueContainerClass.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <pthread.h>

@class DSKeyValueContainerClass;
@class DSKeyValueObservationInfo;

typedef struct DSKeyValueNotifyingInfo {
    Class originalClass;
    Class newSubClass;
    CFMutableSetRef notifyingKeys;
    CFMutableDictionaryRef selKeyMap;
    pthread_mutex_t mutex;
    //originalClass类是否覆写了 willChangeValueForKey: 或  didChangeValueForKey:
    BOOL overrideWillOrDidChange;
}DSKeyValueNotifyingInfo;

#define ISKVOA_SELECTOR NSSelectorFromString(@"_isKVOA")
#define NOTIFY_CLASSNAME_PREFIX "DSKVONotifying_"

DSKeyValueNotifyingInfo *_DSKeyValueContainerClassGetNotifyingInfo(DSKeyValueContainerClass *containerClass);

void DSKVONotifyingSetMethodImplementation(DSKeyValueNotifyingInfo *info, SEL sel, IMP imp, NSString *key);

DSKeyValueNotifyingInfo *_DSKVONotifyingCreateInfoWithOriginalClass(Class originalClass);

BOOL _DSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key);

DSKeyValueContainerClass * _DSKeyValueContainerClassForIsa(Class isa);

void _DSKVONotifyingEnableForInfoAndKey(DSKeyValueNotifyingInfo *info, NSString *key);

Class _DSKVONotifyingOriginalClassForIsa(Class isa);

BOOL DSKVOIsAutonotifying();

@interface DSKeyValueContainerClass : NSObject

@property (nonatomic, assign) Class originalClass;
@property (nonatomic, assign) void * (*cachedObservationInfoImplementation)(id, SEL);
@property (nonatomic, assign) void (*cachedSetObservationInfoImplementation)(id,SEL,void *);
@property (nonatomic, assign) BOOL cachedSetObservationInfoTakesAnObject;
@property (nonatomic, assign) DSKeyValueNotifyingInfo * notifyingInfo;

- (id)initWithOriginalClass:(Class)originalClass;

@end

