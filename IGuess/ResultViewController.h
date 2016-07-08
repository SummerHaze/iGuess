//
//  ResultViewController.h
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResultViewController;

@protocol ResultViewControllerDelegate <NSObject>

- (void)dismissViews:(ResultViewController *)controller;

@end


@interface ResultViewController : UITableViewController <UIApplicationDelegate>

@property (nonatomic) NSMutableArray *results;
@property (nonatomic, weak) id <ResultViewControllerDelegate> delegate;

- (IBAction)back;

@end
