//
//  ResultViewController.m
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "ResultViewController.h"
#import "FMDatabase.h"
#import "ItemDetail.h"
#import "ItemDetailViewController.h"
#import "PlayViewController.h"


@interface ResultViewController ()

@end

@implementation ResultViewController
{
    NSMutableArray *result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    result = self.results;
//    NSLog(@"222self presenting:%@", self.presentingViewController);
//    NSLog(@"222self navigation:%@", self.navigationController);
//    NSLog(@"222self navigation presenting:%@", self.navigationController.presentingViewController);
//    [self.navigationController.presentedViewController.presentingViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [result count];
}

//本tableview的每行data（row）是什么
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentResult" forIndexPath:indexPath];
    
    //显示当次游戏轮数的label，以后可优化成日期
    UILabel *roundLabel = (UILabel *)[cell viewWithTag:2000];
    //显示当次游戏统计结果的label
    UILabel *statLabel = (UILabel *)[cell viewWithTag:2001];
    
//    NSMutableArray *statResults = [self statResults:results];
    NSDictionary *item = result[indexPath.row];
    roundLabel.text = [item objectForKey:@"name"];
    statLabel.text = [item objectForKey:@"result"];
    return cell;
}

- (IBAction)back {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate dismissViews:self];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    PlayViewController *controller = (PlayViewController *)self.window.rootViewController;
//    [controller dismissViewControllerAnimated:NO completion:nil];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [self dismissViewControllerAnimated:NO completion:nil];
//}


@end
