//
//  DSKeyValueComputedProperty.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2016/12/31.
//  Copyright © 2016年 JK. All rights reserved.
//


#import "DSKeyValueProperty.h"

//??经过反复推敲与尝试,我仍然无法明白这种property的用法
//Apple文档也找不到任何关于以[obj addObserver:ob forKeypath:@"@operator.xxx.xxx" context:c]这种模式监听"计算属性"的资料
//(必定要以这种模式监听keypath,才会走到这个类)
@interface DSKeyValueComputedProperty : DSKeyValueProperty

@property(nonatomic, copy) NSString *operationName;
@property(nonatomic, copy) NSString *operationArgumentKeyPath;
@property(nonatomic, strong) DSKeyValueProperty *operationArgumentProperty;

@end

