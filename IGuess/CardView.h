//
//  CardView.h
//  IGuess
//
//  Created by xia on 9/12/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView

/**
 *  设置卡片上显示的词语
 *
 *  @param note 词语
 */
- (void)setLabel:(NSString *)note;

@end
