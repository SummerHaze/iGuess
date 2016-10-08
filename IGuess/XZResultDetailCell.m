//
//  XZResultDetailCel.m
//  IGuess
//
//  Created by xia on 9/9/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZResultDetailCell.h"
#import "XZDBOperation.h"
#import "XZResultDetailItem.h"
#import "XZResultViewController.h"

@interface XZResultDetailCell()

@property (nonatomic) UITableView *tableView;


- (IBAction)addWordToNote:(id)sender;

@end

@implementation XZResultDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addWordToNote:(id)sender {
    id object = sender;
    while (![object isKindOfClass:[XZResultViewController class]]) {
        object = [object nextResponder];
    }
    XZResultViewController *controller = (XZResultViewController *)object;
    self.delegate = controller;
    
    UIView *view = [sender superview];
    XZResultDetailCell *cell = (XZResultDetailCell *)[view superview];
    
    XZResultDetailItem *item = [self.delegate getResultDetailItem:cell];
    XZDBOperation *operation = [[XZDBOperation alloc]init];
    
    if ([self.addButton.currentBackgroundImage isEqual: [UIImage imageNamed:@"add"]]) {
        self.isAdded = @1;
        [cell.addButton setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateNormal];
        [operation saveToResults:@"INSERT INTO notes (result,id,round,name) VALUES(:result,:id,:round,:name);" results:@[item]];
    
    } else {
        self.isAdded = @0;
        [cell.addButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM notes WHERE ROUND=%ld and NAME=\"%@\"",(long)item.round, item.name];
        [operation deleteFromResults:sql];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.isAdded forKey:item.name];
}

@end
