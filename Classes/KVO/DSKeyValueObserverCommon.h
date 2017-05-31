//
//  DSKeyValueCodingCommon.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/11.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdarg.h>
#import <objc/runtime.h>
#import <objc/objc.h>
#import <objc/message.h>
#import <pthread.h>
#import <libkern/OSAtomic.h>
#import "Log.h"

extern void *_CFGetTSD(uint32_t slot);
extern void *_CFSetTSD(uint32_t slot, void *newVal, void (*destructor)(void *));

extern void *NSAllocateScannedUncollectable(size_t);
extern void *NSReallocateScannedUncollectable(void *, size_t);
extern BOOL _CFAppVersionCheckLessThan(const char *, uint64_t, uint64_t, uint64_t);
extern NSUInteger dyld_get_program_sdk_version();
extern void _CF_forwarding_prep_0(void *);

//extern void os_lock_lock(void *);
//extern void os_lock_unlock(void *);

#define os_lock_lock OSSpinLockLock
#define os_lock_unlock OSSpinLockUnlock


static inline NSUInteger _DSKVOPointersHash(NSInteger count,...) {
#if 1
    NSUInteger hash = 0;
    va_list ap;
    va_start(ap, count);
    for (NSInteger i=0; i < count; ++i) {
        void *p = va_arg(ap, void *);
        hash ^= (NSUInteger)p;
    }
    va_end(ap);
    return hash;
#else
    
    void *pointers[count];
    
    va_list ap;
    va_start(ap, count);
    for (NSInteger i=0; i < count; ++i) {
        void *p = va_arg(ap, void *);
        pointers[i] = p;
    }
    va_end(ap);
    
    const NSUInteger FLAG = (0x0FL << (LONG_BIT - 4));
    unsigned char *p = (unsigned char *)pointers + 3;
    NSUInteger hash = 0;
    NSUInteger a = 0, b = 0;
    NSInteger loopSize = count * sizeof(void *);
    do {
        hash <<= 4;
        
        a = *(p - 3);
        a += hash;
        hash = a;
        hash &= FLAG;
        hash >>= (LONG_BIT - 8);
        b = a;
        b &= FLAG;
        if (b == 0) {
            hash = 0;
        }
        b = 0;
        hash ^= a;
        hash <<= 4;
        
        
        b = *(p - 2);
        b += hash;
        hash = b;
        hash &= FLAG;
        hash >>= (LONG_BIT - 8);
        a = b;
        a &= FLAG;
        if (a == 0) {
            hash = 0;
        }
        a = 0;
        hash ^= b;
        hash <<= 4;
        
        
        b = *(p -1);
        b += hash;
        a = b;
        a &= FLAG;
        a >>= (LONG_BIT - 8);
        hash  = b;
        hash &= FLAG;
        if (hash == 0) {
            a = 0;
        }
        hash = 0;
        a ^= hash;
        a <<= 4;
        
        
        hash = *p;
        hash += a;
        b = hash;
        b &= FLAG;
        b >>= (LONG_BIT - 8);
        a = hash;
        a &= FLAG;
        if (a == 0) {
            b = 0;
        }
        b ^= hash;
        
        hash |= (~0L ^ (0x0FL << (LONG_BIT - 4) ));
        hash ^= (0x0FL << (LONG_BIT - 4) );
        hash &= b;
        loopSize -= 4;
        p += 4;
        
    } while(loopSize > 3);
    
    return hash;
#endif
}
