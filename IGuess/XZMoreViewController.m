//
//  XZMoreViewController.m
//  IGuess
//
//  Created by xia on 9/6/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZMoreViewController.h"
#import "XZDBOperation.h"
#import "XZShareView.h"

@interface XZMoreViewController ()

@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) XZShareView *shareView;

@end

@implementation XZMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countLabel.text = [NSString stringWithFormat:@"Total Words Counts: %ld",(long)[self getWordsCount]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)getWordsCount {
    // 读取note中词条
    NSString *sql = @"SELECT * FROM notes";
    XZDBOperation *operation = [[XZDBOperation alloc]init];
    NSArray *words = [operation getResultsFromDB:sql];
    return [words count];
}

- (XZShareView *)shareView {
    if (!_shareView) {
        _shareView = [[XZShareView alloc]init];
//        [_shareView setBackgroundColor:[UIColor lightGrayColor]];
//        [_shareView setAlpha:0.5];
    }
    return _shareView;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 1) {
        shareType = 0; // 分享App
        
//        self.tabBarController.tabBar.hidden = YES;
//        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.shareView];
//        [tableView addSubview:self.shareView];
        
        NSInteger shareViewHeight = self.view.frame.size.height;
//        NSInteger shareViewHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height- rectStatus.size.height;
        
        self.shareView.frame = CGRectMake(self.view.frame.origin.x,
                                          self.view.frame.origin.y + shareViewHeight,
                                          self.view.frame.size.width,
                                          shareViewHeight
                                          );
        
        [UIView animateWithDuration: 1
                              delay: 0
             usingSpringWithDamping: 0.7
              initialSpringVelocity: 2
                            options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{
                             self.shareView.frame = CGRectMake(self.view.frame.origin.x,
                                                               self.view.frame.origin.y,
                                                               self.view.frame.size.width,
                                                               shareViewHeight);
                         } completion: nil];
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
