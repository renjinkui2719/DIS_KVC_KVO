//
//  NSKeyValueProxyCaching.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/2/16.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    NSObject *container;
    NSString *key;
}NSKeyValueProxyLocator;

typedef struct {
    
}NSKeyValueProxyNonGCPoolPointer;

@protocol NSKeyValueProxyCaching <NSObject>
+ (NSKeyValueProxyNonGCPoolPointer *)_proxyNonGCPoolPointer;
+ (NSHashTable *)_proxyShare;
- (NSKeyValueProxyLocator)_proxyLocator;
- (id)_proxyInitWithContainer;
- (void)_proxyNonGCFinalize;
@end

@class NSKeyValueProxyGetter;

NSHashTable * _NSKeyValueProxyShareCreate();
BOOL _NSKeyValueProxyDeallocate(id object);
id _NSGetProxyValueWithGetterNoLock(id container, NSKeyValueProxyGetter *getter);
