//
//  XZAboutViewController.m
//  IGuess
//
//  Created by xia on 10/27/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZAboutViewController.h"

@interface XZAboutViewController()

@property (nonatomic, weak) IBOutlet UIImageView *iconImage;

@end


@implementation XZAboutViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    //    DDLogDebug(@"initWithCoder");
    if ((self = [super initWithCoder:aDecoder])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 优化static group表格顶部的空白区域
    CGRect frame = CGRectMake(0, 0, 0, CGFLOAT_MIN);
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:frame];
}



@end
