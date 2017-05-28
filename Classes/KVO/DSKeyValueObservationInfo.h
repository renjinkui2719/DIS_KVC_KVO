//
//  DSKeyValueObservationInfo.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>

@class DSKeyValueObservance;
@class DSKeyValueProperty;
@class DSKeyValueContainerClass;
struct ObservationInfoWatcher;

@interface DSKeyValueObservationInfo : NSObject
@property (nonatomic, strong) NSArray<DSKeyValueObservance *> *observances;
@property (nonatomic, assign) NSUInteger cachedHash;
@property (nonatomic, assign) BOOL cachedIsShareable;

- (id)_initWithObservances:(DSKeyValueObservance **)observances count:(NSUInteger)count hashValue:(NSUInteger)hashValue;
- (DSKeyValueObservationInfo *)_copyByAddingObservance:(DSKeyValueObservance *)observance;

@end

@interface DSKeyValueShareableObservationInfoKey : NSObject
@property (nonatomic, assign) BOOL addingNotRemoving;
@property (nonatomic, strong) DSKeyValueObservationInfo *baseObservationInfo;
@property (nonatomic, strong) NSObject *additionObserver;
@property (nonatomic, strong) DSKeyValueProperty *additionProperty;
@property (nonatomic, assign) NSUInteger additionOptions;
@property (nonatomic, assign) void* additionContext;
@property (nonatomic, strong) NSObject* additionOriginalObservable;
@property (nonatomic, strong) DSKeyValueObservance* removalObservance;
@property (nonatomic, assign) NSUInteger removalObservanceIndex;
@property (nonatomic, assign) NSUInteger cachedHash;
@end

extern OSSpinLock DSKeyValueObservationInfoCreationSpinLock;
extern OSSpinLock DSKeyValueObservationInfoSpinLock;

extern NSHashTable *DSKeyValueShareableObservationInfos;
extern Class DSKeyValueShareableObservationInfoKeyIsa;
extern NSHashTable *DSKeyValueShareableObservances;


DSKeyValueObservationInfo *_DSKeyValueObservationInfoCreateByAdding(DSKeyValueObservationInfo *baseObservationInfo, id observer, DSKeyValueProperty *property, int options, void *context, id originalObservable,  BOOL *cacheHit, DSKeyValueObservance **addedObservance);

DSKeyValueObservationInfo *_DSKeyValueObservationInfoCreateByRemoving(DSKeyValueObservationInfo *baseObservationInfo, id observer, DSKeyValueProperty *property, void *context, BOOL shouldCompareContext,  id originalObservable,  BOOL *fromCache, DSKeyValueObservance **pObservance);

void _DSKeyValueReplaceObservationInfoForObject(id object, DSKeyValueContainerClass * containerClass, DSKeyValueObservationInfo *oldObservationInfo, DSKeyValueObservationInfo *newObservationInfo);

NSUInteger _DSKeyValueObservationInfoGetObservanceCount(DSKeyValueObservationInfo *info);

void _DSKeyValueObservationInfoGetObservances(DSKeyValueObservationInfo *info, DSKeyValueObservance *observances[], NSUInteger count);

BOOL _DSKeyValueObservationInfoContainsObservance(DSKeyValueObservationInfo *info, DSKeyValueObservance *observance);

DSKeyValueObservationInfo *_DSKeyValueRetainedObservationInfoForObject(id object, DSKeyValueContainerClass *containerClass);

void _DSKeyValueAddObservationInfoWatcher(struct ObservationInfoWatcher * watcher);
void _DSKeyValueRemoveObservationInfoWatcher(struct ObservationInfoWatcher * watcher);
void _DSKeyValueRemoveObservationInfoForObject(id object, DSKeyValueObservationInfo *observationInfo);

