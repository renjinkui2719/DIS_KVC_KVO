#import "NSKeyValueObservationInfo.h"
#import "NSKeyValueObservance.h"
#import "NSKeyValueContainerClass.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import "NSKeyValueCodingCommon.h"
#import "NSKeyValueObserverCommon.h"
#import <objc/runtime.h>


@implementation NSKeyValueObservationInfo

- (id)_initWithObservances:(NSKeyValueObservance **)observances count:(NSUInteger)count hashValue:(NSUInteger)hashValue {
    if (self = [super init]) {
        _observances = [[NSArray alloc] initWithObjects:observances count:count];
        _cachedHash = hashValue;
        _cachedIsShareable  = YES;

        if (_cachedHash != 0) {
            for (NSUInteger i = 0; i < count; ++i) {
                NSKeyValueObservance *observance = observances[i];
                if (!observance.cachedIsShareable) {
                    _cachedIsShareable = NO;
                }
            }
        }
        else {
            for (NSUInteger i = 0; i < count; ++i) {
                NSKeyValueObservance *observance = observances[i];
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

- (NSKeyValueObservationInfo *)_copyByAddingObservance:(NSKeyValueObservance *)observance {

    NSKeyValueObservationInfo *copied = [[NSKeyValueObservationInfo alloc] init];

    NSUInteger hash = _NSKVOPointersHash(4, (void *)observance.observer, (void *)observance.property,  (void *)_observances.count, (void *)observance.context);

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
            NSKeyValueObservance **observance_objs = (NSKeyValueObservance **)NSAllocateObjectArray(result_count);
            if (!observance_objs) {
                [NSException raise:NSMallocException format:@"*** attempt to create a temporary id buffer of length (%lu) failed",(NSUInteger)result_count];
            }
            observance_objs[_observances.count] = observance;
            [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
            copied.observances = [[NSArray alloc] initWithObjects:observance_objs count:result_count];
            NSFreeObjectArray(observance_objs);
        }
        else {
            NSKeyValueObservance *observance_objs[result_count];
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

    NSKeyValueObservationInfo *other = (NSKeyValueObservationInfo *)object;
    if(_observances.count != other.observances.count) {
        return NO;
    }
    
    NSKeyValueObservance *observance_objs[_observances.count];
    [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
    NSKeyValueObservance *other_observance_objs[_observances.count];
    [other.observances getObjects:other_observance_objs range:NSMakeRange(0, _observances.count)];
    
    for (NSUInteger i=0; i<_observances.count; ++i) {
        NSKeyValueObservance *observance = observance_objs[i];
        NSKeyValueObservance *other_observance = observance_objs[i];
        if (observance != other_observance) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@ %p> (\n", self.class, self];
    NSKeyValueObservance *observance_objs[_observances.count];
    [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
    for (NSUInteger i = 0 ;i < _observances.count; ++i) {
        NSKeyValueObservance *observance = observance_objs[i];
        [desc appendString:observance.description];
        [desc appendString:@"\n"];
    }
    [desc appendString:@")"];

    return desc;
}

@end

@implementation NSKeyValueShareableObservationInfoKey

@end

extern OSSpinLock NSKeyValueObservationInfoCreationSpinLock;
extern OSSpinLock NSKeyValueObservationInfoSpinLock;

extern void os_lock_lock(void *);
extern void os_lock_unlock(void *);
extern void *_CFGetTSD(uint32_t slot);
extern void *_CFSetTSD(uint32_t slot, void *newVal, void (*destructor)(void *));
extern NSHashTable *NSKeyValueShareableObservationInfos;
extern Class NSKeyValueShareableObservationInfoKeyIsa;
extern NSHashTable *NSKeyValueShareableObservances;

NSUInteger NSKeyValueShareableObservationInfoNSHTHash(const void * item, NSUInteger (* size)(const void * item)) {
    NSKeyValueShareableObservationInfoKey *infoKey = (NSKeyValueShareableObservationInfoKey *)item;
    if(infoKey.class == NSKeyValueShareableObservationInfoKeyIsa) {
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
                NSKeyValueObservance *observance_objs[count];
                [infoKey.baseObservationInfo.observances getObjects:observance_objs range:NSMakeRange(0, count)];
                NSUInteger hashValue = 0;
                for (NSUInteger i = 0; i < count; ++i) {
                    if (i != infoKey.removalObservanceIndex) {
                        NSKeyValueObservance *observance = observance_objs[i];
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
        return ((NSKeyValueObservationInfo *)item).cachedHash;
    }
}

BOOL NSKeyValueShareableObservationInfoNSHTIsEqual(const void * item1, const void * item2, NSUInteger (* size)(const void * item)) {
    if(item1 == item2) {
        return YES;
    }
    if(object_getClass((id)item1) == NSKeyValueShareableObservationInfoKeyIsa || object_getClass((id)item1) == NSKeyValueShareableObservationInfoKeyIsa) {
        NSKeyValueObservationInfo *info = nil;
        NSKeyValueShareableObservationInfoKey *key = nil;
        if (object_getClass((id)item1) == NSKeyValueShareableObservationInfoKeyIsa) {
            info = ( NSKeyValueObservationInfo *)item2;
            key = ( NSKeyValueShareableObservationInfoKey *)item1;
        }
        else {
            info = ( NSKeyValueObservationInfo *)item1;
            key = ( NSKeyValueShareableObservationInfoKey *)item2;
        }
        
        if(key.addingNotRemoving) {
            NSUInteger observance_count_inkey = 0;
            NSUInteger observance_count = info.observances.count;
            if(key.baseObservationInfo) {
                observance_count_inkey = key.baseObservationInfo.observances.count;
            }
            if(observance_count == observance_count_inkey + 1) {
                NSKeyValueObservance * observance_objs_inkey[observance_count_inkey];
                if(key.baseObservationInfo) {
                    [key.baseObservationInfo.observances getObjects:observance_objs_inkey range:NSMakeRange(0, observance_count_inkey)];
                }

                NSKeyValueObservance * observance_objs[observance_count];
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
            
            NSKeyValueObservance * observance_objs_inkey[observance_count_inkey];
            [key.baseObservationInfo.observances getObjects:observance_objs_inkey range:NSMakeRange(0, observance_count_inkey)];
            
            NSKeyValueObservance * observance_objs[observance_count];
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
                NSKeyValueObservance * *  p_observance_objs = &observance_objs[key.removalObservanceIndex];
                NSKeyValueObservance * *  p_observance_objs_inkey = &observance_objs_inkey[key.removalObservanceIndex + 1];
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
        NSKeyValueObservationInfo *info1 = (NSKeyValueObservationInfo *)item1;
        NSKeyValueObservationInfo *info2 = (NSKeyValueObservationInfo *)item2;
        NSUInteger info1_observance_count = CFArrayGetCount((CFArrayRef)info1.observances);
        NSUInteger info2_observance_count = CFArrayGetCount((CFArrayRef)info2.observances);
        if(info1_observance_count != info2_observance_count) {
            return NO;
        }
        
        NSKeyValueObservance * info1_observance_objs[info1_observance_count];
        [info1.observances getObjects:info1_observance_objs range:NSMakeRange(0, info1_observance_count)];
        NSKeyValueObservance * info2_observance_objs[info2_observance_count];
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

NSKeyValueObservationInfo *_NSKeyValueObservationInfoCreateByAdding(NSKeyValueObservationInfo *baseObservationInfo, id observer, NSKeyValueProperty *property, int options, void *context, id originalObservable,  BOOL *fromCache, NSKeyValueObservance **pObservance) {
    NSKeyValueObservationInfo *createdObservationInfo = nil;
    
    os_lock_lock(&NSKeyValueObservationInfoCreationSpinLock);
    if(!NSKeyValueShareableObservationInfos) {
        NSPointerFunctions *pointerFunctions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
        [pointerFunctions setHashFunction:NSKeyValueShareableObservationInfoNSHTHash];
        [pointerFunctions setIsEqualFunction:NSKeyValueShareableObservationInfoNSHTIsEqual];
        NSKeyValueShareableObservationInfos = [[NSHashTable alloc] initWithPointerFunctions:pointerFunctions capacity:0];
    }
    if(!NSKeyValueShareableObservationInfoKeyIsa) {
        NSKeyValueShareableObservationInfoKeyIsa = [NSKeyValueShareableObservationInfoKey class];
    }
    
    static NSKeyValueShareableObservationInfoKey * shareableObservationInfoKey;
    static NSKeyValueShareableObservanceKey *shareableObservanceKey;
    
    if(!shareableObservationInfoKey) {
        shareableObservationInfoKey = [[NSKeyValueShareableObservationInfoKey alloc] init];
    }
    shareableObservationInfoKey.addingNotRemoving = YES;
    shareableObservationInfoKey.baseObservationInfo = baseObservationInfo;
    shareableObservationInfoKey.additionObserver = observer;
    shareableObservationInfoKey.additionProperty = property;
    shareableObservationInfoKey.additionOptions = options;
    shareableObservationInfoKey.additionContext = context;
    shareableObservationInfoKey.additionOriginalObservable = originalObservable;
    NSKeyValueObservationInfo * observationInfoMember = [NSKeyValueShareableObservationInfos member:shareableObservationInfoKey];
    shareableObservationInfoKey.additionOriginalObservable = nil;
    shareableObservationInfoKey.additionObserver = nil;
    shareableObservationInfoKey.baseObservationInfo = nil;
    if(!observationInfoMember) {
        if(!NSKeyValueShareableObservances) {
            NSKeyValueShareableObservances = [NSHashTable weakObjectsHashTable];
        }
        if(!shareableObservanceKey) {
            shareableObservanceKey = [[NSKeyValueShareableObservanceKey alloc] init];
        }
        shareableObservanceKey.observer = observer;
        shareableObservanceKey.property = property;
        shareableObservanceKey.options = options;
        shareableObservanceKey.context = context;
        shareableObservanceKey.originalObservable = originalObservable;
        NSKeyValueObservance *observanceMember = [NSKeyValueShareableObservances member:shareableObservanceKey];
        shareableObservanceKey.originalObservable = nil;
        shareableObservanceKey.observer = nil;
        NSKeyValueObservance *observance = nil;
        if (!observanceMember) {
            observance = [[NSKeyValueObservance alloc] _initWithObserver:observer property:property options:options context:context originalObservable:originalObservable];
            if(observance.cachedIsShareable) {
                [NSKeyValueShareableObservances addObject:observance];
            }
        }
        else {
            observance = observanceMember;
        }
        
        if(baseObservationInfo) {
            createdObservationInfo = [baseObservationInfo _copyByAddingObservance:observance];
        }
        else {
            createdObservationInfo = [[NSKeyValueObservationInfo alloc] _initWithObservances:&observance count:1 hashValue:0];
        }
        if(createdObservationInfo.cachedIsShareable){
            [NSKeyValueShareableObservationInfos addObject:createdObservationInfo];
        }
        *fromCache = NO;
        *pObservance = observance;
    }
    else {
        *fromCache = YES;
        *pObservance = observationInfoMember.observances.lastObject;
        createdObservationInfo = observationInfoMember;
    }
    
    os_lock_unlock(&NSKeyValueObservationInfoCreationSpinLock);
    
    return createdObservationInfo;
}

NSKeyValueObservationInfo *_NSKeyValueObservationInfoCreateByRemoving(NSKeyValueObservationInfo *baseObservationInfo, id observer, NSKeyValueProperty *property, void *context, BOOL flag,  id originalObservable,  BOOL *fromCache, NSKeyValueObservance **pObservance) {
    NSUInteger observanceCount = CFArrayGetCount((CFArrayRef)baseObservationInfo.observances);
    NSKeyValueObservance *observancesBuff[observanceCount];
    CFArrayGetValues((CFArrayRef)baseObservationInfo.observances, CFRangeMake(0, observanceCount), (const void**)observancesBuff);
    
    NSUInteger observanceIndex = NSNotFound;
    for (NSInteger i = observanceCount - 1; i >= 0; --i) {
        NSKeyValueObservance *observance = observancesBuff[i];
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
            os_lock_lock(&NSKeyValueObservationInfoCreationSpinLock);
            if (!NSKeyValueShareableObservationInfos) {
                NSPointerFunctions *functions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
                [functions setHashFunction:NSKeyValueShareableObservationInfoNSHTHash];
                [functions setIsEqualFunction:NSKeyValueShareableObservationInfoNSHTIsEqual];
                
                NSKeyValueShareableObservationInfos = [[NSHashTable alloc] initWithPointerFunctions:functions capacity:0];
                
                [functions release];
            }
            //loc_5A596
            if (!NSKeyValueShareableObservationInfoKeyIsa) {
                NSKeyValueShareableObservationInfoKeyIsa = NSKeyValueShareableObservationInfoKey.self;
            }
            //loc_5A5BC
            
            static NSKeyValueShareableObservationInfoKey * shareableObservationInfoKey = nil;
            if (!shareableObservationInfoKey) {
                shareableObservationInfoKey = [[NSKeyValueShareableObservationInfoKey alloc] init];
            }
            
            //loc_5A5F5
            shareableObservationInfoKey.addingNotRemoving = NO;
            shareableObservationInfoKey.baseObservationInfo = baseObservationInfo;
            shareableObservationInfoKey.removalObservance = *pObservance;
            shareableObservationInfoKey.removalObservanceIndex = observanceIndex;
            shareableObservationInfoKey.cachedHash = NSKeyValueShareableObservationInfoNSHTHash(shareableObservationInfoKey, NULL);
            
            NSKeyValueObservationInfo *observationInfo = [NSKeyValueShareableObservationInfos member:shareableObservationInfoKey];
            
            shareableObservationInfoKey.removalObservance = nil;
            shareableObservationInfoKey.baseObservationInfo = nil;
            NSUInteger cachedHash = shareableObservationInfoKey.cachedHash;
            shareableObservationInfoKey.cachedHash = 0;
            
            if (!observationInfo) {
                memmove(observancesBuff + observanceIndex, observancesBuff + observanceIndex + 1, observanceCount - (observanceIndex + 1));
                observationInfo = [[NSKeyValueObservationInfo alloc] _initWithObservances:observancesBuff count:observanceCount - 1 hashValue:cachedHash];
                if (observationInfo.cachedIsShareable) {
                    [NSKeyValueShareableObservationInfos addObject:observationInfo];
                }
                *fromCache = NO;
            }
            else {
                *fromCache = YES;
                [observationInfo retain];
            }
            
            os_lock_unlock(&NSKeyValueObservationInfoCreationSpinLock);
            return observationInfo;
        }
        else {
            //loc_5A6A8
            *fromCache = YES;
        }
    }
    
    return nil;
}

void _NSKeyValueReplaceObservationInfoForObject(id object, NSKeyValueContainerClass * containerClass, NSKeyValueObservationInfo *oldObservationInfo, NSKeyValueObservationInfo *newObservationInfo, void *unknowparam) {
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    
    NSKeyValueObservingTSD *TSD = _CFGetTSD(NSKeyValueObservingTSDKey);
    if(TSD) {
        void * ebx = *(TSD + 4);
        while(ebx) {
            if(*ebx != object) {
                ebx = *(ebx+8);
                continue;
            }
            [*(ebx+4) release];
            *(ebx+4) = observationInfo1.retain;
        }
    }
    if(containerClass) {
        containerClass.cachedSetObservationInfoImplementation(object, @selector(setObservationInfo:), observationInfo1);
    }
    else {
        [object setObservationInfo:(__bridge void*)observationInfo1];
    }
    
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
}

void *_NSKeyValueCreateImplicitObservationInfo() {
    return NULL;
}

NSUInteger _NSKeyValueObservationInfoGetObservanceCount(NSKeyValueObservationInfo *info) {
    return info.observances.count;
}

void _NSKeyValueObservationInfoGetObservances(NSKeyValueObservationInfo *info, NSKeyValueObservance *observances[], NSUInteger count) {
    [info.observances getObjects:observances range:NSMakeRange(0, count)];
}

BOOL _NSKeyValueObservationInfoContainsObservance(NSKeyValueObservationInfo *info, NSKeyValueObservance *observance) {
    return [info.observances containsObject:observance];
}
