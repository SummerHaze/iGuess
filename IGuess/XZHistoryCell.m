//
//  XZHistoryCell.m
//  IGuess
//
//  Created by xia on 10/10/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZHistoryCell.h"

@implementation XZHistoryCell
{
    UIColor *passColor;
    UIColor *failColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    passColor = [UIColor colorWithRed:56.0/255.0 green:189.0/255.0 blue:40.0/255.0 alpha:1];
    failColor= [UIColor colorWithRed:242.0/255.0 green:32.0/255.0 blue:57.0/255.0 alpha:1];
    
    // 初始化各label
    self.passLabel.layer.cornerRadius = 8.0f;
    self.passLabel.layer.borderWidth  = 2.0f;
    self.passLabel.layer.borderColor  = passColor.CGColor;
    self.passLabel.layer.backgroundColor = passColor.CGColor;
    self.passLabel.textColor = [UIColor whiteColor];
    
    self.failLabel.layer.cornerRadius = 8.0f;
    self.failLabel.layer.borderWidth  = 2.0f;
    self.failLabel.layer.borderColor  = failColor.CGColor;
    self.failLabel.layer.backgroundColor = failColor.CGColor;
    self.failLabel.textColor = [UIColor whiteColor];
}

// Cell被选中，或被取消选中时调用
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.passLabel.layer.backgroundColor = passColor.CGColor;
    self.failLabel.layer.backgroundColor = failColor.CGColor;
}

// Cell被按住时调用
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.passLabel.layer.backgroundColor = passColor.CGColor;
    self.failLabel.layer.backgroundColor = failColor.CGColor;
    
}


@end
