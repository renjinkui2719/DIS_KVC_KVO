//
//  DSKeyValueChangeDictionary.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+DSKeyValueObserverRegistration.h"

@class DSKeyValueObservationInfo;

typedef struct {
    DSKeyValueChange kind;//0
    id oldValue;//4
    id newValue;//8
    NSIndexSet *indexes;//c
    id extraData;//10
}DSKeyValueChangeDetails;

@interface DSKeyValueChangeDictionary : NSDictionary

@property (nonatomic, assign) DSKeyValueChangeDetails details;
@property (nonatomic, strong) id originalObservable;
@property (nonatomic, assign) BOOL isPriorNotification;
@property (nonatomic, assign) BOOL isRetainingObjects;


- (id)initWithDetailsNoCopy:(DSKeyValueChangeDetails)details originalObservable:(id)originalObservable isPriorNotification:(BOOL)isPriorNotification;
- (void)setDetailsNoCopy:(DSKeyValueChangeDetails)details originalObservable:(id)originalObservable;
- (void)setOriginalObservable:(id)originalObservable;
- (void)retainObjects;

@end
