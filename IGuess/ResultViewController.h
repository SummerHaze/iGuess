//
//  ResultViewController.h
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultDetailCell.h"

@class ResultViewController;

//@protocol ResultViewControllerDelegate <NSObject>
//
//- (NSMutableArray *)getItems:(ResultViewController *)controller;
//
//@end


@interface ResultViewController : UITableViewController <UIApplicationDelegate, ResultDetailCellDelegate>

@property (nonatomic) NSMutableArray *results;

- (IBAction)back;

//@property (nonatomic, weak) id <ResultViewControllerDelegate> delegate;
@property (nonatomic) NSIndexPath *index;

@end
