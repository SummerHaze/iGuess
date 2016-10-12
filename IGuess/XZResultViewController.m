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
#import "XZResultDetailItem.h"

@interface XZResultViewController ()

//@property (nonatomic) IBOutlet UIButton *addButton;

@end

@implementation XZResultViewController
{
    NSArray *notes;
    NSMutableArray *words;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=[[UIView alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    XZDBOperation *operation = [[XZDBOperation alloc]init];
    NSString *sql = @"SELECT * FROM notes ";
    notes = [operation getResultsFromDB:sql];
    
//    NSMutableArray *words = [[NSMutableArray alloc]init];
//    for (XZResultDetailItem *item in notes) {
//        [words addObject:item.name];
//    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZResultDetailCell *cell = (XZResultDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"CurrentResult" forIndexPath:indexPath];
    XZResultDetailItem *item = self.results[indexPath.row];
    NSInteger count = [notes count];
    
    // 获取生词本内的词语，决定页面button的初始状态
    for (XZResultDetailItem *detail in notes) {
        if ([detail.name isEqualToString:item.name]) {
            DDLogInfo(@"词条[%@]已添加进生词本", item.name);
            [cell.addButton setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateNormal];
            break;
        } else {
            count --;
            if (count == 0) {
                [cell.addButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            }
        }
    }


    // 猜词结果展示
    if ([item.result isEqualToString: @"fail"]) {
        NSAttributedString *text = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@     %@", item.name, item.result.uppercaseString]
                                                                  attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        
        cell.resultLabel.attributedText = text;
    } else {
        cell.resultLabel.text = [NSString stringWithFormat:@"%@     %@", item.name, item.result.uppercaseString];
    }
    
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
