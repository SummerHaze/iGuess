//  
//  HistoryViewController.m
//  IGuess
//  
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//  

#import "HistoryViewController.h"
#import "ResultItem.h"
#import "FMDatabase.h"
#import "ResultDetailItem.h"
#import "ResultViewController.h"

#import "History.h"

@interface HistoryViewController ()

@property (nonatomic, strong) History *history;

@end

@implementation HistoryViewController
{
    NSMutableArray *resultsSortedByRound;
    NSMutableArray *resultsCountedByRound;
}

- (History *)history {
    if (!_history) {
        _history = [[History alloc]init];
    }
    return _history;
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.history countResults];

}

- (void)viewWillAppear:(BOOL)animated {
    resultsSortedByRound = [self.history sortResultsByRound];
    resultsCountedByRound = [self.history countResults];
    [self.tableView reloadData];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //  Dispose of any resources that can be recreated.
}



//#pragma mark - ResultViewControllerDelegate delegate
//- (NSMutableArray *)getItems:(ResultDetailViewController *)controller
//{
//    return items;
//}

#pragma mark - Event response
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
//        ResultViewController *controller = segue.destinationViewController;
//        controller.hidesBottomBarWhenPushed = YES;
//        controller.delegate = self;
//        controller.index = sender;
//    }
    
    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
        ResultViewController *controller = (ResultViewController *)segue.destinationViewController;
        controller.results = sender;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [resultsSortedByRound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryItem" forIndexPath:indexPath];
    
    // 显示当次游戏轮数的label，以后可优化成日期
    UILabel *roundLabel = (UILabel *)[cell viewWithTag:1000];
    // 显示当次游戏统计结果的label
    UILabel *statLabel = (UILabel *)[cell viewWithTag:1001];

    ResultItem *item = resultsCountedByRound[indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];

    NSString *time = [dateFormat stringFromDate:item.playTime];
    roundLabel.text = [NSString stringWithFormat:@"%@",time];
    statLabel.text = [NSString stringWithFormat:@"PASS: %ld,  FAIL: %ld",(long)item.passNumber,(long)item.failNumber];
    return cell;
}

#pragma mark – Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowDetail" sender:resultsSortedByRound[indexPath.row]];
}

@end
