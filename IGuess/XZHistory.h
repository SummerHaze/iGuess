//
//  XZHistory.h
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZHistory : NSObject

/**
 *  按照游戏轮数，整理游戏结果
 *
 *  @return 结果数组，每个元素对应着每一轮所有猜词结果
 */
- (NSMutableArray *)sortResultsByRound;

/**
 *  按照游戏轮数，计算出该轮的正确，错误数
 *
 *  @return 每个元素对应着每一轮的统计数，即ResultItem对象
 */
- (NSMutableArray *)countResults:(NSMutableArray *)resultsSortedByRound;

@end
