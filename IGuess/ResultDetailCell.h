//
//  ResultDetailCel.h
//  IGuess
//
//  Created by xia on 9/9/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultDetailItem.h"

@class ResultDetailCell;
@class ResultDetailItem;

@protocol ResultDetailCellDelegate <NSObject>

- (ResultDetailItem *)getResultDetailItem:(ResultDetailCell *)cell;

@end

@interface ResultDetailCell : UITableViewCell

/**
 *  某词条是否已被添加进生词本，1表示是，0表示否
 */
@property (nonatomic) NSNumber *isAdded;

@property (nonatomic) IBOutlet UILabel *resultLabel;
@property (nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, weak)id <ResultDetailCellDelegate> delegate;

@end
