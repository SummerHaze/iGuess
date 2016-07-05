//
//  SettingsViewController.h
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController
//- (IBAction)back;

//- (IBAction)switchValueChanged;

@property (nonatomic) IBOutlet UISwitch *shortDuration;
@property (nonatomic) IBOutlet UISwitch *mediumDuration;
@property (nonatomic) IBOutlet UISwitch *longDuration;
@property (nonatomic) NSInteger duration;


@end
