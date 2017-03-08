//
//  NSKeyValueProxyGetter.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/1/7.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyGetter.h"
#import "NSKeyValueProxyCaching.h"
#import "NSKeyValueProxyShareKey.h"

extern OSSpinLock NSKeyValueProxySpinLock;

id _NSGetProxyValueWithGetterNoLock(id object, NSKeyValueProxyGetter *getter) {
    NSHashTable *proxyShare = [getter.proxyClass _proxyShare];
    
    static NSKeyValueProxyShareKey *proxyShareKey = nil;
    if(!proxyShareKey) {
        proxyShareKey = [[NSKeyValueProxyShareKey alloc] init];
    }
    
    proxyShareKey.container = object;
    proxyShareKey.key = getter.key;
    
    id member = [proxyShare member:proxyShareKey];
    
    proxyShareKey.container = nil;
    proxyShareKey.key = nil;
    
    if(member) {
        return [[member retain] autorelease];
    }
    else {
        member = [[getter.proxyClass alloc] _proxyInitWithContainer:object getter:getter];
        [proxyShare addObject:member];
        
        return [member autorelease];
    }
}

id _NSGetProxyValueWithGetter(id object, SEL selector, NSKeyValueProxyGetter *getter) {
    OSSpinLockLock(&NSKeyValueProxySpinLock);
    id value = _NSGetProxyValueWithGetterNoLock(object, getter);
    OSSpinLockUnlock(&NSKeyValueProxySpinLock);
    return  value;
}

@implementation NSKeyValueProxyGetter

- (id)initWithContainerClassID:(id)containerClassID key:(NSString *)key proxyClass:(Class)proxyClass {
    void *arguments[3] = {0};
    arguments[0] = self;
    if (self = [super initWithContainerClassID:containerClassID key:key implementation:(IMP)_NSGetProxyValueWithGetter selector:NULL extraArguments:arguments count:1]) {
        _proxyClass = proxyClass;
    }
    return  self;
}

@end
