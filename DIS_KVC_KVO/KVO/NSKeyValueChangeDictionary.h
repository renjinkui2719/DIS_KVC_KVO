//
//  NSKeyValueChangeDictionary.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueObservationInfo;

typedef struct {
    NSKeyValueChange kind;//0
    id oldValue;//4
    id newValue;//8
    NSIndexSet *indexes;//c
    NSKeyValueObservationInfo * observationInfo;
}NSKeyValueChangeDetails;

@interface NSKeyValueChangeDictionary : NSDictionary

@property (nonatomic, assign) NSKeyValueChangeDetails details;
@property (nonatomic, strong) id originalObservable;
@property (nonatomic, assign) BOOL isPriorNotification;
@property (nonatomic, assign) BOOL isRetainingObjects;


- (id)initWithDetailsNoCopy:(NSKeyValueChangeDetails)details originalObservable:(id)originalObservable isPriorNotification:(BOOL)isPriorNotification;
- (void)setDetailsNoCopy:(NSKeyValueChangeDetails)details originalObservable:(id)originalObservable;
- (void)setOriginalObservable:(id)originalObservable;
- (void)retainObjects;

@end
