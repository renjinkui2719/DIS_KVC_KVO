//
//  NSObject+NSKeyValueObservingPrivate.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueObservance;
@class NSKeyValueProperty;

typedef struct {
    id object;//8
    NSKeyValueObservance *observance;//c
}ImplicitObservanceAdditionInfo;

typedef struct {
    id relationshipObject;//10
    id observer;//14
    NSString *keyPathFromRelatedObject;//18
    id object;//1c
    void *context;//20
    BOOL flag;//24
}ImplicitObservanceRemovalInfo;

typedef struct {
    CFMutableArrayRef pendingArray;//0
    void *unknow1;//4
    ImplicitObservanceAdditionInfo  implicitObservanceAdditionInfo;
    ImplicitObservanceRemovalInfo implicitObservanceRemovalInfo;
}NSKeyValueObservingTSD;

#define NSKeyValueObservingTSDKey 0x15
#define NSKeyValueObservingKeyPathTSDKey 0x20
#define NSKeyValueObservingObjectTSDKey 0x1F

void NSKeyValueObservingTSDDestroy(void *data);
ImplicitObservanceAdditionInfo *NSKeyValueGetImplicitObservanceAdditionInfo();
ImplicitObservanceRemovalInfo *NSKeyValueGetImplicitObservanceRemovalInfo();

extern const CFArrayCallBacks NSKVOPendingNotificationArrayCallbacks;


@interface NSObject (NSKeyValueObservingPrivate)

- (void)_changeValueForKey:(NSString *)key usingBlock:(void (^)())block;
- (void)_changeValueForKey:(NSString *)key1 key:(NSString *)key2 key:(NSString *)key3 usingBlock:(void (^)(void))block;
- (void)_changeValueForKeys:(NSString * *)keys count:(NSUInteger)count maybeOldValuesDict:(id)oldValuesDict usingBlock:(void (^)(void))block;
- (id)_implicitObservationInfo;
- (CFMutableArrayRef)_pendingChangeNotificationsArrayForKey:(NSString *)key create:(BOOL)create;
- (void)_notifyObserversOfChangeFromValuesForKeys:(NSDictionary *)fromValueForKeys toValuesForKeys:(NSDictionary *)toValueForKeys;
- (void)_didChangeValuesForKeys:(id)keys;
- (void)_willChangeValuesForKeys:(id)keys;
+ (BOOL)_shouldAddObservationForwardersForKey:(NSString *)key;

@end
