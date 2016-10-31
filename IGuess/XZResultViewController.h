//
//  XZResultViewController.h
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZResultDetailCell.h"

@class XZResultViewController;

//@protocol ResultViewControllerDelegate <NSObject>
//
//- (NSMutableArray *)getItems:(ResultViewController *)controller;
//
//@end


// summ change super to UIViewController
@interface XZResultViewController : UIViewController <UITableViewDelegate, UIApplicationDelegate, ResultDetailCellDelegate, UIScrollViewDelegate>

@property (nonatomic) NSMutableArray *results;

- (IBAction)back;

//@property (nonatomic, weak) id <ResultViewControllerDelegate> delegate;
@property (nonatomic) NSIndexPath *index;

@end
