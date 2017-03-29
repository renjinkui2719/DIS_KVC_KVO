//
//  NSKeyValueObservationInfo.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#ifndef NSKeyValueObservationInfo_h
#define NSKeyValueObservationInfo_h

#import <Foundation/Foundation.h>

@class NSKeyValueObservance;
@class NSKeyValueProperty;
@class NSKeyValueContainerClass;

@interface NSKeyValueObservationInfo : NSObject
@property (nonatomic, strong) NSArray<NSKeyValueObservance *> *observances;
@property (nonatomic, assign) NSUInteger cachedHash;
@property (nonatomic, assign) BOOL cachedIsShareable;

- (id)_initWithObservances:(NSKeyValueObservance **)observances count:(NSUInteger)count hashValue:(NSUInteger)hashValue;
- (NSKeyValueObservationInfo *)_copyByAddingObservance:(NSKeyValueObservance *)observance;

@end

@interface NSKeyValueShareableObservationInfoKey : NSObject
@property (nonatomic, assign) BOOL addingNotRemoving;
@property (nonatomic, strong) NSKeyValueObservationInfo *baseObservationInfo;
@property (nonatomic, strong) NSObject *additionObserver;
@property (nonatomic, strong) NSKeyValueProperty *additionProperty;
@property (nonatomic, assign) NSUInteger additionOptions;
@property (nonatomic, assign) void* additionContext;
@property (nonatomic, strong) NSObject* additionOriginalObservable;
@property (nonatomic, strong) NSKeyValueObservance* removalObservance;
@property (nonatomic, assign) NSUInteger removalObservanceIndex;
@property (nonatomic, assign) NSUInteger cachedHash;
@end

NSKeyValueObservationInfo *_NSKeyValueObservationInfoCreateByAdding(NSKeyValueObservationInfo *baseObservationInfo, id observer, NSKeyValueProperty *property, int options, void *context, id originalObservable,  BOOL *flag, NSKeyValueObservance **pObservance);
NSKeyValueObservationInfo *_NSKeyValueObservationInfoCreateByRemoving(NSKeyValueObservationInfo *baseObservationInfo, id observer, NSKeyValueProperty *property, void *context, int options,  id originalObservable,  BOOL *fromCache, NSKeyValueObservance **pObservance);
void _NSKeyValueReplaceObservationInfoForObject(id object, NSKeyValueContainerClass * containerClass, NSKeyValueObservationInfo *oldObservationInfo, NSKeyValueObservationInfo *newObservationInfo, void *unknowparam);
NSUInteger _NSKeyValueObservationInfoGetObservanceCount(NSKeyValueObservationInfo *info) ;
void _NSKeyValueObservationInfoGetObservances(NSKeyValueObservationInfo *info, NSKeyValueObservance *observances[], NSUInteger count) ;
BOOL _NSKeyValueObservationInfoContainsObservance(NSKeyValueObservationInfo *info, NSKeyValueObservance *observance);

#endif /* NSKeyValueObservationInfo_h */



