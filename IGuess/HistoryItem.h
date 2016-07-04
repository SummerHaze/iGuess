//
//  HistoryItem.h
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryItem : NSObject

//游戏的轮数
@property NSInteger round;
//游戏时间
@property NSDate *playTime;
//正确数
@property NSInteger passNumber;
//错误数
@property NSInteger failNumber;

@end
