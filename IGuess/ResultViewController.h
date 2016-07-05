//
//  ResultViewController.h
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UITableViewController <UIApplicationDelegate>

@property (nonatomic) NSMutableArray *results;

- (IBAction)back;

@end
