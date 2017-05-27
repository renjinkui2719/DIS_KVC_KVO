//
//  NSObject+DSKeyValueObserverNotification.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/20.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueProperty.h"
#import "DSKeyValueChangeDictionary.h"
#import "DSKeyValueObserverCommon.h"

@class DSKeyValueObservationInfo;
@class DSKeyValueObservance;

@interface NSObject (DSKeyValueObserverNotification)

- (void)d_willChangeValueForKey:(NSString *)key ;
- (void)d_didChangeValueForKey:(NSString *)key;

- (void)d_willChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;
- (void)d_didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;

- (void)d_willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;
- (void)d_didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;

@end


typedef struct {
    //引用计数
    uint16_t retainCount;
    //是否是一次change的起始
    BOOL beginningOfChange;
    
    id object;//4
    id keyOrKeys;//8
    DSKeyValueObservationInfo *observationInfo;//c
    DSKeyValueObservance *observance;//10
    NSKeyValueChange kind;//14
    id oldValue;//18
    id newValue;//1c
    NSIndexSet *indexes;//20
    NSMutableData * extraData;//24
    id changingValue;//28
    NSMutableDictionary *affectingValuesMap;//2c
}DSKVOPendingChangeNotificationPerThread;

typedef struct {
    CFMutableArrayRef pendingArray;//0
    BOOL beginningOfChange;//4
    DSKeyValueObservationInfo *observationInfo;//8
}DSKVOPushInfoPerThread;

typedef struct {
    CFMutableArrayRef pendingArray;//0
    NSUInteger pendingCount;//4
    DSKVOPendingChangeNotificationPerThread * lastPopedNotification;//8
    NSInteger lastPopdIndex;//c
    DSKeyValueObservance * observance;//10
}DSKVOPopInfoPerThread;

typedef union {
    struct {
        NSKeyValueChange changeKind;
        NSIndexSet *indexes;
    };
    struct {
        NSKeyValueSetMutationKind mutationKind;
        NSSet *objects;
    };
}DSKVOCollectionWillChangeInfo;

typedef struct {
    DSKeyValueObservance *observance;
    NSKeyValueChange kind;
    id oldValue;
    id newValue;
    NSIndexSet *indexes;
    NSMutableData * extraData;
    id changingValue;
    NSMutableDictionary * affectingValuesMap;
    //??以下字段无法推断命名及含义，并且在KVO中无作用
    BOOL unknow_1;
    NSString *keyOrKeys;
}DSKVOPendingChangeNotificationLocal;

typedef struct {
    NSUInteger capacity;
    BOOL notificationsInStack;
    DSKVOPendingChangeNotificationLocal *notifications;
    NSUInteger notificationCount;
     //??以下字段无法推断命名及含义，并且在KVO中无作用
    BOOL unknow_1;
    id unknow_2;
}DSKVOPushInfoLocal;

typedef struct {
    DSKVOPendingChangeNotificationLocal *notifications;
    NSUInteger notificationCount;
    id observer;
    id oldValue;
    id lastChangingValue;
    DSKeyValueObservationInfo *observationInfo;
}DSKVOPopInfoLocal;

typedef void (*DSKVOWillChangeDetailSetupFunc)(DSKeyValueChangeDetails *, id, NSString *, BOOL, int, void *, BOOL *);
typedef void (*DSKVOWillChangeNotificationPushFunc)(id, id, DSKeyValueObservance *, DSKeyValueChangeDetails, DSKeyValuePropertyForwardingValues, void *);

typedef void (*DSKVODidChangeDetailSetupFunc)(DSKeyValueChangeDetails *, id , NSString *, BOOL , int , DSKeyValueChangeDetails);
typedef BOOL (*DSKVODidChangeNotificationPopFunc)(id,id,DSKeyValueObservance **, DSKeyValueChangeDetails *, DSKeyValuePropertyForwardingValues *, id *, void *);

void DSKeyValueWillChange(id object, id keyOrKeys, BOOL isASet, DSKeyValueObservationInfo *observationInfo, DSKVOWillChangeDetailSetupFunc willChangeDetailSetupFunc, void *changeInfo, DSKVOWillChangeNotificationPushFunc willChangeNotificationPushFunc, void *pushInfo, DSKeyValueObservance *observance);
void DSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,DSKVODidChangeDetailSetupFunc didChangeDetailSetupFunc, DSKVODidChangeNotificationPopFunc didChangeNotificationPopFunc, void *popInfo);

void DSKeyValueNotifyObserver(id observer,NSString * keyPath, id object, void *context, id originalObservable, BOOL isPriorNotification, DSKeyValueChangeDetails changeDetails, DSKeyValueChangeDictionary **pChange);
void DSKVONotify(id observer, NSString *keyPath, id object, NSDictionary *changeDictionary, void *context);

void DSKeyValueWillChangeForObservance(id object, id keyOrKeys, BOOL keyOrKeysIsASet, DSKeyValueObservance * observance);
void DSKeyValueDidChangeForObservance(id object, id keyOrKeys, BOOL keyOrKeysIsASet, DSKeyValueObservance * observance);

void DSKeyValueWillChangeBySetting(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, NSDictionary *oldValueDict, BOOL *detailsRetained);
void DSKeyValueDidChangeBySetting(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails);
void DSKeyValueWillChangeByOrderedToManyMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOCollectionWillChangeInfo *changeInfo, BOOL *detailsRetained);
void DSKeyValueDidChangeByOrderedToManyMutation(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails);
void DSKeyValueWillChangeBySetMutation(DSKeyValueChangeDetails *changeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKVOCollectionWillChangeInfo *changeInfo, BOOL *detailsRetained);
void DSKeyValueDidChangeBySetMutation(DSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL keyPathExactMatch, int options, DSKeyValueChangeDetails changeDetails);
void DSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPushInfoPerThread *pushInfo);
BOOL DSKeyValuePopPendingNotificationPerThread(id object,id keyOrKeys, DSKeyValueObservance **popedObservance, DSKeyValueChangeDetails *popedChangeDetails,DSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, DSKVOPopInfoPerThread* popInfo) ;
void DSKeyValuePushPendingNotificationLocal(id object, id keyOrKeys, DSKeyValueObservance *observance, DSKeyValueChangeDetails changeDetails , DSKeyValuePropertyForwardingValues forwardingValues, DSKVOPushInfoLocal *pendingInfo);
BOOL DSKeyValuePopPendingNotificationLocal(id object,id keyOrKeys, DSKeyValueObservance **popedObservance, DSKeyValueChangeDetails *popedChangeDetails,DSKeyValuePropertyForwardingValues *popedForwardValues,id *popedKeyOrKeys, DSKVOPopInfoLocal* pendingInfo) ;

static inline NSString * NSStringFromPendingChangeNotificationPerThread(const DSKVOPendingChangeNotificationPerThread *notification) {
    if (!notification) {
        return @"null";
    }
    return [NSString stringWithFormat:
            BRACE(
                  LINE(@"retainCount: %u,")\
                  LINE(@"beginningOfChange: %@,")\
                  LINE(@"object: %@,")\
                  LINE(@"keyOrKeys: %@,")\
                  LINE(@"observationInfo: %@,")\
                  LINE(@"observance: %@,")\
                  LINE(@"kind: 0X%02X,")\
                  LINE(@"oldValue: %@,")\
                  LINE(@"newValue: %@,")\
                  LINE(@"indexes: %@,")\
                  LINE(@"extraData: %@,")\
                  LINE(@"changingValue: %@,")\
                  LINE(@"affectingValuesMap: %@")\
                  ),
            notification->retainCount,
            bool_desc(notification->beginningOfChange),
            simple_desc(notification->object),
            notification->keyOrKeys,
            simple_desc(notification->observationInfo),
            simple_desc(notification->observance),
            (uint8_t)notification->kind,
            simple_desc(notification->oldValue),
            simple_desc(notification->newValue),
            notification->indexes,
            simple_desc(notification->extraData),
            simple_desc(notification->changingValue),
            simple_desc(notification->affectingValuesMap)
            ];
}

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

static inline NSString * NSStringFromPushInfoPerThread(const DSKVOPushInfoPerThread *info) {
    if (!info) {
        return @"null";
    }
    return [NSString stringWithFormat:
            BRACE(
                  LINE(@"pendingArray: (%zd) elems,")\
                  LINE(@"beginningOfChange: %@,")\
                  LINE(@"observationInfo: %@")\
                  ),
            CFArrayGetCount(info->pendingArray),
            bool_desc(info->beginningOfChange),
            simple_desc(info->observationInfo)
            ];
}

