#import "DSKeyValueObservationInfo.h"
#import "DSKeyValueObservance.h"
#import "DSKeyValueContainerClass.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "NSObject+DSKeyValueObservingCustomization.h"
#import "DSKeyValueCodingCommon.h"
#import "DSKeyValueObserverCommon.h"

OSSpinLock DSKeyValueObservationInfoCreationSpinLock = OS_SPINLOCK_INIT;
OSSpinLock DSKeyValueObservationInfoSpinLock = OS_SPINLOCK_INIT;

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
                NSUInteger hash = _DSKVOPointersHash(4, (void *)observance.observer, (void *)observance.property,(void *)observance.context,(void *)observance.originalObservable);
                _cachedHash = (hash << (i & 0x1F)) | (hash >> (i & 0x1F));
                if (!observance.cachedIsShareable) {
                    _cachedIsShareable = NO;
                }
            }
        }
    }
    return self;
}

- (void)dealloc {
    [_observances release];
    [super dealloc];
}

- (DSKeyValueObservationInfo *)_copyByAddingObservance:(DSKeyValueObservance *)observance {

    DSKeyValueObservationInfo *copied = [[DSKeyValueObservationInfo alloc] init];

    NSUInteger hash = _DSKVOPointersHash(4, (void *)observance.observer, (void *)observance.property,  (void *)_observances.count, (void *)observance.context);

    unsigned char shift = (_observances.count & 0x1F);
    copied.cachedHash = (hash >> shift | hash << shift) ^ _cachedHash;
    
    NSUInteger result_count = _observances.count + 1;

    //result_count 超过 NSIntegerMax，抛 too  large  异常
    if (((NSInteger)result_count) < 0) {
        [NSException raise:NSGenericException format:@"*** attempt to create a temporary id buffer which is too large or with a negative count (%lu) -- possibly data is corrupt",(NSUInteger)result_count];
    }
    else {
        if (result_count == 0) {
            result_count = 1;
        }
        if (result_count > 256) {
            //大于256个对象， 堆分配内存
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
            //栈分配
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


/**
 *  计算 DSKeyValueObservationInfo 或者 DSKeyValueShareableObservationInfoKey对象的hash值
 *
 *  @param item 待计算hash值对象
 *  @param size 无用
 *
 *  @return hash值
 */
NSUInteger DSKeyValueShareableObservationInfoNSHTHash(const void * item, NSUInteger (* size)(const void * item)) {
    DSKeyValueShareableObservationInfoKey *keyOrInfo = (DSKeyValueShareableObservationInfoKey *)item;
    // DSKeyValueShareableObservationInfoKey对象
    if(keyOrInfo.class == DSKeyValueShareableObservationInfoKeyIsa) {
        DSKeyValueShareableObservationInfoKey *key = (DSKeyValueShareableObservationInfoKey *)keyOrInfo;
        if(key.addingNotRemoving) {
            NSUInteger shift = 0;
            if(key.baseObservationInfo) {
                shift = CFArrayGetCount((CFArrayRef)key.baseObservationInfo.observances);
                shift &= 0x1F;
            }
            NSUInteger hashValue =  _DSKVOPointersHash(4,key.additionObserver,key.additionProperty, key.additionContext, key.additionOriginalObservable);
            hashValue = (hashValue << shift) | (hashValue >> shift);
            hashValue ^= (key.baseObservationInfo ? key.baseObservationInfo.cachedHash : 0);
            return hashValue;
        }
        else if(key.cachedHash == 0) {
            NSUInteger base_observance_count = CFArrayGetCount((CFArrayRef)key.baseObservationInfo.observances);
            DSKeyValueObservance *base_observance_objs[base_observance_count];
            [key.baseObservationInfo.observances getObjects:base_observance_objs range:NSMakeRange(0, base_observance_count)];
            NSUInteger hashValue = 0;
            for (NSUInteger i = 0; i < base_observance_count; ++i) {
                if (i != key.removalObservanceIndex) {
                    DSKeyValueObservance *observance = base_observance_objs[i];
                    NSUInteger hash =  _DSKVOPointersHash(4,observance.observer,observance.property, observance.context, observance.originalObservable);
                    hash = (hash << (i & 0x1f)) | (hash >> (i & 0x1f));
                    hash ^= hashValue;
                    hashValue = hash;
                }
            }
            return hashValue;
        }
        else {
            return key.cachedHash;
        }
    }
    // DSKeyValueObservationInfo对象，直接获取 cachedHash
    else {
        return ((DSKeyValueObservationInfo *)item).cachedHash;
    }
}

/**
 *  判断相等方法， 用以在 DSKeyValueShareableObservationInfos 缓存里查找 符合条件的ObservationInfo
 *
 *  @param item1 key/info
 *  @param item2 key/info
 *  @param size 无用
 *
 *  @return YES/NO
 */
BOOL DSKeyValueShareableObservationInfoNSHTIsEqual(const void * item1, const void * item2, NSUInteger (* size)(const void * item)) {
    if(item1 == item2) {
        return YES;
    }
    //一个key 与 一个info比较
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
        //key是个“想要添加observance”的key
        if(key.addingNotRemoving) {
            NSUInteger observance_count_inkey = 0;
            NSUInteger observance_count_inInfo = info.observances.count;
            if(key.baseObservationInfo) {
                observance_count_inkey = key.baseObservationInfo.observances.count;
            }
            //判断是否 (key.baseObservationInfo 加上 key自带的observer等信息后) 恰好等于该 info
            if(observance_count_inInfo == observance_count_inkey + 1) {
                DSKeyValueObservance * observance_objs_inkey[observance_count_inkey];
                if(key.baseObservationInfo) {
                    [key.baseObservationInfo.observances getObjects:observance_objs_inkey range:NSMakeRange(0, observance_count_inkey)];
                }
                
                DSKeyValueObservance * observance_objs_inInfo[observance_count_inInfo];
                [info.observances getObjects:observance_objs_inInfo range:NSMakeRange(0, observance_count_inInfo)];
                
                for (NSUInteger i = 0; i < observance_count_inkey; ++i) {
                    if (observance_objs_inkey[i] != observance_objs_inInfo[i]) {
                        return NO;
                    }
                }
   
                //info.observance列表最后一个observance 和 key带的（observer, property,...）全等
                if(observance_objs_inInfo[observance_count_inkey].property != key.additionProperty) {
                    return NO;
                }
                if(observance_objs_inInfo[observance_count_inkey].options != key.additionOptions) {
                    return NO;
                }
                if(observance_objs_inInfo[observance_count_inkey].context != key.additionContext) {
                    return NO;
                }
                if(observance_objs_inInfo[observance_count_inkey].originalObservable != key.additionOriginalObservable) {
                    return NO;
                }
                if(observance_objs_inInfo[observance_count_inkey].observer != key.additionObserver) {
                    return NO;
                }
                
                return YES;
            }
            else {
                return NO;
            }
        }
        //key是个“想要移除observance”的key
        else {
            //判断是否 (key.baseObservationInfo 减去 key.removalObservanceIndex 处的observance后) 恰好等于该 info
            NSUInteger observance_count_inkey = CFArrayGetCount(( CFArrayRef)key.baseObservationInfo.observances);
            NSUInteger observance_count_inInfo = CFArrayGetCount(( CFArrayRef)info.observances);
            
            if(observance_count_inkey - 1 != observance_count_inInfo) {
                return NO;
            }
            
            DSKeyValueObservance * observance_objs_inkey[observance_count_inkey];
            [key.baseObservationInfo.observances getObjects:observance_objs_inkey range:NSMakeRange(0, observance_count_inkey)];
            
            DSKeyValueObservance * observance_objs_inInfo[observance_count_inInfo];
            [info.observances getObjects:observance_objs_inInfo range:NSMakeRange(0, observance_count_inInfo)];
            
            //removalObservanceIndex 前的observance列表全等
            for (NSUInteger i = 0; i < key.removalObservanceIndex; ++i) {
                if(observance_objs_inkey[i] != observance_objs_inInfo[i]) {
                    return NO;
                }
            }
            
            //removalObservanceIndex 后的observance列表全等
            NSUInteger leftCount = observance_count_inkey - (key.removalObservanceIndex + 1);
            if(leftCount == 0) {
                return YES;
            }
            else {
                DSKeyValueObservance * *  p_observance_objs_inInfo = &observance_objs_inInfo[key.removalObservanceIndex];
                DSKeyValueObservance * *  p_observance_objs_inkey = &observance_objs_inkey[key.removalObservanceIndex + 1];
                for (NSUInteger i = 0; i < leftCount; ++i) {
                    if(p_observance_objs_inInfo[i] != p_observance_objs_inkey[i]) {
                        return NO;
                    }
                }
                
                return YES;
            }
        }
    }
    //两个info比较
    else {
        DSKeyValueObservationInfo *info1 = (DSKeyValueObservationInfo *)item1;
        DSKeyValueObservationInfo *info2 = (DSKeyValueObservationInfo *)item2;
        NSUInteger info1_observance_count = CFArrayGetCount((CFArrayRef)info1.observances);
        NSUInteger info2_observance_count = CFArrayGetCount((CFArrayRef)info2.observances);
        //两个info的observance数目应该相等
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
            //两个info的每一个observance应相同
            for (NSUInteger i = 0; i < info1_observance_count; ++i) {
                if(info1_observance_objs[i] != info2_observance_objs[i]) {
                    return NO;
                }
            }
            return YES;
        }
    }
}

DSKeyValueObservationInfo *_DSKeyValueObservationInfoCreateByAdding(DSKeyValueObservationInfo *baseObservationInfo, id observer, DSKeyValueProperty *property, int options, void *context, id originalObservable,  BOOL *cacheHit, DSKeyValueObservance **addedObservance) {
    DSKeyValueObservationInfo *createdObservationInfo = nil;
    
    os_lock_lock(&DSKeyValueObservationInfoCreationSpinLock);
    
    //observationInfo缓存
    if(!DSKeyValueShareableObservationInfos) {
        NSPointerFunctions *pointerFunctions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
        [pointerFunctions setHashFunction:DSKeyValueShareableObservationInfoNSHTHash];
        [pointerFunctions setIsEqualFunction:DSKeyValueShareableObservationInfoNSHTIsEqual];
        DSKeyValueShareableObservationInfos = [[NSHashTable alloc] initWithPointerFunctions:pointerFunctions capacity:0];
    }
    
    if(!DSKeyValueShareableObservationInfoKeyIsa) {
        DSKeyValueShareableObservationInfoKeyIsa = [DSKeyValueShareableObservationInfoKey class];
    }
    
    //observationInfo查找key
    static DSKeyValueShareableObservationInfoKey * shareableObservationInfoKey;
    
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
    
    //查找缓存里 是否已经包含 和  baseObservationInfo + observance(observer, property, options, context) 一样的 observationInfo
    //避免不必要的创建
    DSKeyValueObservationInfo * existsObservationInfo = [DSKeyValueShareableObservationInfos member:shareableObservationInfoKey];
    
    shareableObservationInfoKey.additionOriginalObservable = nil;
    shareableObservationInfoKey.additionObserver = nil;
    shareableObservationInfoKey.baseObservationInfo = nil;
    
    //缓存中不存在
    if(!existsObservationInfo) {
        //observance缓存
        if(!DSKeyValueShareableObservances) {
            DSKeyValueShareableObservances = [NSHashTable weakObjectsHashTable];
        }
        //observance查找key
        static DSKeyValueShareableObservanceKey *shareableObservanceKey;
        
        if(!shareableObservanceKey) {
            shareableObservanceKey = [[DSKeyValueShareableObservanceKey alloc] init];
        }
        
        shareableObservanceKey.observer = observer;
        shareableObservanceKey.property = property;
        shareableObservanceKey.options = options;
        shareableObservanceKey.context = context;
        shareableObservanceKey.originalObservable = originalObservable;
        
        //查找缓存
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
            //复制baseObservationInfo并追加observance
            createdObservationInfo = [baseObservationInfo _copyByAddingObservance:observance];
        }
        else {
            //创建新的ObservationInfo
            createdObservationInfo = [[DSKeyValueObservationInfo alloc] _initWithObservances:&observance count:1 hashValue:0];
        }
        
        if(createdObservationInfo.cachedIsShareable){
            [DSKeyValueShareableObservationInfos addObject:createdObservationInfo];
        }
        
        *cacheHit = NO;
        *addedObservance = observance;
    }
    else {
        //缓存中存在
        *cacheHit = YES;
        //observance必定就是已存在的info.observance列表最后一个， 因为判断equal就是按照这个原则去判断的
        *addedObservance = existsObservationInfo.observances.lastObject;
        
        createdObservationInfo = existsObservationInfo;
    }
    
    os_lock_unlock(&DSKeyValueObservationInfoCreationSpinLock);
    
    return createdObservationInfo;
}


DSKeyValueObservationInfo *_DSKeyValueObservationInfoCreateByRemoving(DSKeyValueObservationInfo *baseObservationInfo, id observer, DSKeyValueProperty *property, void *context, BOOL shouldCompareContext,  id originalObservable,  BOOL *cacheHit, DSKeyValueObservance **removalObservance) {
    DSKeyValueObservationInfo *createdObservationInfo = nil;
    
    NSUInteger observanceCount = CFArrayGetCount((CFArrayRef)baseObservationInfo.observances);
    DSKeyValueObservance *observancesBuff[observanceCount];
    CFArrayGetValues((CFArrayRef)baseObservationInfo.observances, CFRangeMake(0, observanceCount), (const void **)observancesBuff);
    
    NSUInteger removalObservanceIndex = NSNotFound;
    
    for (NSInteger i = observanceCount - 1; i >= 0; --i) {
        DSKeyValueObservance *observance = observancesBuff[i];
        if (observance.property == property && observance.observer == observer) {
            if (!shouldCompareContext || observance.context == context) {
                if (!originalObservable || observance.originalObservable == originalObservable) {
                    *removalObservance = observance;
                    removalObservanceIndex = i;
                    break;
                }
            }
        }
    }
    
    if (*removalObservance) {
        if (observanceCount > 1) {
            os_lock_lock(&DSKeyValueObservationInfoCreationSpinLock);
            if (!DSKeyValueShareableObservationInfos) {
                NSPointerFunctions *functions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
                [functions setHashFunction:DSKeyValueShareableObservationInfoNSHTHash];
                [functions setIsEqualFunction:DSKeyValueShareableObservationInfoNSHTIsEqual];
                
                DSKeyValueShareableObservationInfos = [[NSHashTable alloc] initWithPointerFunctions:functions capacity:0];
                
                [functions release];
            }
            if (!DSKeyValueShareableObservationInfoKeyIsa) {
                DSKeyValueShareableObservationInfoKeyIsa = DSKeyValueShareableObservationInfoKey.self;
            }
            
            static DSKeyValueShareableObservationInfoKey * shareableObservationInfoKey = nil;
            if (!shareableObservationInfoKey) {
                shareableObservationInfoKey = [[DSKeyValueShareableObservationInfoKey alloc] init];
            }
            
            shareableObservationInfoKey.addingNotRemoving = NO;
            shareableObservationInfoKey.baseObservationInfo = baseObservationInfo;
            shareableObservationInfoKey.removalObservance = *removalObservance;
            shareableObservationInfoKey.removalObservanceIndex = removalObservanceIndex;
            shareableObservationInfoKey.cachedHash = DSKeyValueShareableObservationInfoNSHTHash(shareableObservationInfoKey, NULL);
            
            DSKeyValueObservationInfo *existsObservationInfo = [DSKeyValueShareableObservationInfos member:shareableObservationInfoKey];
            
            shareableObservationInfoKey.removalObservance = nil;
            shareableObservationInfoKey.baseObservationInfo = nil;
            
            NSUInteger cachedHash = shareableObservationInfoKey.cachedHash;
            
            shareableObservationInfoKey.cachedHash = 0;
            
            if (!existsObservationInfo) {
                memmove(observancesBuff + removalObservanceIndex, observancesBuff + removalObservanceIndex + 1, (observanceCount - (removalObservanceIndex + 1)) * sizeof(DSKeyValueObservance *));
                createdObservationInfo = [[DSKeyValueObservationInfo alloc] _initWithObservances:observancesBuff count:observanceCount - 1 hashValue:cachedHash];
                if (createdObservationInfo.cachedIsShareable) {
                    [DSKeyValueShareableObservationInfos addObject:createdObservationInfo];
                }
                *cacheHit = NO;
            }
            else {
                *cacheHit = YES;
                createdObservationInfo = [existsObservationInfo retain];
            }
            
            os_lock_unlock(&DSKeyValueObservationInfoCreationSpinLock);
            
            return createdObservationInfo;
        }
        else {
            *cacheHit = YES;
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
        ObservationInfoWatcher *next = TSD->firstWatcher;
        while(next) {
            if (next->object == object) {
                [next->observationInfo release];
                next->observationInfo = [newObservationInfo retain];
                break;
            }
            next = next->next;
        }
    }
    
    if(containerClass) {
        containerClass.cachedSetObservationInfoImplementation(object, @selector(d_setObservationInfo:), newObservationInfo);
    }
    else {
        [object d_setObservationInfo: newObservationInfo];
    }
    
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
}

DSKeyValueObservationInfo *_DSKeyValueRetainedObservationInfoForObject(id object, DSKeyValueContainerClass *containerClass) {
    DSKeyValueObservationInfo *observationInfo = nil;
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    
    if (containerClass) {
        observationInfo = ((DSKeyValueObservationInfo * (*)(id,SEL))containerClass.cachedObservationInfoImplementation)(object, @selector(observationInfo));
    }
    else {
        observationInfo = (DSKeyValueObservationInfo *)[object d_observationInfo];
    }
    
    [observationInfo retain];
    
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
    
    return  observationInfo;
}


void _DSKeyValueAddObservationInfoWatcher(ObservationInfoWatcher * watcher) {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if (!TSD) {
        TSD = (DSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
        _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
    }
    watcher->next = TSD->firstWatcher;
    TSD->firstWatcher = watcher;
}

void _DSKeyValueRemoveObservationInfoWatcher(ObservationInfoWatcher * watcher) {
    DSKeyValueObservingTSD *TSD = _CFGetTSD(DSKeyValueObservingTSDKey);
    if (!TSD) {
        TSD = (DSKeyValueObservingTSD *)NSAllocateScannedUncollectable(sizeof(DSKeyValueObservingTSD));
        _CFSetTSD(DSKeyValueObservingTSDKey, TSD, DSKeyValueObservingTSDDestroy);
    }
    
    if(TSD->firstWatcher != watcher) {
        NSLog(@"_DSKeyValueRemoveObservationInfoWatcher() was called in a surprising way.");
    }
    
    if(TSD->firstWatcher) {
        TSD->firstWatcher = watcher->next;
    }
}

void _DSKeyValueRemoveObservationInfoForObject(id object, DSKeyValueObservationInfo *observationInfo) {
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    if(!DSKeyValueObservationInfoPerObject) {
        DSKeyValueObservationInfoPerObject = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    CFDictionaryRemoveValue(DSKeyValueObservationInfoPerObject, OBSERVATION_INFO_KEY(object));
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
