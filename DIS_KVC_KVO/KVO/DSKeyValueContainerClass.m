#import "DSKeyValueContainerClass.h"
#import "DSKeyValueObservationInfo.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueObservingCustomization.h"
#import "DSSetValueAndNotify.h"
#import "DSKeyValueGetter.h"
#import "DSKeyValueSetter.h"
#import "DSKeyValueMethodSetter.h"
#import "DSKeyValueMutatingArrayMethodSet.h"
#import "DSKeyValueMutatingOrderedSetMethodSet.h"
#import "DSKeyValueMutatingSetMethodSet.h"
#import "DSKeyValueObserverCommon.h"


@implementation DSKeyValueContainerClass

- (id)initWithOriginalClass:(Class)originalClass {
    if(self = [super init]) {
        _originalClass = originalClass;
        
        _cachedObservationInfoImplementation = (void * (*)(id,SEL))class_getMethodImplementation(originalClass,sel_registerName("observationInfo"));
        
        Method method = class_getInstanceMethod(_originalClass, sel_registerName("setObservationInfo:"));
        _cachedSetObservationInfoImplementation = (void  (*)(id,SEL, void *))method_getImplementation(method);
        
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
        notifyingClass = @"not cached yet".class;
    }
    return [NSString stringWithFormat:@"<%@: Original class: %@, Notifying class: %@>",self.class, _originalClass,notifyingClass];
}

@end

DSKeyValueObservationInfo *_DSKeyValueRetainedObservationInfoForObject(id object, DSKeyValueContainerClass *containerClass) {
    DSKeyValueObservationInfo *observationInfo = nil;
    
    os_lock_lock(&DSKeyValueObservationInfoSpinLock);
    if (containerClass) {
       observationInfo = ((DSKeyValueObservationInfo * (*)(id,SEL))containerClass.cachedObservationInfoImplementation)(object, @selector(observationInfo));
    }
    else {
        observationInfo = (DSKeyValueObservationInfo *)[object observationInfo];
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
    CFDictionaryRemoveValue(DSKeyValueObservationInfoPerObject, (void*)~(NSUInteger)(void *)object);
    os_lock_unlock(&DSKeyValueObservationInfoSpinLock);
}

BOOL DSKVOIsAutonotifying() {
    return YES;
}

Class DSKVOClass(id object, SEL selector) {
    Class objClass = object_getClass(object);
    Class originalClass =  _DSKVONotifyingOriginalClassForIsa(objClass);
    if (objClass == originalClass) {
        Method m = class_getInstanceMethod(objClass, selector);
        return ((id (*)(id,Method))method_invoke)(object, m);
    }
    else {
        return [originalClass class];
    }
}

void DSKVODeallocateBreak(id object) {
    if (!object) {
        NSLog(@"");
    }
}

void DSKVODeallocate(id object, SEL selector) {
    DSKeyValueObservationInfo *observationInfo = _DSKeyValueRetainedObservationInfoForObject(object, nil);
    ObservationInfoWatcher watcher = {object, observationInfo, NULL};
    _DSKeyValueAddObservationInfoWatcher(&watcher);
    DSKeyValueNotifyingInfo *notifyInfo = (DSKeyValueNotifyingInfo *)object_getIndexedIvars(object_getClass(object));
    Method originDellocMethod = class_getInstanceMethod(notifyInfo->originalClass, selector);
    ((id (*)(id,Method))method_invoke)(object, originDellocMethod);
    
    if(observationInfo) {
        Boolean keyExistsAndHasValidFormat = false;
        Boolean NSKVODeallocateCleansUpBeforeThrowing = false;
        
        NSKVODeallocateCleansUpBeforeThrowing = CFPreferencesGetAppBooleanValue(CFSTR("NSKVODeallocateCleansUpBeforeThrowing"), kCFPreferencesCurrentApplication, &keyExistsAndHasValidFormat);
        
        if (!NSKVODeallocateCleansUpBeforeThrowing) {
            NSKVODeallocateCleansUpBeforeThrowing = true;
        }
        
        if(!keyExistsAndHasValidFormat) {
            keyExistsAndHasValidFormat = true;
        }
        
        if(dyld_get_program_sdk_version() > 0x7FFFF || !(keyExistsAndHasValidFormat || NSKVODeallocateCleansUpBeforeThrowing)) {
            if(!(keyExistsAndHasValidFormat || NSKVODeallocateCleansUpBeforeThrowing)) {
                _DSKeyValueRemoveObservationInfoForObject(object, observationInfo);
            }
            [NSException raise:NSInternalInconsistencyException format:@"An instance %p of class %@ was deallocated while key value observers were still registered with it. Current observation info: %@", object, notifyInfo->originalClass, observationInfo];
        }
        else {
            NSLog(@"An instance %p of class %@ was deallocated while key value observers were still registered with it. Observation info was leaked, and may even become mistakenly attached to some other object. Set a breakpoint on NSKVODeallocateBreak to stop here in the debugger. Here's the current observation info:\n%@", object, notifyInfo->originalClass, observationInfo);
            DSKVODeallocateBreak(object);
        }
    }

    _DSKeyValueRemoveObservationInfoWatcher(&watcher);
    [observationInfo release];
}

void DSKVONotifyingSetMethodImplementation(DSKeyValueNotifyingInfo *info, SEL sel, IMP imp, NSString *key) {
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

DSKeyValueNotifyingInfo *_DSKVONotifyingCreateInfoWithOriginalClass(Class originalClass) {
    static const char *notifyingClassNamePrefix = "DSKVONotifying_";
    
    static IMP DSObjectWillChange;
    static IMP DSObjectDidChange;
    
    const char *originalClassName = class_getName(originalClass);
    size_t size = strlen(originalClassName) + 16;
    char *newClassName = (char *)malloc(size);
    
    strlcpy(newClassName, notifyingClassNamePrefix, size);
    strlcat(newClassName, originalClassName, size);
    
    Class containerClass = objc_allocateClassPair(originalClass, newClassName, sizeof(DSKeyValueNotifyingInfo));
    objc_registerClassPair(containerClass);
    
    free(newClassName);
    
    unsigned char *ivars = object_getIndexedIvars(containerClass);
    DSKeyValueNotifyingInfo *notifyingInfo = (DSKeyValueNotifyingInfo *)ivars;
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
        DSObjectWillChange = class_getMethodImplementation([NSObject class], @selector(d_willChangeValueForKey:));
        DSObjectDidChange = class_getMethodImplementation([NSObject class], @selector(d_didChangeValueForKey:));
    });
    
    BOOL flag = YES;
    if(class_getMethodImplementation(notifyingInfo->originalClass, @selector(d_willChangeValueForKey:)) == DSObjectWillChange) {
        flag = class_getMethodImplementation(notifyingInfo->originalClass, @selector(d_didChangeValueForKey:)) != DSObjectDidChange;
    }
    notifyingInfo->flag = flag;
    
    DSKVONotifyingSetMethodImplementation(notifyingInfo, ISKVOASelector, (IMP)DSKVOIsAutonotifying, NULL);
    DSKVONotifyingSetMethodImplementation(notifyingInfo, @selector(dealloc), (IMP)DSKVODeallocate, NULL);
    DSKVONotifyingSetMethodImplementation(notifyingInfo, @selector(class), (IMP)DSKVOClass, NULL);
    
    return notifyingInfo;
}

DSKeyValueNotifyingInfo *_DSKeyValueContainerClassGetNotifyingInfo(DSKeyValueContainerClass *containerClass) {
    if(!containerClass.notifyingInfo) {
        if(!class_isMetaClass(containerClass.originalClass)) {
             containerClass.notifyingInfo = _DSKVONotifyingCreateInfoWithOriginalClass(containerClass.originalClass);;
        }
    }
    return containerClass.notifyingInfo;
}

Class _DSKVONotifyingOriginalClassForIsa(Class isa) {
    if(class_getMethodImplementation(isa, ISKVOASelector) == (IMP)DSKVOIsAutonotifying) {
        void *ivars = object_getIndexedIvars(isa);
        return ((DSKeyValueNotifyingInfo *)ivars)->originalClass;
    }
    return isa;
}


BOOL _DSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key) {
    IMP imp =  class_getMethodImplementation(isa, ISKVOASelector);
    if(imp == (IMP)DSKVOIsAutonotifying) {
        DSKeyValueNotifyingInfo *info = (DSKeyValueNotifyingInfo *)object_getIndexedIvars(isa);
        pthread_mutex_lock(&info->mutex);
        BOOL contains = CFSetContainsValue(info->keys, (CFTypeRef)key);
        pthread_mutex_unlock(&info->mutex);
        return contains;
    }
    return NO;
}

DSKeyValueContainerClass * _DSKeyValueContainerClassForIsa(Class isa) {
    static void * isaCacheKey = NULL;
    static CFMutableDictionaryRef DSKeyValueContainerClassPerOriginalClass = NULL;
    static DSKeyValueContainerClass * cachedContainerClass = NULL;

    if(isa != isaCacheKey) {
        Class originClass  = _DSKVONotifyingOriginalClassForIsa(isa);
        DSKeyValueContainerClass * containerClass = nil;
        if(DSKeyValueContainerClassPerOriginalClass) {
            containerClass = CFDictionaryGetValue(DSKeyValueContainerClassPerOriginalClass, originClass);
        }
        else {
            DSKeyValueContainerClassPerOriginalClass = CFDictionaryCreateMutable(NULL,0,NULL,&kCFTypeDictionaryValueCallBacks);
        }

        if (!containerClass) {
            containerClass = [[DSKeyValueContainerClass alloc] initWithOriginalClass:originClass];
            CFDictionarySetValue(DSKeyValueContainerClassPerOriginalClass, originClass, containerClass);
        }
        
        isaCacheKey = isa;
        cachedContainerClass = containerClass;
    }
    
    return cachedContainerClass;
}


void DSKVOForwardInvocation(id object, SEL selector, void *param) {
    
}

const char *DSKVOOriginalImplementationSelectorForSelector_originalImplementationMethodNamePrefix = "_original_";

void _DSKVONotifyingEnableForInfoAndKey(DSKeyValueNotifyingInfo *info, NSString *key) {
    pthread_mutex_lock(&info->mutex);
    CFSetAddValue(info->keys, (CFStringRef)key);
    pthread_mutex_unlock(&info->mutex);
    
    DSKeyValueSetter * setter = _DSKeyValueSetterForClassAndKey(info->originalClass, key, info->originalClass);
    if([setter isKindOfClass: [DSKeyValueMethodSetter class]]) {
        Method setMethod = [(DSKeyValueMethodSetter *)setter method];
        const char *encoding = method_getTypeEncoding(setMethod);
        if (*encoding == 'v') {
            char *argType = method_copyArgumentType(setMethod, 2);
            IMP imp = NULL;
            switch (*argType) {
                case 'c': {
                    imp = (IMP)_DSSetCharValueAndNotify;
                } break;
                case 'd': {
                    imp = (IMP)_DSSetDoubleValueAndNotify;
                } break;
                case 'f': {
                    imp = (IMP)_DSSetFloatValueAndNotify;
                } break;
                case 'i': {
                    imp = (IMP)_DSSetIntValueAndNotify;
                } break;
                case 'l': {
                    imp = (IMP)_DSSetLongValueAndNotify;
                } break;
                case 'q': {
                    imp = (IMP)_DSSetLongLongValueAndNotify;
                } break;
                case 's': {
                    imp = (IMP)_DSSetShortValueAndNotify;
                } break;
                case 'S': {
                    imp = (IMP)_DSSetUnsignedShortValueAndNotify;
                } break;
                case '{': {
                    if(strcmp(argType, "{CGPoint=ff}") ==0) {
                        imp = (IMP)_DSSetPointValueAndNotify;
                    }
                    else if (strcmp(argType, "{_NSPoint=ff}") == 0) {
                        imp = (IMP)_DSSetPointValueAndNotify;
                    }
                    else if (strcmp (argType, "{_NSRange=II}") == 0) {
                        imp = (IMP)_DSSetRangeValueAndNotify;
                    }
                    else if (strcmp(argType,"{CGRect={CGPoint=ff}{CGSize=ff}}") == 0) {
                        imp = (IMP)_DSSetRectValueAndNotify;
                    }
                    else if (strcmp(argType,"{_NSRect={_NSPoint=ff}{_NSSize=ff}}") == 0) {
                        imp = (IMP)_DSSetRectValueAndNotify;
                    }
                    else if(strcmp(argType, "{CGSize=ff}") == 0) {
                        imp = (IMP)_DSSetSizeValueAndNotify;
                    }
                    else if (strcmp(argType, "{_NSSize=ff}") == 0) {
                        imp = (IMP)_DSSetSizeValueAndNotify;
                    }
                    else {
                        imp = (IMP)_CF_forwarding_prep_0;
                    }
                } break;
                case 'B': {
                    imp = (IMP)_DSSetBoolValueAndNotify;
                } break;
                case 'C': {
                    imp = (IMP)_DSSetUnsignedCharValueAndNotify;
                } break;
                case 'I': {
                    imp = (IMP)_DSSetUnsignedIntValueAndNotify;
                } break;
                case 'L': {
                    imp = (IMP)_DSSetUnsignedLongValueAndNotify;
                } break;
                case 'Q': {
                    imp = (IMP)_DSSetUnsignedLongLongValueAndNotify;
                } break;
                case '#': {
                    imp = (IMP)_DSSetObjectValueAndNotify;
                } break;
                default: {
                    //
                } break;
            }
            
            if (imp) {
                free(argType);
                
                SEL setMethodSelector = method_getName(setMethod);
                DSKVONotifyingSetMethodImplementation(info, setMethodSelector, imp, key);
                
                if (imp == (IMP)_CF_forwarding_prep_0) {
                    DSKVONotifyingSetMethodImplementation(info, @selector(forwardInvocation:), (IMP)DSKVOForwardInvocation, nil);
                    
                    const char *setMethodSelectorName = sel_getName(setMethodSelector);
                    size_t setMethodSelectorNameLen = strlen(setMethodSelectorName);
                    char prefixedName[setMethodSelectorNameLen + 11];
                    strlcpy(prefixedName,
                            DSKVOOriginalImplementationSelectorForSelector_originalImplementationMethodNamePrefix,
                            setMethodSelectorNameLen + 11);
                    strlcat(prefixedName, setMethodSelectorName, setMethodSelectorNameLen + 11);
                    
                    class_addMethod(info->containerClass, sel_registerName(prefixedName), method_getImplementation(setMethod), method_getTypeEncoding(setMethod));
                }
            }
            else {
                free(argType);
                NSLog(@"KVO autonotifyin only supports -set<Key>: methods that take id, \
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
    
    DSKeyValueGetter* getter = _DSKeyValueMutableArrayGetterForIsaAndKey(info->originalClass, key);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        DSKeyValueMutatingArrayMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.insertObjectAtIndex) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectAtIndex),(IMP)DSKVOInsertObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.insertObjectsAtIndexes) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectsAtIndexes),(IMP)DSKVOInsertObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.removeObjectAtIndex) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectAtIndex),(IMP)DSKVORemoveObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.removeObjectsAtIndexes) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectsAtIndexes),(IMP)DSKVORemoveObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.replaceObjectAtIndex) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectAtIndex),(IMP)DSKVOReplaceObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.replaceObjectsAtIndexes) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectsAtIndexes),(IMP)DSKVOReplaceObjectsAtIndexesAndNotify,key);
            }
        }
    }
    
    getter = _DSKeyValueMutableOrderedSetGetterForIsaAndKey(info->originalClass, key);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        DSKeyValueMutatingOrderedSetMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.insertObjectAtIndex) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectAtIndex),(IMP)DSKVOInsertObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.insertObjectsAtIndexes) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.insertObjectsAtIndexes),(IMP)DSKVOInsertObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.removeObjectAtIndex) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectAtIndex),(IMP)DSKVORemoveObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.removeObjectsAtIndexes) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObjectsAtIndexes),(IMP)DSKVORemoveObjectsAtIndexesAndNotify,key);
            }
            if(mutatingMethods.replaceObjectAtIndex) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectAtIndex),(IMP)DSKVOReplaceObjectAtIndexAndNotify,key);
            }
            if(mutatingMethods.replaceObjectsAtIndexes) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.replaceObjectsAtIndexes),(IMP)DSKVOReplaceObjectsAtIndexesAndNotify,key);
            }
        }
    }
    
    getter = _DSKeyValueMutableSetGetterForClassAndKey(info->originalClass, key, info->originalClass);
    if([getter respondsToSelector:@selector(mutatingMethods)]) {
        DSKeyValueMutatingSetMethodSet *mutatingMethods = [getter mutatingMethods];
        if(mutatingMethods) {
            if(mutatingMethods.addObject) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.addObject),(IMP)DSKVOAddObjectAndNotify,key);
            }
            if(mutatingMethods.intersectSet) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.intersectSet),(IMP)DSKVOIntersectSetAndNotify,key);
            }
            if(mutatingMethods.minusSet) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.minusSet),(IMP)DSKVOMinusSetAndNotify,key);
            }
            if(mutatingMethods.removeObject) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.removeObject),(IMP)DSKVORemoveObjectAndNotify,key);
            }
            if(mutatingMethods.unionSet) {
                DSKVONotifyingSetMethodImplementation(info,method_getName(mutatingMethods.unionSet),(IMP)DSKVOUnionSetAndNotify,key);
            }
        }
    }
    
    _DSKeyValueInvalidateCachedMutatorsForIsaAndKey(info->containerClass, key);
}
