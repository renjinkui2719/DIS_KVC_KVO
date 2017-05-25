//
//  DSKeyValueProxyGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyGetter.h"
#import "DSKeyValueProxyCaching.h"
#import "DSKeyValueProxyShareKey.h"
#import <libkern/OSAtomic.h>

extern OSSpinLock DSKeyValueProxySpinLock;

id _DSGetProxyValueWithGetterNoLock(id object, DSKeyValueProxyGetter *getter) {
    NSHashTable *proxyShare = [getter.proxyClass _proxyShare];
    
    static DSKeyValueProxyShareKey *proxyShareKey = nil;
    if(!proxyShareKey) {
        proxyShareKey = [[DSKeyValueProxyShareKey alloc] init];
    }
    
    proxyShareKey.container = object;
    proxyShareKey.key = getter.key;
    
    id existProxy = [proxyShare member:proxyShareKey];
    
    proxyShareKey.container = nil;
    proxyShareKey.key = nil;
    
    if(existProxy) {
        return [[existProxy retain] autorelease];
    }
    else {
        existProxy = [[getter.proxyClass alloc] _proxyInitWithContainer:object getter:getter];
        [proxyShare addObject:existProxy];
        
        return [existProxy autorelease];
    }
}

id _DSGetProxyValueWithGetter(id object, SEL selector, DSKeyValueProxyGetter *getter) {
    OSSpinLockLock(&DSKeyValueProxySpinLock);
    id value = _DSGetProxyValueWithGetterNoLock(object, getter);
    OSSpinLockUnlock(&DSKeyValueProxySpinLock);
    return  value;
}

@implementation DSKeyValueProxyGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key proxyClass:(Class)proxyClass {
    void *arguments[3] = {0};
    arguments[0] = self;
    if (self = [super initWithContainerClassID:containerClassID key:key implementation:(IMP)_DSGetProxyValueWithGetter selector:NULL extraArguments:arguments count:1]) {
        _proxyClass = proxyClass;
    }
    return  self;
}

@end
