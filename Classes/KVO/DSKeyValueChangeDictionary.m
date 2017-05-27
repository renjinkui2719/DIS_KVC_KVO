//
//  DSKeyValueChangeDictionary.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/13.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueChangeDictionary.h"
#import <libkern/OSAtomic.h>

NSString * const NSKeyValueChangeOriginalObservableKey = @"originalObservable";

static inline NSNumber* DSKeyValueChangeDictionaryNumberWithKind(NSKeyValueChange kind) {
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
    if(aKey == NSKeyValueChangeKindKey) {
        return DSKeyValueChangeDictionaryNumberWithKind(_details.kind);
    }
    else if(aKey == NSKeyValueChangeNewKey) {
        return _details.newValue;
    }
    else if(aKey == NSKeyValueChangeOldKey) {
        return _details.oldValue;
    }
    else if(aKey == NSKeyValueChangeIndexesKey) {
        return _details.indexes;
    }
    else if(aKey == NSKeyValueChangeOriginalObservableKey) {
        return _originalObservable;
    }
    else if(aKey == NSKeyValueChangeNotificationIsPriorKey && _isPriorNotification) {
        return (id)kCFBooleanTrue;
    }
    else {
        if([aKey isEqualToString:NSKeyValueChangeKindKey]) {
            return DSKeyValueChangeDictionaryNumberWithKind(_details.kind);
        }
        else if([aKey isEqualToString:NSKeyValueChangeNewKey]) {
            return _details.newValue;
        }
        else if([aKey isEqualToString:NSKeyValueChangeOldKey]) {
            return _details.oldValue;
        }
        else if([aKey isEqualToString:NSKeyValueChangeIndexesKey]) {
            return _details.indexes;
        }
        else if([aKey isEqualToString:NSKeyValueChangeOriginalObservableKey]) {
            return _originalObservable;
        }
        else if([aKey isEqualToString:NSKeyValueChangeNotificationIsPriorKey]) {
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
    
    keys[count++] =  NSKeyValueChangeKindKey;
    if(_details.oldValue) {
        keys[count++] =  NSKeyValueChangeOldKey;
    }
    if(_details.newValue) {
        keys[count++] =  NSKeyValueChangeNewKey;
    }
    if(_details.indexes) {
        keys[count++] =  NSKeyValueChangeIndexesKey;
    }
    if(_originalObservable) {
        keys[count++] =  NSKeyValueChangeOriginalObservableKey;
    }
    if(_isPriorNotification) {
        keys[count++] =  NSKeyValueChangeNotificationIsPriorKey;
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
