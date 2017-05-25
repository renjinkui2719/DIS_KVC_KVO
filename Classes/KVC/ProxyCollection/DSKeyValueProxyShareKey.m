//
//  DSKeyValueProxyShareKey.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/28.
//  Copyright © 2017年 JK. All rights reserved.
//

#import "DSKeyValueProxyShareKey.h"

@implementation DSKeyValueProxyShareKey

- (id)_proxyInitWithContainer:(id)container getter:(DSKeyValueGetter *)getter {
    return nil;
}

- (DSKeyValueProxyLocator)_proxyLocator {
    return (DSKeyValueProxyLocator){_container, _key};
}

+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer {
    return nil;
}

+ (NSHashTable *)_proxyShare {
    return nil;
}

- (void)_proxyNonGCFinalize {
    
}

@end
