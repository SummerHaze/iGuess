//
//  TypePickerViewController.h
//  IGuess
//
//  Created by xia on 8/27/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TypePickerViewController;

@protocol TypePickerViewControllerDelegate <NSObject>

- (void)typePicker:(TypePickerViewController *)controller didPickType:(NSString *)typeName;

@end

@interface TypePickerViewController : UITableViewController

@property (nonatomic, weak)id <TypePickerViewControllerDelegate> delegate;

@end


