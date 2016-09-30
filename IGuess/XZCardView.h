//
//  XZCardView.h
//  IGuess
//
//  Created by xia on 9/12/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZCardView;

@protocol XZCardViewDelegate <NSObject>

- (void)showMeaningWebview:(XZCardView *)cardView;

@end

@interface XZCardView : UIView

@property (nonatomic, weak) id <XZCardViewDelegate> delegate;

- (void)setLabel:(NSString *)note; // 设置卡片上显示的词语

@end
