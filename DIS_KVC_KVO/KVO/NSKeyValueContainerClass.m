#import "NSKeyValueContainerClass.h"
#import "NSKeyValueObservationInfo.h"
#import "NSObject+NSKeyValueObservingPrivate.h"
#import "NSObject+NSKeyValueCodingPrivate.h"
#import "NSSetValueAndNotify.h"
#import "NSKeyValueGetter.h"
#import "NSKeyValueSetter.h"
#import "NSKeyValueMethodSetter.h"
#import "NSKeyValueMutatingArrayMethodSet.h"
#import "NSKeyValueMutatingOrderedSetMethodSet.h"
#import "NSKeyValueMutatingSetMethodSet.h"
#import "NSKeyValueObserverCommon.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import <objc/message.h>

extern Class NSClassFromObject(id);
extern OSSpinLock NSKeyValueObservationInfoSpinLock;
extern void os_lock_lock(void *);
extern void os_lock_unlock(void *);
extern void *_CFGetTSD(uint32_t slot);
extern void *_CFSetTSD(uint32_t slot, void *newVal, void (*destructor)(void *));
extern void * NSAllocateScannedUncollectable(size_t);
extern NSUInteger dyld_get_program_sdk_version();
extern CFMutableDictionaryRef NSKeyValueObservationInfoPerObject;

@implementation NSKeyValueContainerClass 

- (id)initWithOriginalClass:(Class)originalClass {
    if(self = [super init]) {
        _originalClass = originalClass;
        
        _cachedObservationInfoImplementation = class_getMethodImplementation(originalClass,sel_registerName("observationInfo"));
        
        Method method = class_getInstanceMethod(_originalClass, sel_registerName("setObservationInfo:"));
        _cachedSetObservationInfoImplementation = method_getImplementation(method);
        
        char type = 0;
        method_getArgumentType(method, 2, &type, 1);
        if (type == '@') {
            _cachedSetObservationInfoTakesAnObject = YES;
        }
    }
    return self;
}

- (id)description {
    Class notifyingClass = NULL;
    if(_notifyingInfo) {
        notifyingClass = _notifyingInfo->containerClass;
    }
    else {
        notifyingClass = NSClassFromObject(@"not cached yet");
    }
    return [NSString stringWithFormat:@"<%@: Original class: %@, Notifying class: %@>",NSClassFromObject(self), _originalClass,notifyingClass];
}

@end

NSKeyValueObservationInfo *_NSKeyValueRetainedObservationInfoForObject(id object, NSKeyValueContainerClass *containerClass) {
    NSKeyValueObservationInfo *observationInfo = nil;
    
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    if (containerClass) {
       observationInfo = ((NSKeyValueObservationInfo * (*)(id,SEL))containerClass.cachedObservationInfoImplementation)(object, @selector(observationInfo));
    }
    else {
        observationInfo = (NSKeyValueObservationInfo *)[object observationInfo];
    }
    
    [observationInfo retain];
    
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
    
    return  observationInfo;
}

 

typedef struct {
    void *p1;
    void *p2;
    void *p3;
    void *p4;
}ObservationInfoWatcher;

typedef struct {
    id object;
    NSKeyValueObservationInfo *observationInfo;
    void *p3;
}unknow_stru_1;

void _NSKeyValueAddObservationInfoWatcher(unknow_stru_1 * pstru) {
    ObservationInfoWatcher *watcher = (ObservationInfoWatcher *)_CFGetTSD(0x15);
    if (!watcher) {
        watcher = (ObservationInfoWatcher *)NSAllocateScannedUncollectable(40);
        _CFSetTSD(0x15, watcher, NSKeyValueObservingTSDDestroy);
    }
    pstru->p3 = watcher->p2;
    watcher->p2 = pstru;
}

void _NSKeyValueRemoveObservationInfoWatcher(unknow_stru_1 * pstru) {
    ObservationInfoWatcher *watcher = (ObservationInfoWatcher *)_CFGetTSD(0x15);
    if (!watcher) {
        watcher = (ObservationInfoWatcher *)NSAllocateScannedUncollectable(40);
        _CFSetTSD(0x15, watcher, NSKeyValueObservingTSDDestroy);
    }
    if(watcher->p2 != pstru) {
        NSLog(@"_NSKeyValueRemoveObservationInfoWatcher() was called in a surprising way.");
    }
    if(watcher->p2) {
        watcher->p2 = pstru->p3;
    }
}

void _NSKeyValueRemoveObservationInfoForObject(id object, NSKeyValueObservationInfo *observationInfo) {
    os_lock_lock(&NSKeyValueObservationInfoSpinLock);
    if(!NSKeyValueObservationInfoPerObject) {
        NSKeyValueObservationInfoPerObject = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    CFDictionaryRemoveValue(NSKeyValueObservationInfoPerObject, (void*)~(NSUInteger)(void *)object);
    os_lock_unlock(&NSKeyValueObservationInfoSpinLock);
}

BOOL NSKVOIsAutonotifying() {
    return YES;
}

Class NSKVOClass(id object, SEL selector) {
    Class objClass = object_getClass(object);
    Class originalClass =  _NSKVONotifyingOriginalClassForIsa(objClass);
    if (objClass == originalClass) {
        Method m = class_getInstanceMethod(objClass, selector);
        return ((id (*)(id,Method))method_invoke)(object, m);
    }
    else {
        return [originalClass class];
    }
}

void NSKVODeallocateBreak(id object) {
    if (!object) {
        NSLog(@"");
    }
}

void NSKVODeallocate(id object, SEL selector) {
    NSKeyValueObservationInfo *observationInfo = _NSKeyValueRetainedObservationInfoForObject(object, nil);
    unknow_stru_1 stru = {0};
    stru.object = object;
    stru.observationInfo = observationInfo;
    stru.p3 = nil;
    _NSKeyValueAddObservationInfoWatcher(&stru);
    Class cls = object_getClass(object);
    void *ivars = object_getIndexedIvars(cls);
    NSKeyValueNotifyingInfo *notifyInfo = (NSKeyValueNotifyingInfo *)ivars;
    Method originDellocMethod = class_getInstanceMethod(notifyInfo->originalClass, selector);
    ((id (*)(id,Method))method_invoke)(object, originDellocMethod);
    
    if(observationInfo) {
        Boolean keyExistsAndHasValidFormat = NO;
        Boolean NSKVODeallocateCleansUpBeforeThrowing = CFPreferencesGetAppBooleanValue(CFSTR("NSKVODeallocateCleansUpBeforeThrowing"), kCFPreferencesCurrentApplication, &keyExistsAndHasValidFormat);
        if(!NSKVODeallocateCleansUpBeforeThrowing) {
            NSKVODeallocateCleansUpBeforeThrowing = YES;
        }
        unsigned char flag = !NSKVODeallocateCleansUpBeforeThrowing | !keyExistsAndHasValidFormat;
        if(dyld_get_program_sdk_version() > 0x7FFFF || !flag) {
            if(!flag) {
                _NSKeyValueRemoveObservationInfoForObject(object, observationInfo);
            }
            [NSException raise:NSInternalInconsistencyException format:@"An instance %p of class %@ was deallocated while key value observers were still registered with it. Current observation info: %@", object, notifyInfo->originalClass, observationInfo];
        }
        else {
            NSLog(@"An instance %p of class %@ was deallocated while key value observers were still registered with it. Observation info was leaked, and may even become mistakenly attached to some other object. Set a breakpoint on NSKVODeallocateBreak to stop here in the debugger. Here's the current observation info:\n%@", object, notifyInfo->originalClass, observationInfo);
        }
        
        _NSKeyValueRemoveObservationInfoWatcher(&stru);
    }
}

void NSKVONotifyingSetMethodImplementation(NSKeyValueNotifyingInfo *info, SEL sel, IMP imp, NSString *key) {
    Method m = class_getInstanceMethod(info->originalClass, sel);
    if (m) {
        if (key) {
            pthread_mutex_lock(&info->mutex);
            
            CFDictionarySetValue(info->selKeyMap,sel, key);
            
            pthread_mutex_unlock(&info->mutex);
        }
        const char *encoding = method_getTypeEncoding(m);
        class_addMethod(info->containerClass, sel, imp, encoding);
    }
}

NSKeyValueNotifyingInfo *_NSKVONotifyingCreateInfoWithOriginalClass(Class originalClass) {
    static const char *notifyingClassNamePrefix = "NSKVONotifying_";
    
    static IMP NSObjectWillChange;
    static IMP NSObjectDidChange;
    
    const char *originalClassName = class_getName(originalClass);
    size_t size = strlen(originalClassName) + 16;
    char *newClassName = (char *)malloc(size);
    
    strlcpy(newClassName, notifyingClassNamePrefix, size);
    strlcat(newClassName, originalClassName, size);
    
    Class containerClass = objc_allocateClassPair(originalClass, newClassName, sizeof(NSKeyValueNotifyingInfo));
    objc_registerClassPair(containerClass);
    
    free(newClassName);
    
    unsigned char *ivars = object_getIndexedIvars(containerClass);
    NSKeyValueNotifyingInfo *notifyingInfo = (NSKeyValueNotifyingInfo *)ivars;
    notifyingInfo->originalClass = originalClass;
    notifyingInfo->containerClass = containerClass;
    
    notifyingInfo->keys = CFSetCreateMutable(NULL, 0, &kCFCopyStringSetCallBacks);
    notifyingInfo->selKeyMap = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    
    pthread_mutexattr_t mutexattr;
    pthread_mutexattr_init(&mutexattr);
    pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&notifyingInfo->mutex, &mutexattr);
    pthread_mutexattr_destroy(&mutexattr);
    
    static dispatch_once_t NSObjectIMPLookupOnce;
    dispatch_once(&NSObjectIMPLookupOnce, ^{
        NSObjectWillChange = class_getMethodImplementation([NSObject class], @selector(willChangeValueForKey:));
        NSObjectDidChange = class_getMethodImplementation([NSObject class], @selector(didChangeValueForKey:));
    });
    
    BOOL flag = YES;
    if(class_getMethodImplementation(notifyingInfo->originalClass, @selector(willChangeValueForKey:)) == NSObjectWillChange) {
        flag = class_getMethodImplementation(notifyingInfo->originalClass, @selector(didChangeValueForKey:)) != NSObjectDidChange;
    }
    notifyingInfo->flag = flag;
    
    NSKVONotifyingSetMethodImplementation(notifyingInfo, ISKVOASelector, (IMP)NSKVOIsAutonotifying, NULL);
    NSKVONotifyingSetMethodImplementation(notifyingInfo, @selector(dealloc), (IMP)NSKVODeallocate, NULL);
    NSKVONotifyingSetMethodImplementation(notifyingInfo, @selector(class), (IMP)NSKVOClass, NULL);
    
    return notifyingInfo;
}

NSKeyValueNotifyingInfo *_NSKeyValueContainerClassGetNotifyingInfo(NSKeyValueContainerClass *containerClass) {
    if(!containerClass.notifyingInfo) {
        if(!class_isMetaClass(containerClass.originalClass)) {
             containerClass.notifyingInfo = _NSKVONotifyingCreateInfoWithOriginalClass(containerClass.originalClass);;
        }
    }
    return containerClass.notifyingInfo;
}

Class _NSKVONotifyingOriginalClassForIsa(Class isa) {
    if(class_getMethodImplementation(isa, ISKVOASelector) == (IMP)NSKVOIsAutonotifying) {
        void *ivars = object_getIndexedIvars(isa);
        return ((NSKeyValueNotifyingInfo *)ivars)->originalClass;
    }
    return isa;
}


BOOL _NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key) {
    IMP imp =  class_getMethodImplementation(isa, ISKVOASelector);
    if(imp == (IMP)NSKVOIsAutonotifying) {
        NSKeyValueNotifyingInfo *info = (NSKeyValueNotifyingInfo *)object_getIndexedIvars(isa);
        pthread_mutex_lock(&info->mutex);
        BOOL contains = CFSetContainsValue(info->keys, (CFTypeRef)key);
        pthread_mutex_unlock(&info->mutex);
        return contains;
    }
    return NO;
}

NSKeyValueContainerClass * _NSKeyValueContainerClassForIsa(Class isa) {
    static void * isaCacheKey = NULL;
    static CFMutableDictionaryRef NSKeyValueContainerClassPerOriginalClass = NULL;
    static NSKeyValueContainerClass * cachedContainerClass = NULL;

    if(isa != isaCacheKey) {
        Class originClass  = _NSKVONotifyingOriginalClassForIsa(isa);
        NSKeyValueContainerClass * containerClass = nil;
        if(NSKeyValueContainerClassPerOriginalClass) {
            containerClass = CFDictionaryGetValue(NSKeyValueContainerClassPerOriginalClass, originClass);
        }
        else {
            NSKeyValueContainerClassPerOriginalClass = CFDictionaryCreateMutable(NULL,0,NULL,&kCFTypeDictionaryValueCallBacks);
        }

        if (!containerClass) {
            containerClass = [[NSKeyValueContainerClass alloc] initWithOriginalClass:originClass];
            CFDictionarySetValue(NSKeyValueContainerClassPerOriginalClass, originClass, containerClass);
        }
        
        isaCacheKey = isa;
        cachedContainerClass = containerClass;
    }
    
    return cachedContainerClass;
}


void NSKVOForwardInvocation(id object, SEL selector, void *param) {
    
}

const char *NSKVOOriginalImplementationSelectorForSelector_originalImplementationMethodNamePrefix = "_original_";

void _NSKVONotifyingEnableForInfoAndKey(NSKeyValueNotifyingInfo *info, NSString *key) {
    pthread_mutex_lock(&info->mutex);
    CFSetAddValue(info->keys, (CFStringRef)key);
    pthread_mutex_unlock(&info->mutex);
    
    NSKeyValueSetter * setter = _NSKeyValueSetterForClassAndKey(info->originalClass, key, info->originalClass);
    if([setter isKindOfClass: [NSKeyValueMethodSetter class]]) {
        Method setMethod = [(NSKeyValueMethodSetter *)setter method];
        const char *encoding = method_getTypeEncoding(setMethod);
        if (*encoding == 'v') {
            char *argType = method_copyArgumentType(setMethod, 2);
            IMP imp = NULL;
            switch (*argType) {
                case 'c': {
                    imp = (IMP)_NSSetCharValueAndNotify;
                } break;
                case 'd': {
                    imp = (IMP)_NSSetDoubleValueAndNotify;
                } break;
                case 'f': {
                    imp = (IMP)_NSSetFloatValueAndNotify;
                } break;
                case 'i': {
                    imp = (IMP)_NSSetIntValueAndNotify;
                } break;
                case 'l': {
                    imp = (IMP)_NSSetLongValueAndNotify;
                } break;
                case 'q': {
                    imp = (IMP)_NSSetLongLongValueAndNotify;
                } break;
                case 's': {
                    imp = (IMP)_NSSetShortValueAndNotify;
                } break;
                case 'S': {
                    imp = (IMP)_NSSetUnsignedShortValueAndNotify;
                } break;
                case '{': {
                    if(strcmp(argType, "{CGPoint=ff}") ==0) {
                        imp = (IMP)_NSSetPointValueAndNotify;
                    }
                    else if (strcmp(argType, "{_NSPoint=ff}") == 0) {
                        imp = (IMP)_NSSetPointValueAndNotify;
                    }
                    else if (strcmp (argType, "{_NSRange=II}") == 0) {
                        imp = (IMP)_NSSetRangeValueAndNotify;
                    }
                    else if (strcmp(argType,"{CGRect={CGPoint=ff}{CGSize=ff}}") == 0) {
                        imp = (IMP)_NSSetRectValueAndNotify;
                    }
                    else if (strcmp(argType,"{_NSRect={_NSPoint=ff}{_NSSize=ff}}") == 0) {
                        imp = (IMP)_NSSetRectValueAndNotify;
                    }
                    else if(strcmp(argType, "{CGSize=ff}") == 0) {
                        imp = (IMP)_NSSetSizeValueAndNotify;
                    }
                    else if (strcmp(argType, "{_NSSize=ff}") == 0) {
                        imp = (IMP)_NSSetSizeValueAndNotify;
                    }
                    else {
                        imp = (IMP)_CF_forwarding_prep_0;
                    }
                } break;
                case 'B': {
                    imp = (IMP)_NSSetBoolValueAndNotify;
                } break;
                case 'C': {
                    imp = (IMP)_NSSetUnsignedCharValueAndNotify;
                } break;
                case 'I': {
                    imp = (IMP)_NSSetUnsignedIntValueAndNotify;
                } break;
                case 'L': {
                    imp = (IMP)_NSSetUnsignedLongValueAndNotify;
                } break;
                case 'Q': {
                    imp = (IMP)_NSSetUnsignedLongLongValueAndNotify;
                } break;
                case '#': {
                    imp = (IMP)_NSSetObjectValueAndNotify;
                } break;
                default: {
                    //
                } break;
            }
            
            if (imp) {
                free(argType);
                
                SEL setMethodSelector = method_getName(setMethod);
                NSKVONotifyingSetMethodImplementation(info, setMethodSelector, imp, key);
                
                if (imp == (IMP)_CF_forwarding_prep_0) {
                    NSKVONotifyingSetMethodImplementation(info, @selector(forwardInvocation:), (IMP)NSKVOForwardInvocation, nil);
                    
                    const char *setMethodSelectorName = sel_getName(setMethodSelector);
                    size_t setMethodSelectorNameLen = strlen(setMethodSelectorName);
                    char prefixedName[setMethodSelectorNameLen + 11];
                    strlcpy(prefixedName,
                            NSKVOOriginalImplementationSelectorForSelector_originalImplementationMethodNamePrefix,
                            setMethodSelectorNameLen + 11);
                    strlcat(prefixedName, setMethodSelectorName, setMethodSelectorNameLen + 11);
                    
                    class_addMethod(info->containerClass, sel_registerName(prefixedName), method_getImplementation(setMethod), method_getTypeEncoding(setMethod));
                }
            }
            else {
                free(argType);
                NSLog(@"KVO autonotifying only supports -set<Key>: methods that take id, \
                      NSNumber-supported scalar types, and some NSValue-supported structure \
                      types. Autonotifying will not be done for invocations of -[%s %s].",
                      class_getName(info->originalClass), sel_getName(method_getName(setMethod))
                      );
            }
        }
        else {
            NSLog(@"KVO autonotifying only supports -set<Key>: \
                  methods that return void. Autonotifying will not be done for invocations of -[%s %s].",
                  class_getName(info->originalClass), sel_getName(method_getName(setMethod)));
        }
    }
    
    NSKeyValueGetter* getter = _NSKeyValueMutableArrayGetterForIsaAndKey(info->originalClass, key);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        NSKeyValueMutatingArrayMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.insertObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectAtIndex),(IMP)NSKVOInsertObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.insertObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectsAtIndexes),(IMP)NSKVOInsertObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.removeObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectAtIndex),(IMP)NSKVORemoveObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.removeObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectsAtIndexes),(IMP)NSKVORemoveObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.replaceObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectAtIndex),(IMP)NSKVOReplaceObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.replaceObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectsAtIndexes),(IMP)NSKVOReplaceObjectsAtIndexesAndNotify,key);
            }
        }
    }
    
    getter = _NSKeyValueMutableOrderedSetGetterForIsaAndKey(info->originalClass, key);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        NSKeyValueMutatingOrderedSetMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.insertObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectAtIndex),(IMP)NSKVOInsertObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.insertObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectsAtIndexes),(IMP)NSKVOInsertObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.removeObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectAtIndex),(IMP)NSKVORemoveObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.removeObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectsAtIndexes),(IMP)NSKVORemoveObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.replaceObjectAtIndex) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectAtIndex),(IMP)NSKVOReplaceObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.replaceObjectsAtIndexes) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectsAtIndexes),(IMP)NSKVOReplaceObjectsAtIndexesAndNotify,key);
            }
        }
    }
    
    getter = _NSKeyValueMutableSetGetterForClassAndKey(info->originalClass, key, info->originalClass);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        NSKeyValueMutatingSetMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.addObject) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.addObject),(IMP)NSKVOAddObjectAndNotify,key);
            }
            if(mutatingMethods.intersectSet) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.intersectSet),(IMP)NSKVOIntersectSetAndNotify,key);
            }
            if(mutatingMethods.minusSet) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.minusSet),(IMP)NSKVOMinusSetAndNotify,key);
            }
            if(mutatingMethods.removeObject) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObject),(IMP)NSKVORemoveObjectAndNotify,key);
            }
            if(mutatingMethods.unionSet) {
                NSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.unionSet),(IMP)NSKVOUnionSetAndNotify,key);
            }
        }
    }
    
    _NSKeyValueInvalidateCachedMutatorsForIsaAndKey(info->containerClass, key);
}
