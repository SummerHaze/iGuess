//
//  XZTypePickerViewController.h
//  IGuess
//
//  Created by xia on 8/27/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZTypePickerViewController;

@protocol TypePickerViewControllerDelegate <NSObject>

- (void)typePicker:(XZTypePickerViewController *)controller didPickType:(NSString *)typeName;

@end

@interface XZTypePickerViewController : UITableViewController

@property (nonatomic, weak)id <TypePickerViewControllerDelegate> delegate;

@end


