//
//  XZCountDownView.m
//  IGuess
//
//  Created by xia on 9/26/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZCountDownView.h"

@interface XZCountDownView()

@property (nonatomic, weak) UILabel *countLabel;

@end

@implementation XZCountDownView
{
    NSTimer *timer;
    NSInteger second;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];
        self.alpha = 1;
        
        UILabel *countLabel = [[UILabel alloc]init];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.font = [UIFont systemFontOfSize:60];
        countLabel.textColor = [UIColor whiteColor];
        countLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.countLabel = countLabel;
        [self addSubview:countLabel];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.countLabel.frame = CGRectMake(self.center.x-self.countLabel.frame.size.width/2,
                                       self.center.y-self.countLabel.frame.size.height/2,
                                       100,
                                       100);
}

- (void)setText:(NSString *)text {
    self.countLabel.text = text;
}

@end
