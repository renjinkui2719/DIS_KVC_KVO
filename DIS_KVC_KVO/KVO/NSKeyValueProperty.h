//
//  NSKeyValueProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSKeyValueContainerClass;
@class NSKeyValueObservance;

typedef struct {
    id p1;
    NSMutableDictionary *p2;
}NSKeyValuePropertyForwardingValues;

@interface NSKeyValueProperty : NSObject <NSCopying>

@property (nonatomic, strong) NSKeyValueContainerClass *containerClass;
@property (nonatomic, copy) NSString *keyPath;

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath;
- (NSString *)restOfKeyPathIfContainedByValueForKeyPath:(NSString *)keyPath;
- (id)dependentValueKeyOrKeysIsASet:(BOOL *)isASet;
- (void)object:(id)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues)forwardingValues;
- (BOOL)object:(id)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(NSKeyValuePropertyForwardingValues *)forwardingValues;
- (void)object:(id)object didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse;
- (void)object:(id)object didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse;
- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(id)keys;
- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch;
- (Class)isaForAutonotifying;
- (NSKeyValueProperty*)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(id)keyPath propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;

- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch;
- (Class)_isaForAutonotifying;
- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(id)keys;

- (void)_givenPropertiesBeingInitialized:(CFSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties;

@end

