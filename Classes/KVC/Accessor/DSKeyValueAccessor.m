//
//  DSKeyValueAccessor.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import "DSKeyValueAccessor.h"

NSUInteger DSKeyValueAccessorHash(DSKeyValueAccessor *accrssor) {
    return accrssor.hashValue;
}

BOOL DSKeyValueAccessorIsEqual(DSKeyValueAccessor *lhs, DSKeyValueAccessor *rhs) {
    return (lhs.containerClassID == rhs.containerClassID) && (lhs.key == rhs.key || [lhs.key isEqualToString:rhs.key]);
}

@implementation DSKeyValueAccessor

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key implementation:(IMP)implementation selector:(SEL)selector extraArguments:(void *[3])extraArguments count:(NSUInteger)count {
    if (self = [super init]) {
        _containerClassID = containerClassID;
        _key = key.copy;
        _implementation = implementation;
        _selector = selector;
        
        NSUInteger hash = 0;
        if (key) {
            hash = CFHash(key);
        }
        hash ^= (NSUInteger)containerClassID;
        _hashValue = hash;
        
        _extraArgumentCount = count;
        
        _extraArgument1 = extraArguments[0];
        if (_extraArgument1 == key) {
            _extraArgument1 = _key;
        }
        
        _extraArgument2 = extraArguments[1];
        if (_extraArgument2 == key) {
            _extraArgument2 = _key;
        }
        
        _extraArgument3 = extraArguments[2];
    }
    return self;
}

- (void)dealloc {
    [_key release];
    [super dealloc];
}

@end
