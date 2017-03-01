//
//  NSKeyValueObservance.h
//  KVOIMP
//
//  Created by JK on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueProperty;

@interface NSKeyValueObservance : NSObject
{
    int _options:7;
    int _cachedIsShareable:1;
}

@property (nonatomic, strong) id observer;
@property (nonatomic, strong) NSKeyValueProperty * property;
@property (nonatomic, assign) void * context;
@property (nonatomic, strong) id originalObservable;
@property (nonatomic, assign) int options;
@property (nonatomic, assign) int cachedIsShareable;


- (id)_initWithObserver:(id)observer property:(id)property options:(int)options context:(void *)context originalObservable:(id)originalObservable;

@end

@interface NSKeyValueShareableObservanceKey : NSKeyValueObservance

@end
