//
//  NSKeyValueProxyShareKey.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "NSKeyValueProxyShareKey.h"

@implementation NSKeyValueProxyShareKey

- (id)_proxyInitWithContainer:(id)container getter:(NSKeyValueGetter *)getter {
    return nil;
}

- (NSKeyValueProxyLocator)_proxyLocator {
    return (NSKeyValueProxyLocator){_container, _key};
}

+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    return nil;
}

+ (NSHashTable *)_proxyShare {
    return nil;
}

- (void)_proxyNonGCFinalize {
    
}

@end
