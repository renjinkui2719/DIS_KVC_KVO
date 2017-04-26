//
//  NSObject+DSKeyValueObserverRegistration.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DSKeyValueObservingOptions) {
    DSKeyValueObservingOptionNew = 0x01,
    DSKeyValueObservingOptionOld = 0x02,
    DSKeyValueObservingOptionInitial = 0x04,
    DSKeyValueObservingOptionPrior = 0x08
};

typedef NS_ENUM(NSUInteger, DSKeyValueChange) {
    DSKeyValueChangeSetting = 1,
    DSKeyValueChangeInsertion = 2,
    DSKeyValueChangeRemoval = 3,
    DSKeyValueChangeReplacement = 4,
};

typedef NS_ENUM(NSUInteger, DSKeyValueSetMutationKind) {
    DSKeyValueUnionSetMutation = 1,
    DSKeyValueMinusSetMutation = 2,
    DSKeyValueIntersectSetMutation = 3,
    DSKeyValueSetSetMutation = 4
};

extern NSString *const DSKeyValueChangeKindKey;
extern NSString *const DSKeyValueChangeNewKey;
extern NSString *const DSKeyValueChangeOldKey;
extern NSString *const DSKeyValueChangeIndexesKey;
extern NSString *const DSKeyValueChangeNotificationIsPriorKey;
extern NSString *const DSKeyValueChangeOriginalObservableKey;

@class DSKeyValueProperty;

@interface NSObject (DSKeyValueObserverRegistration)

- (void)d_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(DSKeyValueObservingOptions)options context:(nullable void *)context;
- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;
- (void)d_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

- (void)_d_addObserver:(id)observer forProperty:(DSKeyValueProperty *)property options:(int)options context:(void *)context;
- (void)_d_removeObserver:(id)observer forProperty:(DSKeyValueProperty *)property;
@end


