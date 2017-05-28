//
//  main.m
//  RunTestsOnIOS
//
//  Created by renjinkui on 2017/5/25.
//  Copyright © 2017年 JK. All rights reserved.
//

#import <UIKit/UIKit.h>

extern int kvc_kvo_test_main(int argc, const char * argv[]);

int main(int argc, char * argv[]) {
    //整个测试过程和UI无关，所以不安装UI，不启动runloop，直接进入测试，完成后退出
    kvc_kvo_test_main(argc, (const char **)argv);
}
