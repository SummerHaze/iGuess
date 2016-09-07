//
//  PlayViewController.m
//  IGuess
//
//  Created by xia on 3/6/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "PlayViewController.h"
#import "ResultViewController.h"
#import "WordGuessingGame.h"
#import "ResultDetailItem.h"

@interface PlayViewController ()

@property (nonatomic, strong) WordGuessingGame *game;  //与controller对应的model

@property (nonatomic, weak) IBOutlet UIButton *controlButton;
@property (nonatomic, weak) IBOutlet UIButton *passButton;
@property (nonatomic, weak) IBOutlet UIButton *failButton;
@property (nonatomic, weak) IBOutlet UILabel *countDownLabel;
@property (nonatomic, weak) IBOutlet UILabel *puzzleLabel;

- (IBAction)guessRight;
- (IBAction)guessWrong;
- (IBAction)pauseOrPlay;

@end

@implementation PlayViewController
{
    NSTimer *timer;
    UIImage *pauseImage;
    UIImage *playImage;
}

#pragma mark - Life cycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    pauseImage = [UIImage imageNamed:@"pause.png"];
    playImage = [UIImage imageNamed:@"play.png"];
    
    [self.game startGame];
    self.puzzleLabel.text = [self.game getNextPuzzle];
    
    self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.game.duration + 1];
    [self startCountDown];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//切后台，或进程异常退出保护
- (void)applicationDidEnterBackground {
    if ([_controlButton.currentBackgroundImage isEqual: pauseImage] ) {
        //切换后台前，游戏未暂停
        DDLogDebug(@"游戏进行时切后台，暂停");
        self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue + 1];
        [self pauseCountDown];
    } else {
        DDLogDebug(@"游戏暂停时切后台，不做处理");
    }
}

- (void)applicationDidEnterForeground {
    if ([_controlButton.currentBackgroundImage isEqual: pauseImage]) {
        DDLogDebug(@"游戏恢复前台，继续");
        self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue + 1];
        [self resumeCountDown];
        
    } else {
        DDLogDebug(@"游戏恢复前台，保持暂停");
    }
}

- (void)applicationWillTerminate {
    [self.game stopGame];
    self.puzzleLabel.text = nil;
    DDLogDebug(@"游戏过程中被异常终止，保存结果成功");
}

#pragma mark - WordGuessingGame lazy load
- (WordGuessingGame *)game {
    if (!_game) {
        _game = [[WordGuessingGame alloc]init];
    }
    return _game;
}

#pragma mark - Alert view
// 倒计时开始
- (void)startCountDown {
    NSTimeInterval interval = 1;
    timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(updateCountDown)
                                            userInfo:nil
                                             repeats:YES];
    [timer setFireDate:[NSDate distantPast]];
}

// 倒计时结束，释放定时器
- (void)stopCountDown {
    if ([timer isValid] == YES) {
        [timer invalidate];
        timer = nil;
    }
}

// 暂停游戏
- (void)pauseCountDown {
    [timer setFireDate:[NSDate distantFuture]];
    DDLogVerbose(@"暂停成功");
    
}

// 暂停后恢复游戏
- (void)resumeCountDown {
    [timer setFireDate:[NSDate date]];
    DDLogVerbose(@"恢复成功");
}

// 倒计时结束后，强制弹框结束游戏
- (void)updateCountDown {
    int count = self.countDownLabel.text.intValue;
    if (--count < 0) {
        // 倒计时结束，停止游戏，显示结果
        [self stopCountDown];
        [self.game stopGame];
        
        NSInteger passCount = 0;
        NSInteger failCount = 0;
        for (ResultDetailItem *item in self.game.results) {
            if ([item.result isEqualToString: @"pass"]) {
                passCount += 1;
            } else {
                failCount += 1;
            }
        }
        
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"游戏结束！"
                                            message:[NSString stringWithFormat:@"PASS: %ld\n FAIL: %ld",(long)passCount, (long)failCount]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"再来一轮"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action)
                                                             {
                                                                 [self.game startGame];
                                                                 self.puzzleLabel.text = [self.game getNextPuzzle];
                                                                 self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.game.duration + 1];
                                                                 [self startCountDown];
                                                            }];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"查看结果"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                                            {
                                                                [self performSegueWithIdentifier:@"ShowDetailToo" sender:self.game.results];
                                                            }];
        [alertController addAction:cancel];
        [alertController addAction:confirm];
        [self presentViewController:alertController animated:NO completion:nil];
        
    } else {
        // 倒计时未结束，仅更新countDownLabel
        self.countDownLabel.text =[NSString stringWithFormat:@"%d", count];
    }
}

#pragma mark - Event response
- (IBAction)guessRight {
    [self.game guessRight];
    self.puzzleLabel.text = [self.game getNextPuzzle];

};

- (IBAction)guessWrong {
    [self.game guessWrong];
    self.puzzleLabel.text = [self.game getNextPuzzle];
};

//- (void)goToNextPuzzle {
//    //    NSInteger offset = 300;
//    //    if ( puzzleString != nil) {
//    //        // label由左横滑进屏幕
//    //        CGPoint puzzleCenter = self.puzzleLabel.center;
//    //        puzzleCenter.x -= offset;
//    //        self.puzzleLabel.center = puzzleCenter;
//    //
//    //        puzzleCenter.x += offset;
//    //        [UIView animateWithDuration:0.5
//    //                         animations:^{
//    //                             self.puzzleLabel.center = puzzleCenter;
//    //                         }
//    //                         completion:nil];
//    //    }
//    
//    NSString *puzzleString;
//    puzzleString = [self.game.puzzles objectAtIndex:self.game.guessedWordsCounts];
//    self.game.guessedWordsCounts += 1;
//    
//}

- (IBAction)pauseOrPlay {
    if ([self.controlButton.currentBackgroundImage isEqual: pauseImage]) {
        [self.controlButton setBackgroundImage:playImage forState:UIControlStateNormal];
        [self pauseCountDown];
    } else if ([self.controlButton.currentBackgroundImage isEqual: playImage]) {
        [self.controlButton setBackgroundImage:pauseImage forState:UIControlStateNormal];
        [self resumeCountDown];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDetailToo"]) {
        ResultViewController *controller = (ResultViewController *)segue.destinationViewController;
        controller.results = sender;
    }
}

- (void)dismissViews:(ResultViewController *)controller{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}


@end
