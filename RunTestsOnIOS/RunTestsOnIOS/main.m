//
//  main.m
//  RunTestsOnIOS
//
//  Created by renjinkui on 2017/5/25.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char * argv[]) {
    //整个测试过程和UI无关，所以不安装UI，不启动runloop，直接进入测试，完成后退出
    //fix 调用一个UIKit类， 否则UIKit库不加载，造成 [NSValue valueWithCGPoint:(CGPoint)]等方法不可用
    [UIApplication class];
    
    void tests_main();
    tests_main();
    
    return 0;
}
