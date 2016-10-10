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
//    [self.history countResults];

}

- (void)viewWillAppear:(BOOL)animated {
    resultsSortedByRound = [self.history sortResultsByRound];
    resultsCountedByRound = [self.history countResults:resultsSortedByRound];
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
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [resultsSortedByRound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XZHistoryCell *cell = (XZHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"HistoryItem" forIndexPath:indexPath];


//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    XZResultItem *item = resultsCountedByRound[indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];

    NSString *time = [dateFormat stringFromDate:item.playTime];

    cell.roundLabel.text = [NSString stringWithFormat:@"%ld", (indexPath.row+1)];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",time];
    cell.passLabel.text = [NSString stringWithFormat:@"%ld",(long)item.passNumber];
    cell.failLabel.text = [NSString stringWithFormat:@"%ld",(long)item.failNumber];
    
    return cell;
}

#pragma mark – Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowDetail" sender:resultsSortedByRound[indexPath.row]];
}


@end
