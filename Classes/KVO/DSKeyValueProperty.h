//
//  DSKeyValueProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKeyValueObserverCommon.h"

@class DSKeyValueContainerClass;
@class DSKeyValueObservance;

typedef struct {
    id changingValue;
    NSMutableDictionary *affectingValuesMap;
}DSKeyValuePropertyForwardingValues;

static inline NSString * NSStringFromPropertyForwardingValues(const DSKeyValuePropertyForwardingValues *fwd) {
    if (!fwd) {
        return @"null";
    }
    return [NSString stringWithFormat:
            BRACE(
                  LINE(@"changingValue: %@,")\
                  LINE(@"affectingValuesMap: %@")\
                  ),
            simple_desc(fwd->changingValue),
            fwd->affectingValuesMap
            ];
}

@interface DSKeyValueProperty : NSObject <NSCopying>

@property (nonatomic, strong) DSKeyValueContainerClass *containerClass;
@property (nonatomic, copy) NSString *keyPath;

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath;
- (NSString *)restOfKeyPathIfContainedByValueForKeyPath:(NSString *)keyPath;
- (id)dependentValueKeyOrKeysIsASet:(BOOL *)isASet;
- (void)object:(id)object withObservance:(DSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues)forwardingValues;
- (BOOL)object:(id)object withObservance:(DSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)recurse forwardingValues:(DSKeyValuePropertyForwardingValues *)forwardingValues;
- (void)object:(id)object didRemoveObservance:(DSKeyValueObservance *)observance recurse:(BOOL)recurse;
- (void)object:(id)object didAddObservance:(DSKeyValueObservance *)observance recurse:(BOOL)recurse;
- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(id)keys;
- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch;
- (Class)isaForAutonotifying;
- (DSKeyValueProperty*)_initWithContainerClass:(DSKeyValueContainerClass *)containerClass keyPath:(id)keyPath propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;

- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch;
- (Class)_isaForAutonotifying;
- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(id)keys;

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableSet *)affectingProperties;

- (void)_addDependentValueKey:(id)valueKey;

@end

