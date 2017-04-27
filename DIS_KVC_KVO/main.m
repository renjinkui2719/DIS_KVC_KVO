//
//  main.m
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/3/1.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+DSKeyValueCoding.h"

@interface Score : NSObject
@property (nonatomic, assign) CGFloat math;
@end
@implementation Score
@end

@interface User : NSObject
@property (nonatomic, assign) NSRect rect;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Score *score;
@end
@implementation User

@end

int main(int argc, const char * argv[]) {
    
    User *user = [User new];
    user.name = @"JJK";
    user.age = 27;
    user.rect = NSMakeRect(10, 20, 30, 40);
    user.score = [Score new];
    user.score.math = 99.0;
    
    //[user d_setValue:@28 forKey:@"age"];
    @try {
        [user d_setValue:@101.0 forKeyPath:@"score.math"];
    } @catch (NSException *exception) {
        NSLog(@"catch exception: %@", exception);
    } @finally {
        
    }
    
    id v = [user d_valueForKeyPath:@"score.math"];
    NSLog(@"");
    //[user d_setValue:[NSValue valueWithRect:NSMakeRect(100, 200, 300, 400)] forKey:@"rect"];
    
    //NSString *name = [user d_valueForKey:@"name"];
    //name = [user d_valueForKey:@"name"];
    //id rect = [user d_valueForKey:@"rect"];
    NSLog(@"");
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
