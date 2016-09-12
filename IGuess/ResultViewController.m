//
//  ResultViewController.m
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "ResultViewController.h"
#import "FMDatabase.h"
#import "ResultDetailItem.h"
#import "PlayViewController.h"
#import "MeaningViewController.h"
#import "DBOperation.h"
#import "ResultDetailCell.h"

@interface ResultViewController ()

//@property (nonatomic) IBOutlet UIButton *addButton;

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowMeaning"]) {
        MeaningViewController *controller = segue.destinationViewController;
        controller.name = sender;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

//本tableview的每行data（row）是什么
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResultDetailCell *cell = (ResultDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"CurrentResult" forIndexPath:indexPath];
    
//    cell.resultLabel = (UILabel *)[cell viewWithTag:2000];
//    UILabel *addButton = (UIButton *)[cell viewWithTag:2001];
    
    ResultDetailItem *item = self.results[indexPath.row];
    cell.resultLabel.text = [NSString stringWithFormat:@"%@     %@", item.name, item.result.uppercaseString];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    ResultDetailItem *item = self.results[indexPath.row];
    [self performSegueWithIdentifier:@"ShowMeaning" sender:item.name];
}

#pragma mark - ResultDetaiCell Delegate
- (ResultDetailItem *)getResultDetailItem:(ResultDetailCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ResultDetailItem *item = self.results[indexPath.row];
    return item;
}

@end
