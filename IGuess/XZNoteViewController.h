//
//  XZNoteViewController.h
//  IGuess
//
//  Created by xia on 9/9/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLSwipeableView.h"

@interface XZNoteViewController: UIViewController <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (nonatomic, strong) ZLSwipeableView *swipeableView;

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView;

@end
