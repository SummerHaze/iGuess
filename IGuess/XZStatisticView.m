//
//  XZStatisticView.m
//  IGuess
//
//  Created by xia on 10/29/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZStatisticView.h"

#define PASS_COLOR [UIColor colorWithRed:56.0/255.0 green:189.0/255.0 blue:40.0/255.0 alpha:1]
#define FAIL_COLOR [UIColor colorWithRed:242.0/255.0 green:32.0/255.0 blue:57.0/255.0 alpha:1]

NSInteger globalPassCounts;
NSInteger globalFailCounts;

@interface XZStatisticView()

@property (nonatomic, strong) UILabel *passLabel;
@property (nonatomic, strong) UILabel *failLabel;

@end

@implementation XZStatisticView
{
    NSInteger fullWidth;
    NSInteger fullHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // 初始化各label
    self.passLabel = [[UILabel alloc]init];
    self.passLabel.backgroundColor = PASS_COLOR;
    self.passLabel.textColor = [UIColor whiteColor];
    self.passLabel.textAlignment = NSTextAlignmentCenter;
    self.passLabel.font = [UIFont fontWithName:@"Arial" size:20];
    
    self.failLabel = [[UILabel alloc]init];
    self.failLabel.backgroundColor = FAIL_COLOR;
    self.failLabel.textColor = [UIColor whiteColor];
    self.failLabel.textAlignment = NSTextAlignmentCenter;
    self.failLabel.font = [UIFont fontWithName:@"Arial" size:20];
    
    [self addSubview: self.passLabel];
    [self addSubview: self.failLabel];
    
}

- (void)layoutSubviews {
    fullWidth = self.frame.size.width;
    fullHeight = 36;
    
    // 直接将statView的frame设置为最终frame位置，避免Xcode8编译后，与layout最终位置不同导致下掉动画
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.frame = CGRectMake(0, statusBarHeight + 44, fullWidth, fullHeight);
    
    self.passLabel.text = [NSString stringWithFormat:@"%ld", (long)globalPassCounts];
    self.failLabel.text = [NSString stringWithFormat:@"%ld", (long)globalFailCounts];
    
    if (globalPassCounts == 0 && globalFailCounts != 0) {
        self.passLabel.frame = CGRectMake(0, 0, 0, fullHeight);
        self.failLabel.frame = CGRectMake(0, 0, fullWidth, fullHeight);
    } else if (globalPassCounts != 0 && globalFailCounts == 0) {
        self.passLabel.frame = CGRectMake(0, 0, fullWidth, fullHeight);
        self.failLabel.frame = CGRectMake(0, 0, 0, fullHeight);
    } else if (globalPassCounts == 0 && globalFailCounts == 0) {
        DDLogError(@"Error! Pass and Fail counts are both Zero!");
    } else {
        // 计算两个label的width比值
        float passRatio = (float)globalPassCounts / (globalPassCounts + globalFailCounts);
        float failRatio = (float)globalFailCounts / (globalPassCounts + globalFailCounts);
        self.passLabel.frame = CGRectMake(0, 0, fullWidth * passRatio, fullHeight);
        self.failLabel.frame = CGRectMake(fullWidth * passRatio, 0, fullWidth * failRatio, fullHeight);
    }
}


@end
