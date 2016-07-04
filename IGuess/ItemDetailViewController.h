//
//  ItemDetailViewController.h
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemDetailViewController;

@protocol ItemDetailViewControllerDelegate <NSObject>

- (NSMutableArray *)getItems:(ItemDetailViewController *)controller;

@end


@interface ItemDetailViewController : UITableViewController

@property (nonatomic, weak) id <ItemDetailViewControllerDelegate> delegate;
@property (nonatomic) NSIndexPath *index;

@end
