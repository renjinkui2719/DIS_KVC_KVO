//
//  NSObject+NSKeyValueObservingPrivate.h
//  KV
//
//  Created by renjinkui on 2017/2/18.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueObservance;

typedef struct {
    id object;
    NSKeyValueObservance *observance;
}ImplicitObservanceAdditionInfo;

typedef struct {
    id relationshipObject;
    NSKeyValueObservance *observance;
    NSString *keyPathFromRelatedObject;
    id object;
    NSKeyValueProperty *property;
    BOOL flag;
}ImplicitObservanceRemovalInfo;

typedef struct {
    CFMutableArrayRef pendingArray;
    void *unknow1;
    ImplicitObservanceAdditionInfo  implicitObservanceAdditionInfo;
    ImplicitObservanceRemovalInfo implicitObservanceRemovalInfo;
}NSKeyValueObservingTSD;

#define NSKeyValueObservingTSDKey 0x15

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
