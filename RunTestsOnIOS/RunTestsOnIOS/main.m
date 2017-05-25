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
    kvc_kvo_test_main(argc, (const char **)argv);
}
