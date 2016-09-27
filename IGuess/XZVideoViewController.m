//
//  VideoViewController.m
//  IGuess
//
//  Created by xia on 9/14/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "XZCountDownView.h"
#import "XZVideoViewController.h"

@implementation XZVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加自定义倒计时view
    XZCountDownView *countDownView = [[XZCountDownView alloc]init];
    countDownView.frame = self.view.frame;
    [self.view addSubview:countDownView];
    
    sleep(3);
    
    [countDownView removeFromSuperview];
//    [countDownView setCount:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
