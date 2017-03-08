#import "NSKeyValueContainerClass.h"
#import "NSKeyValueObservationInfo.h"
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
    CFDictionaryRemoveValue(NSKeyValueObservationInfoPerObject, ~(NSUInteger)(void *)object);
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
            CFDictionarySetValue(info->selMap,key, sel);
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
    notifyingInfo->selMap = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    
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

