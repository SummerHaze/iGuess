//
//  XZResultDetailCel.h
//  IGuess
//
//  Created by xia on 9/9/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZResultDetailItem.h"

@class XZResultDetailCell;
@class XZResultDetailItem;

@protocol ResultDetailCellDelegate <NSObject>

- (XZResultDetailItem *)getResultDetailItem:(XZResultDetailCell *)cell;

@end

@interface XZResultDetailCell : UITableViewCell

/**
 *  某词条是否已被添加进生词本，1表示是，0表示否
 */
@property (nonatomic) NSNumber *isAdded;

@property (nonatomic) IBOutlet UILabel *resultLabel;
@property (nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, weak)id <ResultDetailCellDelegate> delegate;

@end
