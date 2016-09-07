//
//  WordGuessingGame.h
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordGuessingGame : NSObject

@property (nonatomic) int duration;             // 游戏时长
@property (nonatomic) int round;                // 游戏轮数
@property (nonatomic) int guessedWordsCounts;   // 已猜过的词条数
@property (nonatomic, copy) NSString *currentPuzzle;
@property (nonatomic) NSMutableArray *puzzles;  // 从DB中加载的词条
@property (nonatomic) NSMutableArray *results;  // 游戏结果

- (NSString *)getNextPuzzle;

- (void)startGame;
- (void)stopGame;

- (void)guessRight;
- (void)guessWrong;

@end
