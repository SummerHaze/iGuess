//
//  ResultDetailCel.m
//  IGuess
//
//  Created by xia on 9/9/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "ResultDetailCell.h"
#import "DBOperation.h"
#import "ResultDetailItem.h"
#import "ResultViewController.h"

@interface ResultDetailCell()

@property (nonatomic) UITableView *tableView;

@end

@implementation ResultDetailCell

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
    while (![object isKindOfClass:[ResultViewController class]]) {
        object = [object nextResponder];
    }
    ResultViewController *controller = (ResultViewController *)object;
    self.delegate = controller;
    
    UIView *view = [sender superview];
    ResultDetailCell *cell = (ResultDetailCell *)[view superview];
    
    ResultDetailItem *item = [self.delegate getResultDetailItem:cell];
    
    DBOperation *operation = [[DBOperation alloc]init];
    if ([self.addButton.currentTitle isEqual: @"＋"]) {
        [self.addButton setTitle:@"V" forState:UIControlStateNormal];
        [operation saveToResults:@"INSERT INTO notes (result,id,round,name) VALUES(:result,:id,:round,:name);" results:@[item]];
        
    } else {
        [self.addButton setTitle:@"＋" forState:UIControlStateNormal];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM notes WHERE ROUND=%ld and NAME=\"%@\"",(long)item.round, item.name];
        [operation deleteFromResults:sql];
    }
    
}

@end
