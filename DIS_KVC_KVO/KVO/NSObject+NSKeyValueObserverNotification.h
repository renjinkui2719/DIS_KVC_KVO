//
//  NSObject+NSKeyValueObserverNotification.h
//  KV
//
//  Created by renjinkui on 2017/2/20.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSKeyValueChangeDictionary.h"
#import "NSKeyValueProperty.h"

@class NSKeyValueObservationInfo;
@class NSKeyValueObservance;

typedef struct {
    uint16_t unknow1:16;
    uint16_t unknow2:16;
    id object;//4
    id keyOrKeys;//8
    NSKeyValueObservationInfo *observationInfo;//c
    NSKeyValueObservance *observance;//10
    NSKeyValueChange kind;//14
    id oldValue;//18
    id newValue;//1c
    NSIndexSet *indexes;//20
    id changeDetails_unknow1;//24
    id forwardingValues_p1;//28
    id forwardingValues_p2;//2c
}NSKVOPendingNotification;

typedef struct {
    CFMutableArrayRef pendingArray;
    NSUInteger count;
    NSKeyValueObservationInfo *observationInfo;
    NSUInteger index;
    NSKeyValueObservance *observance;
}NSKVOPendingInfoPerThreadPush;

typedef struct {
    CFMutableArrayRef pendingArray;
    NSUInteger count;
    NSKVOPendingNotification * notification;
    NSUInteger index;
    NSKeyValueObservance * observance;
}NSKVOPendingInfoPerThreadPop;

typedef struct {
    NSUInteger capacity;//0
    BOOL isStackBuff;//4
    void *detailsBuff;//8
    NSUInteger count;//c
    BOOL p5;//10
    id p6;//14
}NSKVOPendingInfoLocalPush;

typedef struct {
    void *detailsBuff;//0
    NSUInteger count;//4
    id observer;//8
    id oldValue;//c
    id forwardValues_p1;//10
    NSKeyValueObservationInfo *observationInfo;//14
}NSKVOPendingInfoLocalPop;

typedef void (*NSKeyValueWillChangeByCallback)(NSKeyValueChangeDetails *, id , NSString *, BOOL , int , NSDictionary *, BOOL *);
typedef void (*NSKeyValuePushPendingNotificationCallback)(id , id , NSKeyValueObservance *, NSKeyValueChangeDetails  , NSKeyValuePropertyForwardingValues , void *);

typedef void (*NSKeyValueDidChangeByCallback)(NSKeyValueChangeDetails *, id , NSString *, BOOL , int , NSKeyValueChangeDetails );
typedef BOOL (*NSKeyValuePopPendingNotificationCallback)(id ,id , NSKeyValueObservance **, NSKeyValueChangeDetails *,NSKeyValuePropertyForwardingValues *,id *, void * );

void NSKeyValueWillChange(id object, id keyOrKeys, BOOL isASet, NSKeyValueObservationInfo *observationInfo, NSKeyValueWillChangeByCallback willChangeByCallback, NSDictionary *oldValueDict, NSKeyValuePushPendingNotificationCallback pushPendingNotificationCallback, void *pendingInfo, NSKeyValueObservance *observance) ;
void NSKeyValueDidChange(id object, id keyOrKeys, BOOL isASet,NSKeyValueDidChangeByCallback didChangeByCallback, NSKeyValuePopPendingNotificationCallback popPendingNotificationCallback, void *pendingInfo);

void NSKeyValueNotifyObserver(id observer,NSString * keyPath, id object, void *context, id originalObservable, BOOL isPriorNotification, NSKeyValueChangeDetails changeDetails, NSKeyValueChangeDictionary **pChange);

void NSKeyValueDidChangeBySetting(NSKeyValueChangeDetails *resultChangeDetails, id object, NSString *keyPath, BOOL equal, int options, NSKeyValueChangeDetails changeDetails) ;
BOOL NSKeyValuePopPendingNotificationLocal(id object,id keyOrKeys, NSKeyValueObservance **observance, NSKeyValueChangeDetails *changeDetails,NSKeyValuePropertyForwardingValues *forwardValues,id *findKeyOrKeys, NSKVOPendingInfoLocalPop* pendingInfo);
BOOL NSKeyValuePopPendingNotificationPerThread(id object,id keyOrKeys, NSKeyValueObservance **observance, NSKeyValueChangeDetails *changeDetails,NSKeyValuePropertyForwardingValues *forwardValues,id *findKeyOrKeys, NSKVOPendingInfoPerThreadPop* pendingInfo);

void NSKeyValueWillChangeBySetting(NSKeyValueChangeDetails *changeDetails, id object, NSString *affectedKeyPath, BOOL match, int options, NSDictionary *oldValueDict, BOOL *detailsRetained);
void NSKeyValuePushPendingNotificationLocal(id object, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueChangeDetails changeDetails , NSKeyValuePropertyForwardingValues forwardingValues, NSKVOPendingInfoLocalPush *pendingInfo);
void NSKeyValuePushPendingNotificationPerThread(id object, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueChangeDetails changeDetails , NSKeyValuePropertyForwardingValues forwardingValues, NSKVOPendingInfoPerThreadPush *pendingInfo) ;

@interface NSObject (NSKeyValueObserverNotification)

@end


