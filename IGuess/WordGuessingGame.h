//
//  WordGuessingGame.h
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordGuessingGame : NSObject

/**
 *  游戏时长
 */
@property (nonatomic) int duration;

/**
 *  游戏轮数
 */
@property (nonatomic) int round;

/**
 *  已猜过的词条数
 */
@property (nonatomic) int guessedWordsCounts;

/**
 *  当前词条
 */
@property (nonatomic, copy) NSString *currentPuzzle;

/**
 *  从DB中加载的词条
 */
@property (nonatomic) NSMutableArray *puzzles;

/**
 *  游戏结果
 */
@property (nonatomic) NSMutableArray *results;

/**
 *  获取下一个词条
 *
 *  @return 下一个词条
 */
- (NSString *)getNextPuzzle;

/**
 *  启动游戏
 */
- (void)startGame;

/**
 *  结束游戏
 */
- (void)stopGame;

/**
 *  猜对
 */
- (void)guessRight;

/**
 *  猜错
 */
- (void)guessWrong;

@end
