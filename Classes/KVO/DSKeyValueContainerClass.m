#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "DSKeyValueContainerClass.h"
#import "DSKeyValueObservationInfo.h"
#import "NSObject+DSKeyValueObservingPrivate.h"
#import "NSObject+DSKeyValueCodingPrivate.h"
#import "NSObject+DSKeyValueObservingCustomization.h"
#import "NSObject+DSKeyValueObserverNotification.h"
#import "DSSetValueAndNotify.h"
#import "DSKeyValueGetter.h"
#import "DSKeyValueSetter.h"
#import "DSKeyValueMethodSetter.h"
#import "DSKeyValueFastMutableCollection1Getter.h"
#import "DSKeyValueFastMutableCollection2Getter.h"
#import "DSKeyValueMutatingSetMethodSet.h"
#import "DSKeyValueMutatingOrderedSetMethodSet.h"
#import "DSKeyValueMutatingArrayMethodSet.h"
#import "DSKeyValueObserverCommon.h"


@implementation DSKeyValueContainerClass

- (id)initWithOriginalClass:(Class)originalClass {
    if(self = [super init]) {
        _originalClass = originalClass;
        
        _cachedObservationInfoImplementation = (void * (*)(id,SEL))class_getMethodImplementation(originalClass,sel_registerName("d_observationInfo"));
        
        Method setMethod = class_getInstanceMethod(_originalClass, sel_registerName("d_setObservationInfo:"));
        _cachedSetObservationInfoImplementation = (void  (*)(id,SEL, void *))method_getImplementation(setMethod);
        
        char argType = 0;
        method_getArgumentType(setMethod, 2, &argType, 1);
        if (argType == '@') {
            _cachedSetObservationInfoTakesAnObject = YES;
        }
    }
    return self;
}

- (id)description {
    Class notifyingClass = NULL;
    if(_notifyingInfo) {
        notifyingClass = _notifyingInfo->newSubClass;
    }
    else {
        notifyingClass = @"not cached yet".class;
    }
    return [NSString stringWithFormat:@"<%@: Original class: %@, Notifying class: %@>",self.class, _originalClass,notifyingClass];
}

@end


BOOL DSKVOIsAutonotifying() {
    return YES;
}

Class DSKVOClass(id object, SEL selector) {
    Class currentClass = object_getClass(object);
    Class originalClass =  _DSKVONotifyingOriginalClassForIsa(currentClass);
    if (currentClass == originalClass) {
        Method m = class_getInstanceMethod(currentClass, selector);
        return ((Class (*)(id,Method))method_invoke)(object, m);
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
    
    @try {
        if(watcher.observationInfo) {
            BOOL keyExistsAndHasValidFormat = false;
            BOOL cleansUpBeforeThrowing = false;
            
            cleansUpBeforeThrowing = (BOOL)CFPreferencesGetAppBooleanValue(CFSTR("NSKVODeallocateCleansUpBeforeThrowing"), kCFPreferencesCurrentApplication, (Boolean *)&keyExistsAndHasValidFormat);
            
            cleansUpBeforeThrowing = cleansUpBeforeThrowing && keyExistsAndHasValidFormat;
            
            if (dyld_get_program_sdk_version() > 0x7FFFF || cleansUpBeforeThrowing) {
                if (cleansUpBeforeThrowing) {
                    _DSKeyValueRemoveObservationInfoForObject(object, watcher.observationInfo);
                }
                [NSException raise:NSInternalInconsistencyException format:@"An instance %p of class %@ was deallocated while key value observers were still registered with it. Current observation info: %@", object, notifyInfo->originalClass, watcher.observationInfo];
            }
            else {
                NSLog(@"An instance %p of class %@ was deallocated while key value observers were still registered with it. Observation info was leaked, and may even become mistakenly attached to some other object. Set a breakpoint on NSKVODeallocateBreak to stop here in the debugger. Here's the current observation info:\n%@", object, notifyInfo->originalClass, watcher.observationInfo);
                DSKVODeallocateBreak(object);
            }
        }

    }
    @catch (NSException *exception) {
        [exception raise];
    }
    @finally {
        _DSKeyValueRemoveObservationInfoWatcher(&watcher);
        
        [watcher.observationInfo release];
    }    
}

void DSKVONotifyingSetMethodImplementation(DSKeyValueNotifyingInfo *info, SEL sel, IMP imp, NSString *key) {
    Method originMethod = class_getInstanceMethod(info->originalClass, sel);
    if (originMethod) {
        if (key) {
            pthread_mutex_lock(&info->mutex);
            
            CFDictionarySetValue(info->selKeyMap,sel, key);
            
            pthread_mutex_unlock(&info->mutex);
        }
        const char *encoding = method_getTypeEncoding(originMethod);
        class_addMethod(info->newSubClass, sel, imp, encoding);
    }
}

DSKeyValueNotifyingInfo *_DSKVONotifyingCreateInfoWithOriginalClass(Class originalClass) {
    
    static IMP DSObjectWillChange;
    static IMP DSObjectDidChange;
    
    //构造新的子类名
    const char *originalClassName = class_getName(originalClass);
    size_t size = strlen(originalClassName) + 16/*NOTIFY_CLASSNAME_PREFIX长度 + 1('\0')*/;
    char *newClassName = (char *)malloc(size);
    
    strlcpy(newClassName, NOTIFY_CLASSNAME_PREFIX, size);
    strlcat(newClassName, originalClassName, size);
    
    //创建子类
    Class newSubClass = objc_allocateClassPair(originalClass, newClassName, sizeof(DSKeyValueNotifyingInfo));
    objc_registerClassPair(newSubClass);
    
    free(newClassName);
    
    unsigned char *ivars = object_getIndexedIvars(newSubClass);
    DSKeyValueNotifyingInfo *notifyingInfo = (DSKeyValueNotifyingInfo *)ivars;
    notifyingInfo->originalClass = originalClass;
    notifyingInfo->newSubClass = newSubClass;
    notifyingInfo->notifyingKeys = CFSetCreateMutable(NULL, 0, &kCFCopyStringSetCallBacks);
    notifyingInfo->selKeyMap = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    
    pthread_mutexattr_t mutexattr;
    pthread_mutexattr_init(&mutexattr);
    pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&notifyingInfo->mutex, &mutexattr);
    pthread_mutexattr_destroy(&mutexattr);
    
    //获取根类的 willChangeValueForKey 和 didChangeValueForKey实现
    static dispatch_once_t NSObjectIMPLookupOnce;
    dispatch_once(&NSObjectIMPLookupOnce, ^{
        DSObjectWillChange = class_getMethodImplementation([NSObject class], @selector(d_willChangeValueForKey:));
        DSObjectDidChange = class_getMethodImplementation([NSObject class], @selector(d_didChangeValueForKey:));
    });
    
    //originalClass类是否覆写了 willChangeValueForKey: 或  didChangeValueForKey:
    notifyingInfo->overrideWillOrDidChange = class_getMethodImplementation(notifyingInfo->originalClass, @selector(d_willChangeValueForKey:)) != DSObjectWillChange || class_getMethodImplementation(notifyingInfo->originalClass, @selector(d_didChangeValueForKey:)) != DSObjectDidChange;
    //添加子类 _isKVOA方法
    DSKVONotifyingSetMethodImplementation(notifyingInfo, ISKVOA_SELECTOR, (IMP)DSKVOIsAutonotifying, NULL);
    //添加子类 dealloc方法
    DSKVONotifyingSetMethodImplementation(notifyingInfo, @selector(dealloc), (IMP)DSKVODeallocate, NULL);
    //添加子类 class方法
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
    if(class_getMethodImplementation(isa, ISKVOA_SELECTOR) == (IMP)DSKVOIsAutonotifying) {
        void *ivars = object_getIndexedIvars(isa);
        return ((DSKeyValueNotifyingInfo *)ivars)->originalClass;
    }
    return isa;
}

BOOL _DSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key) {
    if(class_getMethodImplementation(isa, ISKVOA_SELECTOR) == (IMP)DSKVOIsAutonotifying) {
        DSKeyValueNotifyingInfo *info = (DSKeyValueNotifyingInfo *)object_getIndexedIvars(isa);
        pthread_mutex_lock(&info->mutex);
        BOOL containsKey = CFSetContainsValue(info->notifyingKeys, (CFTypeRef)key);
        pthread_mutex_unlock(&info->mutex);
        return containsKey;
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

void _DSKVONotifyingEnableForInfoAndKey(DSKeyValueNotifyingInfo *info, NSString *key) {
    pthread_mutex_lock(&info->mutex);
    CFSetAddValue(info->notifyingKeys, (CFStringRef)key);
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
                    if(strcmp(argType, @encode(CGPoint)) ==0) {
                        imp = (IMP)_DSSetPointValueAndNotify;
                    }
#if TARGET_OS_OSX
                    else if (strcmp(argType, @encode(NSPoint)) == 0) {
                        imp = (IMP)_DSSetPointValueAndNotify;
                    }
#endif
                    else if (strcmp (argType, @encode(NSRange)) == 0) {
                        imp = (IMP)_DSSetRangeValueAndNotify;
                    }
                    else if (strcmp(argType,@encode(CGRect)) == 0) {
                        imp = (IMP)_DSSetRectValueAndNotify;
                    }
#if TARGET_OS_OSX
                    else if (strcmp(argType,@encode(NSRect)) == 0) {
                        imp = (IMP)_DSSetRectValueAndNotify;
                    }
#endif
                    else if(strcmp(argType, @encode(CGSize)) == 0) {
                        imp = (IMP)_DSSetSizeValueAndNotify;
                    }
#if TARGET_OS_OSX
                    else if (strcmp(argType, @encode(NSSize)) == 0) {
                        imp = (IMP)_DSSetSizeValueAndNotify;
                    }
#endif
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
                case '#':
                case '@':{
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
                    strlcpy(prefixedName, "_original_", setMethodSelectorNameLen + 11);
                    strlcat(prefixedName, setMethodSelectorName, setMethodSelectorNameLen + 11);
                    
                    class_addMethod(info->newSubClass, sel_registerName(prefixedName), method_getImplementation(setMethod), method_getTypeEncoding(setMethod));
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
        DSKeyValueMutatingArrayMethodSet *mutatingMethods = (DSKeyValueMutatingArrayMethodSet *)[(DSKeyValueFastMutableCollection1Getter/*或者 DSKeyValueFastMutableCollection1Getter,强转仅仅为了消除警告*/ *)getter mutatingMethods];
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
        DSKeyValueMutatingOrderedSetMethodSet *mutatingMethods = (DSKeyValueMutatingOrderedSetMethodSet *)[(DSKeyValueFastMutableCollection1Getter *)getter mutatingMethods];
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
        DSKeyValueMutatingSetMethodSet *mutatingMethods = (DSKeyValueMutatingSetMethodSet *)[(DSKeyValueFastMutableCollection1Getter *)getter mutatingMethods];
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
    
    _DSKeyValueInvalidateCachedMutatorsForIsaAndKey(info->newSubClass, key);
}
