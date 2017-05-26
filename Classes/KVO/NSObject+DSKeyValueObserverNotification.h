//
//  NSObject+DSKeyValueObserverNotification.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/20.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueObserverCommon.h"
#import "DSKeyValueChangeDictionary.h"
#import "DSKeyValueProperty.h"
#import "NSObject+DSKeyValueObserverRegistration.h"


@class DSKeyValueObservationInfo;
@class DSKeyValueObservance;

typedef struct {
    uint16_t retainCount;
    BOOL pushAsLastPop;
    id object;//4
    id keyOrKeys;//8
    DSKeyValueObservationInfo *observationInfo;//c
    DSKeyValueObservance *observance;//10
    DSKeyValueChange kind;//14
    id oldValue;//18
    id newValue;//1c
    NSIndexSet *indexes;//20
    NSMutableData * extraData;//24
    id forwardingValues_p1;//28
    id forwardingValues_p2;//2c
}DSKVOPendingChangeNotificationPerThread;

static inline NSString * NSStringFromPendingChangeNotificationPerThread(const DSKVOPendingChangeNotificationPerThread *notification) {
    if (!notification) {
        return @"null";
    }
    return [NSString stringWithFormat:
            BRACE(
                 LINE(@"retainCount: %u,")\
                 LINE(@"pushAsLastPop: %@,")\
                 LINE(@"object: %@,")\
                 LINE(@"keyOrKeys: %@,")\
                 LINE(@"observationInfo: %@,")\
                 LINE(@"observance: %@,")\
                 LINE(@"kind: 0X%02X,")\
                 LINE(@"oldValue: %@,")\
                 LINE(@"newValue: %@,")\
                 LINE(@"indexes: %@,")\
                 LINE(@"extraData: %@,")\
                 LINE(@"forwardingValues_p1: %@,")\
                 LINE(@"forwardingValues_p2: %@")\
                 ),
            notification->retainCount,
            bool_desc(notification->pushAsLastPop),
            simple_desc(notification->object),
            notification->keyOrKeys,
            simple_desc(notification->observationInfo),
            simple_desc(notification->observance),
            (uint8_t)notification->kind,
            simple_desc(notification->oldValue),
            simple_desc(notification->newValue),
            notification->indexes,
            simple_desc(notification->extraData),
            simple_desc(notification->forwardingValues_p1),
            simple_desc(notification->forwardingValues_p2)
        ];
}

typedef struct {
    CFMutableArrayRef pendingArray;//0
    BOOL pushAsLastPop;//4
    DSKeyValueObservationInfo *observationInfo;//8
}DSKVOPushInfoPerThread;

static inline NSString * NSStringFromPushInfoPerThread(const DSKVOPushInfoPerThread *info) {
    if (!info) {
        return @"null";
    }
    return [NSString stringWithFormat:
            BRACE(
                  LINE(@"pendingArray: (%zd) elems,")\
                  LINE(@"pushAsLastPop: %@,")\
                  LINE(@"observationInfo: %@")\
                  ),
            CFArrayGetCount(info->pendingArray),
            bool_desc(info->pushAsLastPop),
            simple_desc(info->observationInfo)
            ];
}

typedef struct {
    CFMutableArrayRef pendingArray;//0
    NSUInteger pendingCount;//4
    DSKVOPendingChangeNotificationPerThread * lastPopedNotification;//8
    NSInteger lastPopdIndex;//c
    DSKeyValueObservance * observance;//10
}DSKVOPopInfoPerThread;

static inline NSString * NSStringFromPopInfoPerThread(const DSKVOPopInfoPerThread *info) {
    if (!info) {
        return @"null";
    }
    return [NSString stringWithFormat:
            BRACE(
                  LINE(@"pendingArray: (%zd) elems,")\
                  LINE(@"pendingCount: %zd,")\
                  LINE(@"lastPopedNotification: %@,")\
                  LINE(@"lastPopdIndex: %zd,")\
                  LINE(@"observance: %@")\
                  ),
            CFArrayGetCount(info->pendingArray),
            info->pendingCount,
            NSStringFromPendingChangeNotificationPerThread(info->lastPopedNotification),
            info->lastPopdIndex,
            simple_desc(info->observance)
            ];
}


typedef union {
    struct {
        DSKeyValueChange changeKind;
        NSIndexSet *indexes;
    };
    struct {
        DSKeyValueSetMutationKind mutationKind;
        NSSet *objects;
    };
}DSKVOArrayOrSetWillChangeInfo;



typedef struct {
    DSKeyValueObservance *observance;//0
    DSKeyValueChange kind;//4
    id oldValue;//8
    id newValue;//c
    NSIndexSet *indexes;//10
    NSMutableData * extraData;//14
    id forwardingValues_p1;//18
    id forwardingValues_p2;//1c
    BOOL p5;//20
    NSString *keyOrKeys;//24
}DSKVOPendingInfoLocalDetail;


typedef struct {
    NSUInteger capacity;//0
    BOOL isStackBuff;//4
    DSKVOPendingInfoLocalDetail *detailsBuff;//8
    NSUInteger detailsCount;//c
    BOOL p5;//10
    id p6;//14
}DSKVOPendingInfoLocalPush;


typedef struct {
    DSKVOPendingInfoLocalDetail *detailsBuff;//0
    NSUInteger detailsCount;//4
    id observer;//8
    id oldValue;//c
    id forwardValues_p1;//10
    DSKeyValueObservationInfo *observationInfo;//14
}DSKVOPendingInfoLocalPop;


typedef void (*DSKeyValueWillChangeByCallback)(DSKeyValueChangeDetails *, id , NSString *, BOOL , int , NSDictionary *, BOOL *);
typedef void (*DSKeyValuePushPendingNotificationCallback)(id , id , DSKeyValueObservance *, DSKeyValueChangeDetails  , DSKeyValuePropertyForwardingValues , void *);

typedef void (*DSKeyValueDidChangeByCallback)(DSKeyValueChangeDetails *, id , NSString *, BOOL , int , DSKeyValueChangeDetails );
typedef BOOL (*DSKeyValuePopPendingNotificationCallback)(id ,id , DSKeyValueObservance **, DSKeyValueChangeDetails *,DSKeyValuePropertyForwardingValues *,id *, void * );

void DSKeyValueWillChange(id object, id keyOrKeys, BOOL isASet, DSKeyValueObservationInfo *observationInfo, DSKeyValueWillChangeByCallback willChangeByCallback, void *changeInfo, DSKeyValuePushPendingNotificationCallback pushPendingNotificationCallback, void *pendingInfo, DSKeyValueObservance *observance) ;
void DSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,DSKeyValueDidChangeByCallback didChangeByCallback, DSKeyValuePopPendingNotificationCallback popPendingNotificationCallback, void *pendingInfo);

void DSKeyValueNotifyObserver(id observer,NSString * keyPath, id object, void *context, id originalObservable, BOOL isPriorNotification, DSKeyValueChangeDetails changeDetails, DSKeyValueChangeDictionary **pChange);
void DSKVONotify(id observer, NSString *keyPath, id object, NSDictionary *changeDictionary, void *context);

void DSKeyValueDidChangeBySetting(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL equal, int options, DSKeyValueChangeDetails changeDetails) ;
BOOL DSKeyValuePopPendingNotificationLocal(id object,id keyOrKeys, DSKeyValueObservance **observance, DSKeyValueChangeDetails *changeDetails,DSKeyValuePropertyForwardingValues *forwardValues,id *findKeyOrKeys, DSKVOPendingInfoLocalPop* pendingInfo);
BOOL DSKeyValuePopPendingNotificationPerThread(id object,id keyOrKeys, DSKeyValueObservance **observance, DSKeyValueChangeDetails *changeDetails,DSKeyValuePropertyForwardingValues *forwardValues,id *findKeyOrKeys, DSKVOPopInfoPerThread* pendingInfo);

void DSKeyValueWillChangeBySetting(DSKeyValueChangeDetails *changeDetails, id object, NSString *affectedKeyPath, BOOL match, int options, NSDictionary *oldValueDict, BOOL *detailsRetained);
void DSKeyValuePushPendingNotificationLocal(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPendingInfoLocalPush *pendingInfo);
void DSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPushInfoPerThread *pendingInfo) ;

BOOL _DSKeyValueCheckObservationInfoForPendingNotification(id object, DSKeyValueObservance *observance, DSKeyValueObservationInfo * observationInfo);
void DSKeyValueWillChangeBySetMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained);
void DSKeyValueWillChangeByOrderedToManyMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained);
void DSKeyValueWillChangeBySetMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOArrayOrSetWillChangeInfo *changeInfo, BOOL *detailsRetained);

void DSKeyValueDidChangeByOrderedToManyMutation(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL exactMatch, int options, DSKeyValueChangeDetails changeDetails);
void DSKeyValueDidChangeBySetMutation(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails);

void DSKeyValueWillChangeForObservance(id object, id keyOrKeys, BOOL keyOrKeysIsASet, DSKeyValueObservance * observance);
void DSKeyValueDidChangeForObservance(id object, id keyOrKeys, BOOL keyOrKeysIsASet, DSKeyValueObservance * observance);

@interface NSObject (DSKeyValueObserverNotification)

- (void)d_willChangeValueForKey:(NSString *)key ;
- (void)d_didChangeValueForKey:(NSString *)key;
- (void)d_willChange:(DSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;
- (void)d_didChange:(DSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;
- (void)d_willChangeValueForKey:(NSString *)key withSetMutation:(DSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;
- (void)d_didChangeValueForKey:(NSString *)key withSetMutation:(DSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;
@end


