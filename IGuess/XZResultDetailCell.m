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
#import "MBProgressHUD.h"

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
    
    UITableView *tableView = (UITableView *)self.superview;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.addButton.currentBackgroundImage isEqual: [UIImage imageNamed:@"add"]]) {
        self.isAdded = @1;
        [cell.addButton setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateNormal];
        BOOL saveResult= [operation saveToResults:@"INSERT INTO notes (result,id,round,name) VALUES(:result,:id,:round,:name);" results:@[item]];
        
        // hud提示操作成功
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tableView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.offset = CGPointMake(0.f, 100.f);
        hud.alpha = 0.8f;
        
        if (saveResult == YES) {
            hud.label.text = NSLocalizedString(@"Added to Notebook!", @"HUD message title");
        } else {
            hud.label.text = NSLocalizedString(@"Add to Notebook fail!", @"HUD message title");
        }
        
        [hud hideAnimated:YES afterDelay:0.8];
        
        
    } else {
        self.isAdded = @0;
        [cell.addButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM notes WHERE ROUND=%ld and NAME=\"%@\"",(long)item.round, item.name];
        BOOL deleteResult = [operation deleteFromResults:sql];
        
        // hud提示删除成功
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tableView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.offset = CGPointMake(0.f, 100.0f);
        hud.alpha = 0.8f;
        
        if (deleteResult == YES) {
            hud.label.text = NSLocalizedString(@"Removed from Notebook!", @"HUD message title");
        } else {
            hud.label.text = NSLocalizedString(@"Remove from Notebook fail!", @"HUD message title");
        }
        
        [hud hideAnimated:YES afterDelay:0.8];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.isAdded forKey:item.name];
}



@end
