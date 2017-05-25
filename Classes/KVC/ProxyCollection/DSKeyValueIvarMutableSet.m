//
//  DSKeyValueIvarMutableSet.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueIvarMutableSet.h"
#import "DSKeyValueNilSetEnumerator.h"
#import "DSKeyValueCodingCommon.h"

@implementation DSKeyValueIvarMutableSet

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    if((self = [super _proxyInitWithContainer:container getter:getter])) {
        _ivar = [getter ivar];
    }
    return self;
}

- (void)_proxyNonGCFinalize {
    _ivar = NULL;
    [super _proxyNonGCFinalize];
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    static DSKeyValueProxyNonGCPoolPointer proxyPool;
    return  &proxyPool;
}

- (NSUInteger)count {
    
    return [object_getIvarDirectly(self.container, _ivar) count];
}

- (id)member:(id)object {
    return [object_getIvarDirectly(self.container, _ivar) member:object];
}

- (NSEnumerator *)objectEnumerator {
    id setValue = object_getIvarDirectly(self.container, _ivar);
    if(setValue) {
        return [setValue objectEnumerator];
    }
    else {
        return [[[DSKeyValueNilSetEnumerator alloc] init] autorelease];
    }
}

- (void)addObject:(id)object {
    id setValue = object_getIvarDirectly(self.container, _ivar);
    if(setValue) {
        [setValue addObject:object];
    }
    else {
        object_setIvarDirectly(self.container, _ivar,  [[NSMutableSet alloc] initWithObjects:&object count:1]);
    }
}

- (void)addObjectsFromArray:(NSArray *)array {
    id setValue = object_getIvarDirectly(self.container, _ivar);
    if(setValue) {
        [setValue addObjectsFromArray:array];
    }
    else {
        object_setIvarDirectly(self.container, _ivar, [[NSMutableSet alloc] initWithArray:array]);
    }
}


- (void)removeAllObjects {
    [object_getIvarDirectly(self.container, _ivar) removeAllObjects];
}

- (void)removeObject:(id)object {
    [object_getIvarDirectly(self.container, _ivar) removeObject: object];
}

- (void)setSet:(NSSet *)otherSet {
    id setValue =  object_getIvarDirectly(self.container, _ivar);
    if(setValue) {
        [setValue setSet:otherSet];
    }
    else {
        object_setIvarDirectly(self.container, _ivar, [otherSet mutableCopy]);
    }
}

- (void)intersectSet:(NSSet *)otherSet {
    [object_getIvarDirectly(self.container, _ivar) intersectSet:otherSet];
}

- (void)minusSet:(NSSet *)otherSet {
    [object_getIvarDirectly(self.container, _ivar) minusSet:otherSet];
}

- (void)unionSet:(NSSet *)otherSet {
    id setValue = object_getIvarDirectly(self.container, _ivar);
    if(setValue) {
        [setValue unionSet:otherSet];
    }
    else {
        object_setIvarDirectly(self.container, _ivar, [otherSet mutableCopy]);
    }
}

@end
