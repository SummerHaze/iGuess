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
#import "MeaningViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController
{
    NSMutableArray *result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    result = self.results;
//    DDLogVerbose(@"222self presenting:%@", self.presentingViewController);
//    DDLogVerbose(@"222self navigation:%@", self.navigationController);
//    DDLogVerbose(@"222self navigation presenting:%@", self.navigationController.presentingViewController);
//    [self.navigationController.presentedViewController.presentingViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back {
//    [self.delegate dismissViews:self];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowMeaningToo"]) {
        MeaningViewController *controller = segue.destinationViewController;
        controller.name = sender;
    }
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
    
//    UILabel *roundLabel = (UILabel *)[cell viewWithTag:2000];
//    UILabel *statLabel = (UILabel *)[cell viewWithTag:2001];
//    NSMutableArray *statResults = [self statResults:results];
    
    NSDictionary *item = result[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", [item objectForKey:@"name"], [item objectForKey:@"result"]];
    
    return cell;
}

#pragma mark – Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = result[indexPath.row];
    [self performSegueWithIdentifier:@"ShowMeaningToo" sender:[item objectForKey:@"name"]];
}


@end
