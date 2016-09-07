//
//  ResultDetailViewController.h
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResultDetailViewController;

@protocol ResultDetailViewControllerDelegate <NSObject>

- (NSMutableArray *)getItems:(ResultDetailViewController *)controller;

@end


@interface ResultDetailViewController : UITableViewController

@property (nonatomic, weak) id <ResultDetailViewControllerDelegate> delegate;
@property (nonatomic) NSIndexPath *index;

@end
