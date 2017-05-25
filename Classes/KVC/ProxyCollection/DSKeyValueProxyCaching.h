//
//  DSKeyValueProxyCaching.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    NSObject *container;
    NSString *key;
}DSKeyValueProxyLocator;

typedef struct {
    
}DSKeyValueProxyNonGCPoolPointer;

@protocol DSKeyValueProxyCaching <NSObject>
+ (DSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer;
+ (NSHashTable *)_proxyShare;
- (DSKeyValueProxyLocator)_proxyLocator;
- (id)_proxyInitWithContainer;
- (void)_proxyNonGCFinalize;
@end

@class DSKeyValueProxyGetter;

NSHashTable * _DSKeyValueProxyShareCreate();
BOOL _DSKeyValueProxyDeallocate(id object);
