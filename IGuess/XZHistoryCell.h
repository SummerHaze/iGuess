//
//  XZHistoryCell.h
//  IGuess
//
//  Created by xia on 10/10/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZHistoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *roundLabel;
@property (nonatomic, weak) IBOutlet UILabel *passLabel;
@property (nonatomic, weak) IBOutlet UILabel *failLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@end
