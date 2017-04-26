#import "DSKeyValueObservationInfo.h"
#import "DSKeyValueObservance.h"
#import "DSKeyValueContainerClass.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "DSKeyValueCodingCommon.h"
#import "DSKeyValueObserverCommon.h"

OSSpinLock DSKeyValueObservationInfoCreationSpinLock;
OSSpinLock DSKeyValueObservationInfoSpinLock;

NSHashTable *DSKeyValueShareableObservationInfos;
Class DSKeyValueShareableObservationInfoKeyIsa;
NSHashTable *DSKeyValueShareableObservances;


@implementation DSKeyValueObservationInfo

- (id)_initWithObservances:(DSKeyValueObservance **)observances count:(NSUInteger)count hashValue:(NSUInteger)hashValue {
    if (self = [super init]) {
        _observances = [[NSArray alloc] initWithObjects:observances count:count];
        _cachedHash = hashValue;
        _cachedIsShareable  = YES;

        if (_cachedHash != 0) {
            for (NSUInteger i = 0; i < count; ++i) {
                DSKeyValueObservance *observance = observances[i];
                if (!observance.cachedIsShareable) {
                    _cachedIsShareable = NO;
                }
            }
        }
        else {
            for (NSUInteger i = 0; i < count; ++i) {
                DSKeyValueObservance *observance = observances[i];
                NSUInteger hash = _NSKVOPointersHash(4, (void *)observance.observer, (void *)observance.property,(void *)observance.context,(void *)observance.originalObservable);
                _cachedHash = (hash << (i & 0x1F)) | (hash >> (i & 0x1F));
                if (!observance.cachedIsShareable) {
                    _cachedIsShareable = NO;
                }
            }
        }
    }
    return self;
}

- (DSKeyValueObservationInfo *)_copyByAddingObservance:(DSKeyValueObservance *)observance {

    DSKeyValueObservationInfo *copied = [[DSKeyValueObservationInfo alloc] init];

    NSUInteger hash = _DSKVOPointersHash(4, (void *)observance.observer, (void *)observance.property,  (void *)_observances.count, (void *)observance.context);

    unsigned char shift = (_observances.count & 0x1F);
    copied.cachedHash = (hash >> shift | hash << shift) ^ _cachedHash;
    
    NSUInteger result_count = _observances.count + 1;

    if (((NSInteger)result_count) < 0) {
        [NSException raise:NSGenericException format:@"*** attempt to create a temporary id buffer which is too large or with a negative count (%lu) -- possibly data is corrupt",(NSUInteger)result_count];
    }
    else {
        if (result_count == 0) {
            result_count = 1;
        }
        if (result_count > 256) {
            DSKeyValueObservance **observance_objs = (DSKeyValueObservance **)NSAllocateObjectArray(result_count);
            if (!observance_objs) {
                [NSException raise:NSMallocException format:@"*** attempt to create a temporary id buffer of length (%lu) failed",(NSUInteger)result_count];
            }
            observance_objs[_observances.count] = observance;
            [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
            copied.observances = [[NSArray alloc] initWithObjects:observance_objs count:result_count];
            NSFreeObjectArray(observance_objs);
        }
        else {
            DSKeyValueObservance *observance_objs[result_count];
            memset(observance_objs, 0, result_count);
            observance_objs[_observances.count] = observance;
            [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
            copied.observances = [[NSArray alloc] initWithObjects:observance_objs count:result_count];
        }
        
        copied.cachedIsShareable = _cachedIsShareable;
    }
    
    return copied;
}

- (NSUInteger)hash {
    return _cachedHash;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }

    if (![object isKindOfClass: self.class]) {
        return NO;
    }

    DSKeyValueObservationInfo *other = (DSKeyValueObservationInfo *)object;
    if(_observances.count != other.observances.count) {
        return NO;
    }
    
    DSKeyValueObservance *observance_objs[_observances.count];
    [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
    DSKeyValueObservance *other_observance_objs[_observances.count];
    [other.observances getObjects:other_observance_objs range:NSMakeRange(0, _observances.count)];
    
    for (NSUInteger i=0; i<_observances.count; ++i) {
        DSKeyValueObservance *observance = observance_objs[i];
        DSKeyValueObservance *other_observance = observance_objs[i];
        if (observance != other_observance) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@ %p> (\n", self.class, self];
    DSKeyValueObservance *observance_objs[_observances.count];
    [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
    for (NSUInteger i = 0 ;i < _observances.count; ++i) {
        DSKeyValueObservance *observance = observance_objs[i];
        [desc appendString:observance.description];
        [desc appendString:@"\n"];
    }
    [desc appendString:@")"];

    return desc;
}

@end

@implementation DSKeyValueShareableObservationInfoKey

@end



NSUInteger DSKeyValueShareableObservationInfoNSHTHash(const void * item, NSUInteger (* size)(const void * item)) {
    DSKeyValueShareableObservationInfoKey *infoKey = (DSKeyValueShareableObservationInfoKey *)item;
    if(infoKey.class == DSKeyValueShareableObservationInfoKeyIsa) {
        if(infoKey.addingNotRemoving) {
            NSUInteger count = 0;
            if(infoKey.baseObservationInfo) {
                count = CFArrayGetCount((CFArrayRef)infoKey.baseObservationInfo.observances);
                count &= 0x1F;
            }
            NSUInteger hashValue =  _NSKVOPointersHash(4,infoKey.additionObserver,infoKey.additionProperty, infoKey.additionContext, infoKey.additionOriginalObservable);
            hashValue = (hashValue << count) | (hashValue >> count);
            hashValue ^= (infoKey.baseObservationInfo ? infoKey.baseObservationInfo.cachedHash : 0);
            return hashValue;
        }
        else {
            if(infoKey.cachedHash == 0) {
                NSUInteger count = CFArrayGetCount((CFArrayRef)infoKey.baseObservationInfo.observances);
                DSKeyValueObservance *observance_objs[count];
                [infoKey.baseObservationInfo.observances getObjects:observance_objs range:NSMakeRange(0, count)];
                NSUInteger hashValue = 0;
                for (NSUInteger i = 0; i < count; ++i) {
                    if (i != infoKey.removalObservanceIndex) {
                        DSKeyValueObservance *observance = observance_objs[i];
                        NSUInteger hash =  _NSKVOPointersHash(4,observance.observer,observance.property, observance.context, observance.originalObservable);
                        hash = (hash << (i & 0x1f)) | (hash >> (i & 0x1f));
                        hash ^= hashValue;
                        hashValue = hash;
                    }
                }
                return hashValue;
            }
            else {
                return infoKey.cachedHash;
            }
        }
    }
    else {
        return ((DSKeyValueObservationInfo *)item).cachedHash;
    }
}

BOOL DSKeyValueShareableObservationInfoNSHTIsEqual(const void * item1, const void * item2, NSUInteger (* size)(const void * item)) {
    if(item1 == item2) {
        return YES;
    }
    if(object_getClass((id)item1) == DSKeyValueShareableObservationInfoKeyIsa || object_getClass((id)item1) == DSKeyValueShareableObservationInfoKeyIsa) {
        DSKeyValueObservationInfo *info = nil;
        DSKeyValueShareableObservationInfoKey *key = nil;
        if (object_getClass((id)item1) == DSKeyValueShareableObservationInfoKeyIsa) {
            info = (DSKeyValueObservationInfo *)item2;
            key = (DSKeyValueShareableObservationInfoKey *)item1;
        }
        else {
            info = (DSKeyValueObservationInfo *)item1;
            key = (DSKeyValueShareableObservationInfoKey *)item2;
        }
        
        if(key.addingNotRemoving) {
            NSUInteger observance_count_inkey = 0;
            NSUInteger observance_count = info.observances.count;
            if(key.baseObservationInfo) {
                observance_count_inkey = key.baseObservationInfo.observances.count;
            }
            if(observance_count == observance_count_inkey + 1) {
                DSKeyValueObservance * observance_objs_inkey[observance_count_inkey];
                if(key.baseObservationInfo) {
                    [key.baseObservationInfo.observances getObjects:observance_objs_inkey range:NSMakeRange(0, observance_count_inkey)];
                }

                DSKeyValueObservance * observance_objs[observance_count];
                [info.observances getObjects:observance_objs range:NSMakeRange(0, observance_count)];
                
                for (NSUInteger i = 0; i < observance_count_inkey; ++i) {
                    if (observance_objs_inkey[i] != observance_objs[i]) {
                        return NO;
                    }
                }
   
                if(observance_objs[observance_count_inkey].property != key.additionProperty) {
                    return NO;
                }
                if(observance_objs[observance_count_inkey].options != key.additionOptions) {
                    return NO;
                }
                if(observance_objs[observance_count_inkey].context != key.additionContext) {
                    return NO;
                }
                if(observance_objs[observance_count_inkey].originalObservable != key.additionOriginalObservable) {
                    return NO;
                }
                if(observance_objs[observance_count_inkey].observer != key.additionObserver) {
                    return NO;
                }
                
                return YES;
            }
            else {
                return NO;
            }
        }
        else {
            NSUInteger observance_count_inkey = CFArrayGetCount(( CFArrayRef)key.baseObservationInfo.observances);
            NSUInteger observance_count = CFArrayGetCount(( CFArrayRef)info.observances);
            if(observance_count_inkey - 1 != observance_count) {
                return NO;
            }
            
            DSKeyValueObservance * observance_objs_inkey[observance_count_inkey];
            [key.baseObservationInfo.observances getObjects:observance_objs_inkey range:NSMakeRange(0, observance_count_inkey)];
            
            DSKeyValueObservance * observance_objs[observance_count];
            [info.observances getObjects:observance_objs range:NSMakeRange(0, observance_count)];
            
            for (NSUInteger i = 0; i < key.removalObservanceIndex; ++i) {
                if(observance_objs_inkey[i] != observance_objs[i]) {
                    return NO;
                }
            }
            
            NSUInteger leftCount = observance_count_inkey - (key.removalObservanceIndex + 1);
            if(leftCount == 0) {
                return YES;
            }
            else {
                DSKeyValueObservance * *  p_observance_objs = &observance_objs[key.removalObservanceIndex];
                DSKeyValueObservance * *  p_observance_objs_inkey = &observance_objs_inkey[key.removalObservanceIndex + 1];
                for (NSUInteger i = 0; i < leftCount; ++i) {
                    if(p_observance_objs[i] != p_observance_objs_inkey[i]) {
                        return NO;
                    }
                }
                
                return YES;
            }
        }
    }
    else {
        DSKeyValueObservationInfo *info1 = (DSKeyValueObservationInfo *)item1;
        DSKeyValueObservationInfo *info2 = (DSKeyValueObservationInfo *)item2;
        NSUInteger info1_observance_count = CFArrayGetCount((CFArrayRef)info1.observances);
        NSUInteger info2_observance_count = CFArrayGetCount((CFArrayRef)info2.observances);
        if(info1_observance_count != info2_observance_count) {
            return NO;
        }
        
        DSKeyValueObservance * info1_observance_objs[info1_observance_count];
        [info1.observances getObjects:info1_observance_objs range:NSMakeRange(0, info1_observance_count)];
        DSKeyValueObservance * info2_observance_objs[info2_observance_count];
        [info1.observances getObjects:info2_observance_objs range:NSMakeRange(0, info2_observance_count)];
        
        if(info1_observance_count == 0) {
            return  YES;
        }
        else {
            for (NSUInteger i = 0; i < info1_observance_count; ++i) {
                if(info1_observance_objs[i] != info2_observance_objs[i]) {
                    return NO;
                }
            }
            return YES;
        }
    }
}

DSKeyValueObservationInfo *_DSKeyValueObservationInfoCreateByAdding(DSKeyValueObservationInfo *baseObservationInfo, id observer, DSKeyValueProperty *property, int options, void *context, id originalObservable,  BOOL *fromCache, DSKeyValueObservance **pObservance) {
    DSKeyValueObservationInfo *createdObservationInfo = nil;
    
    os_lock_lock(&DSKeyValueObservationInfoCreationSpinLock);
    
    if(!DSKeyValueShareableObservationInfos) {
        NSPointerFunctions *pointerFunctions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
        [pointerFunctions setHashFunction:DSKeyValueShareableObservationInfoNSHTHash];
        [pointerFunctions setIsEqualFunction:DSKeyValueShareableObservationInfoNSHTIsEqual];
        DSKeyValueShareableObservationInfos = [[NSHashTable alloc] initWithPointerFunctions:pointerFunctions capacity:0];
    }
    if(!DSKeyValueShareableObservationInfoKeyIsa) {
        DSKeyValueShareableObservationInfoKeyIsa = [DSKeyValueShareableObservationInfoKey class];
    }
    
    static DSKeyValueShareableObservationInfoKey * shareableObservationInfoKey;
    static DSKeyValueShareableObservanceKey *shareableObservanceKey;
    
    if(!shareableObservationInfoKey) {
        shareableObservationInfoKey = [[DSKeyValueShareableObservationInfoKey alloc] init];
    }
    shareableObservationInfoKey.addingNotRemoving = YES;
    shareableObservationInfoKey.baseObservationInfo = baseObservationInfo;
    shareableObservationInfoKey.additionObserver = observer;
    shareableObservationInfoKey.additionProperty = property;
    shareableObservationInfoKey.additionOptions = options;
    shareableObservationInfoKey.additionContext = context;
    shareableObservationInfoKey.additionOriginalObservable = originalObservable;
    DSKeyValueObservationInfo * existsObservationInfo = [DSKeyValueShareableObservationInfos member:shareableObservationInfoKey];
    shareableObservationInfoKey.additionOriginalObservable = nil;
    shareableObservationInfoKey.additionObserver = nil;
    shareableObservationInfoKey.baseObservationInfo = nil;
    if(!existsObservationInfo) {
        if(!DSKeyValueShareableObservances) {
            DSKeyValueShareableObservances = [NSHashTable weakObjectsHashTable];
        }
        if(!shareableObservanceKey) {
            shareableObservanceKey = [[DSKeyValueShareableObservanceKey alloc] init];
        }
        shareableObservanceKey.observer = observer;
        shareableObservanceKey.property = property;
        shareableObservanceKey.options = options;
        shareableObservanceKey.context = context;
        shareableObservanceKey.originalObservable = originalObservable;
        DSKeyValueObservance *existsObservance = [DSKeyValueShareableObservances member:shareableObservanceKey];
        shareableObservanceKey.originalObservable = nil;
        shareableObservanceKey.observer = nil;
        DSKeyValueObservance *observance = nil;
        if (!existsObservance) {
            observance = [[DSKeyValueObservance alloc] _initWithObserver:observer property:property options:options context:context originalObservable:originalObservable];
            if(observance.cachedIsShareable) {
                [DSKeyValueShareableObservances addObject:observance];
            }
        }
        else {
            observance = existsObservance;
        }
        
        if(baseObservationInfo) {
            createdObservationInfo = [baseObservationInfo _copyByAddingObservance:observance];
        }
        else {
            createdObservationInfo = [[DSKeyValueObservationInfo alloc] _initWithObservances:&observance count:1 hashValue:0];
        }
        
        if(createdObservationInfo.cachedIsShareable){
            [DSKeyValueShareableObservationInfos addObject:createdObservationInfo];
        }
        
        *fromCache = NO;
        *pObservance = observance;
    }
    else {
        *fromCache = YES;
        *pObservance = existsObservationInfo.observances.lastObject;
        createdObservationInfo = existsObservationInfo;
    }
    
    os_lock_unlock(&DSKeyValueObservationInfoCreationSpinLock);
    
    return createdObservationInfo;
}

DSKeyValueObservationInfo *_DSKeyValueObservationInfoCreateByRemoving(DSKeyValueObservationInfo *baseObservationInfo, id observer, DSKeyValueProperty *property, void *context, BOOL flag,  id originalObservable,  BOOL *fromCache, DDSKeyValueObservance **pObservance) {
    NSUInteger observanceCount = CFArrayGetCount((CFArrayRef)baseObservationInfo.observances);
    DSKeyValueObservance *observancesBuff[observanceCount];
    CFArrayGetValues((CFArrayRef)baseObservationInfo.observances, CFRangeMake(0, observanceCount), (const void**)observancesBuff);
    
    NSUInteger observanceIndex = NSNotFound;
    for (NSInteger i = observanceCount - 1; i >= 0; --i) {
        DSKeyValueObservance *observance = observancesBuff[i];
        if (observance.property == property && observance.observer == observer) {
            if (!flag || observance.context == context) {
                if (!originalObservable || observance.originalObservable == originalObservable) {
                    //loc_5A4C1
                    *pObservance = observance;
                    observanceIndex = i;
                    //loc_5A4C6
                    break;
                }
            }
        }
    }//for
    //loc_5A4AA
    
    //loc_5A4AA
    if (*pObservance) {
        //loc_5A4C6
        if (observanceCount >= 2) {
            os_lock_lock(&DSKeyValueObservationInfoCreationSpinLock);
            if (!DSKeyValueShareableObservationInfos) {
                NSPointerFunctions *functions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
                [functions setHashFunction:DSKeyValueShareableObservationInfoNSHTHash];
                [functions setIsEqualFunction:DSKeyValueShareableObservationInfoNSHTIsEqual];
                
                DSKeyValueShareableObservationInfos = [[NSHashTable alloc] initWithPointerFunctions:functions capacity:0];
                
                [functions release];
            }
            //loc_5A596
            if (!DSKeyValueShareableObservationInfoKeyIsa) {
                DSKeyValueShareableObservationInfoKeyIsa = DSKeyValueShareableObservationInfoKey.self;
            }
            //loc_5A5BC
            
            static DSKeyValueShareableObservationInfoKey * shareableObservationInfoKey = nil;
            if (!shareableObservationInfoKey) {
                shareableObservationInfoKey = [[DSKeyValueShareableObservationInfoKey alloc] init];
            }
            
            //loc_5A5F5
            shareableObservationInfoKey.addingNotRemoving = NO;
            shareableObservationInfoKey.baseObservationInfo = baseObservationInfo;
            shareableObservationInfoKey.removalObservance = *pObservance;
            shareableObservationInfoKey.removalObservanceIndex = observanceIndex;
            shareableObservationInfoKey.cachedHash = DSKeyValueShareableObservationInfoNSHTHash(shareableObservationInfoKey, NULL);
            
            DSKeyValueObservationInfo *observationInfo = [DSKeyValueShareableObservationInfos member:shareableObservationInfoKey];
            
            shareableObservationInfoKey.removalObservance = nil;
            shareableObservationInfoKey.baseObservationInfo = nil;
            NSUInteger cachedHash = shareableObservationInfoKey.cachedHash;
            shareableObservationInfoKey.cachedHash = 0;
            
            if (!observationInfo) {
                memmove(observancesBuff + observanceIndex, observancesBuff + observanceIndex + 1, observanceCount - (observanceIndex + 1));
                observationInfo = [[DSKeyValueObservationInfo alloc] _initWithObservances:observancesBuff count:observanceCount - 1 hashValue:cachedHash];
                if (observationInfo.cachedIsShareable) {
                    [DSKeyValueShareableObservationInfos addObject:observationInfo];
                }
                *fromCache = NO;
            }
            else {
                *fromCache = YES;
                [observationInfo retain];
            }
            
            os_lock_unlock(&DSKeyValueObservationInfoCreationSpinLock);
            return observationInfo;
        }
        else {
            //loc_5A6A8
            *fromCache = YES;
        }
    }
    
    return nil;
}

void _DSKeyValueReplaceObservationInfoForObject(id object, DSKeyValueContainerClass * containerClass, DSKeyValueObservationInfo *oldObservationInfo, DSKeyValueObservationInfo *newObservationInfo) {
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    if (newObservationInfo) {
        [newObservationInfo retain];
    }
    
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if(TSD) {
        ObservationInfoWatcher *watcher = TSD->firstWatcher;
        while(watcher) {
            if (watcher->object == object) {
                [watcher->observationInfo release];
                watcher->observationInfo = [newObservationInfo retain];
                break;
            }
            watcher = watcher->next;
        }
    }
    if(containerClass) {
        containerClass.cachedSetObservationInfoImplementation(object, @selector(setObservationInfo:), newObservationInfo);
    }
    else {
        [object setObservationInfo: newObservationInfo];
    }
    
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
}

void *_DSKeyValueCreateImplicitObservationInfo() {
    return NULL;
}

NSUInteger _DSKeyValueObservationInfoGetObservanceCount(DSKeyValueObservationInfo *info) {
    return info.observances.count;
}

void _DSKeyValueObservationInfoGetObservances(DSKeyValueObservationInfo *info, DSKeyValueObservance *observances[], NSUInteger count) {
    [info.observances getObjects:observances range:NSMakeRange(0, count)];
}

BOOL _DSKeyValueObservationInfoContainsObservance(DSKeyValueObservationInfo *info, DSKeyValueObservance *observance) {
    return [info.observances containsObject:observance];
}
