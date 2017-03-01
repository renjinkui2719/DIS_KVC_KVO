#import "NSKeyValueObservationInfo.h"
#import "NSKeyValueObservance.h"
#import "NSKeyValueContainerClass.h"
#import "NSKVOUtility.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import <objc/runtime.h>

extern int NSFreeObjectArray(void *ptr);
void* NSAllocateObjectArray(NSUInteger count);

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
                NSUInteger hash = _NSKVOPointersHash(4, (__bridge void *)observance.observer, (__bridge void *)observance.property,(void *)observance.context,(__bridge void *)observance.originalObservable);
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

    NSUInteger hash = _NSKVOPointersHash(4, (__bridge void *)observance.observer, (__bridge void *)observance.property,  (void *)_observances.count, (void *)observance.context);

    unsigned char shift = (_observances.count & 0x1F);
    copied.cachedHash = (hash >> shift | hash << shift) ^ _cachedHash;
    
    NSUInteger result_count = _observances.count + 1;

    if (((NSInteger)result_count) < 0) {
        /*
         如果此时 _observances.count(无符号数)再加1，使得结果的最高位为1，此时对应的有符号数是负数, 则算作"too large", 引发异常
         */
        [NSException raise:NSGenericException format:@"*** attempt to create a temporary id buffer which is too large or with a negative count (%lu) -- possibly data is corrupt",(NSUInteger)result_count];
    }
    else {
        if (result_count == 0) {
            result_count = 1;
        }
        if (result_count > 256) {
            NSKeyValueObservance __unsafe_unretained **observance_objs = (NSKeyValueObservance __unsafe_unretained **)NSAllocateObjectArray(result_count);
            if (!observance_objs) {
                [NSException raise:NSMallocException format:@"*** attempt to create a temporary id buffer of length (%lu) failed",(NSUInteger)result_count];
            }
            observance_objs[_observances.count] = observance;
            [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
            copied.observances = [[NSArray alloc] initWithObjects:observance_objs count:result_count];
            NSFreeObjectArray(observance_objs);
        }
        else {
            NSKeyValueObservance __unsafe_unretained *observance_objs[result_count];
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
    
    NSKeyValueObservance __unsafe_unretained *observance_objs[_observances.count];
    [_observances getObjects:observance_objs range:NSMakeRange(0, _observances.count)];
    NSKeyValueObservance __unsafe_unretained *other_observance_objs[_observances.count];
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
    NSKeyValueObservance __unsafe_unretained *observance_objs[_observances.count];
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
    NSKeyValueShareableObservationInfoKey *infoKey = (__bridge NSKeyValueShareableObservationInfoKey *)item;
    if(infoKey.class == NSKeyValueShareableObservationInfoKeyIsa) {
        if(infoKey.addingNotRemoving) {
            NSUInteger count = 0;
            if(infoKey.baseObservationInfo) {
                count = CFArrayGetCount((__bridge CFArrayRef)infoKey.baseObservationInfo.observances);
                count &= 0x1F;
            }
            NSUInteger hashValue =  _NSKVOPointersHash(4,infoKey.additionObserver,infoKey.additionProperty, infoKey.additionContext, infoKey.additionOriginalObservable);
            hashValue = (hashValue << count) | (hashValue >> count);
            hashValue ^= (infoKey.baseObservationInfo ? infoKey.baseObservationInfo.cachedHash : 0);
            return hashValue;
        }
        else {
            if(infoKey.cachedHash == 0) {
                NSUInteger count = CFArrayGetCount((__bridge CFArrayRef)infoKey.baseObservationInfo.observances);
                NSKeyValueObservance __unsafe_unretained *observance_objs[count];
                [infoKey.baseObservationInfo.observances getObjects:observance_objs range:NSMakeRange(0, count)];
                NSUInteger hashValue = 0;
                if(count) {
                    NSUInteger i = 0;
                    while(i != infoKey.removalObservanceIndex) {
                        NSKeyValueObservance *observance = observance_objs[i];
                        NSUInteger hash =  _NSKVOPointersHash(4,observance.observer,observance.property, observance.context, observance.originalObservable);
                        hash = (hash << (i & 0x1f)) | (hash >> (i & 0x1f));
                        hash ^= hashValue;
                        hashValue = hash;
                        if(++i == count) {
                            break;
                        }
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
        return ((__bridge NSKeyValueObservationInfo *)item).cachedHash;
    }
}

BOOL NSKeyValueShareableObservationInfoNSHTIsEqual(const void * item1, const void * item2, NSUInteger (* size)(const void * item)) {
    if(item1 == item2) {
        return YES;
    }
    if(object_getClass((id)item1) == NSKeyValueShareableObservationInfoKeyIsa || object_getClass((id)item1) == NSKeyValueShareableObservationInfoKeyIsa) {
        NSKeyValueObservationInfo *info = nil;
        NSKeyValueShareableObservationInfoKey *infoKey = nil;
        if (object_getClass(( id)item1) == NSKeyValueShareableObservationInfoKeyIsa) {
            info = ( NSKeyValueObservationInfo *)item2;
            infoKey = ( NSKeyValueShareableObservationInfoKey *)item1;
        }
        else {
            info = ( NSKeyValueObservationInfo *)item1;
            infoKey = ( NSKeyValueShareableObservationInfoKey *)item2;
        }
        
        if(infoKey.addingNotRemoving) {
            NSUInteger base_observance_count = 0;
            NSUInteger observance_count = info.observances.count;
            if(infoKey.baseObservationInfo) {
                base_observance_count = infoKey.baseObservationInfo.observances.count;
            }
            if(observance_count == base_observance_count + 1) {
                NSKeyValueObservance *__unsafe_unretained base_observance_objs[base_observance_count];
                if(infoKey.baseObservationInfo) {
                    [infoKey.baseObservationInfo.observances getObjects:base_observance_objs range:NSMakeRange(0, base_observance_count)];
                }

                NSKeyValueObservance *__unsafe_unretained observance_objs[observance_count];
                [info.observances getObjects:observance_objs range:NSMakeRange(0, observance_count)];
                
                if(base_observance_count != 0) {
                    NSUInteger i = 0;
                    while(i < base_observance_count) {
                        if(base_observance_objs[i] != observance_objs[i]) {
                            return NO;
                        }
                        ++i;
                    }
                }
                if(observance_objs[base_observance_count].property != infoKey.additionProperty) {
                    return NO;
                }
                if(observance_objs[base_observance_count].options != infoKey.additionOptions) {
                    return NO;
                }
                if(observance_objs[base_observance_count].context != infoKey.additionContext) {
                    return NO;
                }
                if(observance_objs[base_observance_count].originalObservable != infoKey.additionOriginalObservable) {
                    return NO;
                }
                if(observance_objs[base_observance_count].observer != infoKey.additionObserver) {
                    return NO;
                }
                
                return YES;
            }
            else {
                return NO;
            }
        }
        else {
            NSUInteger base_observance_count = CFArrayGetCount(( CFArrayRef)infoKey.baseObservationInfo.observances);
            NSUInteger observance_count = CFArrayGetCount(( CFArrayRef)info.observances);
            if(base_observance_count - 1 != observance_count) {
                return NO;
            }
            NSKeyValueObservance *__unsafe_unretained base_observance_objs[base_observance_count];
            [infoKey.baseObservationInfo.observances getObjects:base_observance_objs range:NSMakeRange(0, base_observance_count)];
            
            NSKeyValueObservance *__unsafe_unretained observance_objs[observance_count];
            [info.observances getObjects:observance_objs range:NSMakeRange(0, observance_count)];
            
            if(infoKey.removalObservanceIndex != 0) {
                NSUInteger i = 0;
                while(i < infoKey.removalObservanceIndex) {
                    if(base_observance_objs[i] != observance_objs[i]) {
                        return NO;
                    }
                    ++i;
                }
            }
            NSUInteger count = base_observance_count - (infoKey.removalObservanceIndex + 1);
            if(count == 0) {
                return YES;
            }
            else {
                NSKeyValueObservance *__unsafe_unretained *  p_observance_objs = &observance_objs[infoKey.removalObservanceIndex];
                NSKeyValueObservance *__unsafe_unretained *  p_base_observance_objs = &base_observance_objs[infoKey.removalObservanceIndex + 1];
                NSUInteger i = 0;
                while(i < count) {
                    if(p_observance_objs[i] != p_base_observance_objs[i]) {
                        return NO;
                    }
                    ++i;
                }
                return YES;
            }
            return YES;
        }
    }
    else {
        NSKeyValueObservationInfo *info1 = (__bridge NSKeyValueObservationInfo *)item1;
        NSKeyValueObservationInfo *info2 = (__bridge NSKeyValueObservationInfo *)item2;
        NSUInteger info1_observance_count = CFArrayGetCount((__bridge CFArrayRef)info1.observances);
        NSUInteger info2_observance_count = CFArrayGetCount((__bridge CFArrayRef)info2.observances);
        if(info1_observance_count != info2_observance_count) {
            return NO;
        }
        
        NSKeyValueObservance *__unsafe_unretained info1_observance_objs[info1_observance_count];
        [info1.observances getObjects:info1_observance_objs range:NSMakeRange(0, info1_observance_count)];
        NSKeyValueObservance *__unsafe_unretained info2_observance_objs[info2_observance_count];
        [info1.observances getObjects:info2_observance_objs range:NSMakeRange(0, info2_observance_count)];
        
        if(info1_observance_count == 0) {
            return  YES;
        }
        else {
            NSUInteger i = 0;
            while(i < info1_observance_count) {
                if(info1_observance_objs[i] != info2_observance_objs[i]) {
                    return NO;
                }
                ++i;
            }
            return YES;
        }
    }
}

NSKeyValueObservationInfo *_NSKeyValueObservationInfoCreateByAdding(NSKeyValueObservationInfo *baseObservationInfo, id observer, NSKeyValueProperty *property, int options, void *context, id originalObservable,  BOOL *fromCache, NSKeyValueObservance **pObservance) {
    NSKeyValueObservationInfo *createdObservationInfo = nil;
    
    os_lock_lock(&NSKeyValueObservationInfoCreationSpinLock);
    if(!NSKeyValueShareableObservationInfos) {
        NSPointerFunctions *pointerFunctions = [[NSPointerFunctions alloc] initWithOptions:5];
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
    shareableObservationInfoKey.additionOptions = options & 0xFFFFFFFB;
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
