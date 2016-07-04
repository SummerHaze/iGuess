//
//  PlayViewController.h
//  IGuess
//
//  Created by xia on 3/6/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController

- (IBAction)guessRight;
- (IBAction)guessWrong;
- (IBAction)deleteWordsFromDB;
- (IBAction)back;
- (IBAction)pauseOrPlay;

@property(nonatomic) IBOutlet UILabel *countDownLabel;
@property(nonatomic) IBOutlet UILabel *puzzleLabel;

@end
