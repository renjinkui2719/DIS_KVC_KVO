//
//  DSKeyValueChangeDictionary.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueChangeDictionary.h"
#import <libkern/OSAtomic.h>

static inline NSNumber* DSKeyValueChangeDictionaryNumberWithKind(DSKeyValueChange kind) {
    NSNumber *numbersByKind[] = { (NSNumber*)0x0FEEDFACE,nil,nil,nil,nil,(NSNumber*)0x0FEEDFACE};
    NSNumber *number = [[NSNumber alloc] initWithInteger:kind];
    if(!OSAtomicCompareAndSwapPtr(NULL, number, (void **)(numbersByKind + kind))) {
        [number release];
    }
    return numbersByKind[kind];
}


@implementation DSKeyValueChangeDictionary

- (id)initWithDetailsNoCopy:(DSKeyValueChangeDetails)details originalObservable:(id)originalObservable isPriorNotification:(BOOL)isPriorNotification {
    if(self = [super init]) {
        _details = details;
        _originalObservable = originalObservable;
        _isPriorNotification = isPriorNotification;
    }
    return self;
}

- (void)dealloc {
    if(_isRetainingObjects) {
        [_details.oldValue release];
        [_details.newValue release];
        [_details.indexes release];
        [_originalObservable release];
    }
    [super dealloc];
}

- (id)objectForKey:(NSString *)aKey {
    if(aKey == DSKeyValueChangeKindKey) {
        return DSKeyValueChangeDictionaryNumberWithKind(_details.kind);
    }
    else if(aKey == DSKeyValueChangeNewKey) {
        return _details.newValue;
    }
    else if(aKey == DSKeyValueChangeOldKey) {
        return _details.oldValue;
    }
    else if(aKey == DSKeyValueChangeIndexesKey) {
        return _details.indexes;
    }
    else if(aKey == DSKeyValueChangeOriginalObservableKey) {
        return _originalObservable;
    }
    else if(aKey == DSKeyValueChangeNotificationIsPriorKey && _isPriorNotification) {
        return (id)kCFBooleanTrue;
    }
    else {
        if([aKey isEqualToString:DSKeyValueChangeKindKey]) {
            return DSKeyValueChangeDictionaryNumberWithKind(_details.kind);
        }
        else if([aKey isEqualToString:DSKeyValueChangeNewKey]) {
            return _details.newValue;
        }
        else if([aKey isEqualToString:DSKeyValueChangeOldKey]) {
            return _details.oldValue;
        }
        else if([aKey isEqualToString:DSKeyValueChangeIndexesKey]) {
            return _details.indexes;
        }
        else if([aKey isEqualToString:DSKeyValueChangeOriginalObservableKey]) {
            return _originalObservable;
        }
        else if([aKey isEqualToString:DSKeyValueChangeNotificationIsPriorKey]) {
            return _isPriorNotification ? (id)kCFBooleanTrue : nil;
        }
    }
    
    return nil;
}

- (void)setDetailsNoCopy:(DSKeyValueChangeDetails)details originalObservable:(id)originalObservable {
    if(_isRetainingObjects) {
        [_details.oldValue release];
        [_details.newValue release];
        [_details.indexes release];
        [_originalObservable release];
        _isRetainingObjects = NO;
    }
    _details = details;
    _originalObservable = originalObservable;
}

- (void)setOriginalObservable:(id)originalObservable {
    if(_originalObservable != originalObservable) {
        if(_isRetainingObjects) {
            [_originalObservable release];
        }
        _originalObservable = originalObservable;
        if(_isRetainingObjects) {
            [originalObservable retain];
        }
    }
}

- (NSUInteger)count {
    return 1                       +
    (_details.oldValue ? 1 : 0)    +
    (_details.newValue ? 1 : 0)    +
    (_details.indexes ? 1 : 0)     +
    (_originalObservable ? 1 : 0)  +
    (_isPriorNotification ? 1 : 0) ;
}


- (id)keyEnumerator {
    NSUInteger count = 0;
    NSString *keys[6];
    
    keys[count++] =  DSKeyValueChangeKindKey;
    if(_details.oldValue) {
        keys[count++] =  DSKeyValueChangeOldKey;
    }
    if(_details.newValue) {
        keys[count++] =  DSKeyValueChangeNewKey;
    }
    if(_details.indexes) {
        keys[count++] =  DSKeyValueChangeIndexesKey;
    }
    if(_originalObservable) {
        keys[count++] =  DSKeyValueChangeOriginalObservableKey;
    }
    if(_isPriorNotification) {
        keys[count++] =  DSKeyValueChangeNotificationIsPriorKey;
    }
    
    NSEnumerator *enumerator = nil;
    NSArray *keysArray = [[NSArray alloc] initWithObjects:keys count:count];
    enumerator = keysArray.objectEnumerator;
    [keysArray release];
    return enumerator;
}


- (void)retainObjects {
    if(!_isRetainingObjects) {
        [_details.oldValue retain];
        [_details.newValue retain];
        [_details.indexes retain];
        [_originalObservable retain];
        _isRetainingObjects = YES;
    }
}

@end
