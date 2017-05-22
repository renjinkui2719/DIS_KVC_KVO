//
//  DSKeyValueObservance.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DSKeyValueProperty;

@interface DSKeyValueObservance : NSObject
{
    int _options:7;
    int _cachedIsShareable:1;
}

@property (nonatomic, strong) id observer;
@property (nonatomic, strong) DSKeyValueProperty * property;
@property (nonatomic, assign) void * context;
@property (nonatomic, strong) id originalObservable;
@property (nonatomic, assign) int options;
@property (nonatomic, assign) int cachedIsShareable;

- (id)_initWithObserver:(id)observer property:(DSKeyValueProperty *)property options:(int)options context:(void *)context originalObservable:(id)originalObservable;

@end

@interface DSKeyValueShareableObservanceKey : DSKeyValueObservance

@end
