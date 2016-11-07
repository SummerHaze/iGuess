//  
//  XZHistoryViewController.m
//  IGuess
//  
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//  

#import "XZHistoryViewController.h"
#import "XZResultItem.h"
#import "FMDatabase.h"
#import "XZResultDetailItem.h"
#import "XZResultViewController.h"
#import "XZHistoryCell.h"
#import "XZHistory.h"

@interface XZHistoryViewController ()

@property (nonatomic, strong) XZHistory *history;

@end

@implementation XZHistoryViewController
{
    NSMutableArray *resultsSortedByRound;
    NSMutableArray *resultsCountedByRound;
}

- (XZHistory *)history {
    if (!_history) {
        _history = [[XZHistory alloc]init];
    }
    return _history;
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView=[[UIView alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //  Dispose of any resources that can be recreated.
}

#pragma mark - Event response
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
        XZResultViewController *controller = (XZResultViewController *)segue.destinationViewController;
        controller.results = sender;
        controller.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    resultsSortedByRound = [self.history sortResultsByRound];
    resultsCountedByRound = [self.history countResults:resultsSortedByRound];
    NSInteger count = [resultsSortedByRound count];
    
    if (!count) {
        // 没有结果显示占位图
        self.tableView.userInteractionEnabled = NO;
        DDLogInfo(@"history >>> no results");
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"placeholder"]];
        imageView.frame = CGRectMake(tableView.center.x-180/2, tableView.center.y-150, 180, 90);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.tableView addSubview:imageView];
    } else {
        // 有结果，显示结果，移除占位图
        self.tableView.userInteractionEnabled = YES;
        DDLogInfo(@"history >>> results exist");
        for (UIView *view in [tableView subviews]) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZHistoryCell *cell = (XZHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"HistoryItem" forIndexPath:indexPath];
    
    if ([resultsSortedByRound count]) {
        // results数据库有数据，展示结果列表
        XZResultItem *item = resultsCountedByRound[indexPath.row];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        
        NSString *time = [dateFormat stringFromDate:item.playTime];
        
        cell.roundLabel.text = [NSString stringWithFormat:@"%ld", (indexPath.row+1)];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@", time];
        cell.passLabel.text = [NSString stringWithFormat:@"%ld", (long)item.passNumber];
        cell.failLabel.text = [NSString stringWithFormat:@"%ld", (long)item.failNumber];
        return cell;
    } else {
        return nil;
    }
}

#pragma mark – Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowDetail" sender:resultsSortedByRound[indexPath.row]];
}


@end
