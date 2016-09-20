//
//  XZResultViewController.m
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZResultViewController.h"
#import "FMDatabase.h"
#import "XZResultDetailItem.h"
#import "XZPlayViewController.h"
#import "XZMeaningViewController.h"
#import "XZDBOperation.h"
#import "XZResultDetailCell.h"

@interface XZResultViewController ()

//@property (nonatomic) IBOutlet UIButton *addButton;

@end

@implementation XZResultViewController

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
        XZMeaningViewController *controller = segue.destinationViewController;
        controller.name = sender;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

//本tableview的每行data（row）是什么
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZResultDetailCell *cell = (XZResultDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"CurrentResult" forIndexPath:indexPath];
    
//    cell.resultLabel = (UILabel *)[cell viewWithTag:2000];
//    UILabel *addButton = (UIButton *)[cell viewWithTag:2001];
    
    XZResultDetailItem *item = self.results[indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *added = [defaults objectForKey:item.name];
    
    if (added.intValue == 1) {
        DDLogInfo(@"该词条已添加进生词本");
        [cell.addButton setTitle:@"V" forState:UIControlStateNormal];
    } else if (added.intValue == 0) {
        [cell.addButton setTitle:@"＋" forState:UIControlStateNormal];
    }

    cell.resultLabel.text = [NSString stringWithFormat:@"%@     %@", item.name, item.result.uppercaseString];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    XZResultDetailItem *item = self.results[indexPath.row];
    [self performSegueWithIdentifier:@"ShowMeaning" sender:item.name];
}

#pragma mark - ResultDetaiCell Delegate
- (XZResultDetailItem *)getResultDetailItem:(XZResultDetailCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    XZResultDetailItem *item = self.results[indexPath.row];
    return item;
}

@end
