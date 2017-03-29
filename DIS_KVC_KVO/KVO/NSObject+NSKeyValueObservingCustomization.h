//
//  NSObject+NSKeyValueObservingCustomization.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/25.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CFMutableDictionaryRef NSKeyValueObservationInfoPerObject;
extern CFMutableDictionaryRef NSKeyValueOldStyleDependenciesByClass;

extern OSSpinLock NSKeyValueOldStyleDependenciesSpinLock;

@interface NSObject (NSKeyValueObservingCustomization)

- (void *)observationInfo;
- (void)setObservationInfo:(void *)info ;
+ (id)keyPathsForValuesAffectingValueForKey:(NSString *)key;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;

@end
