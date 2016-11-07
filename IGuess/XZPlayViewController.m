//
//  XZPlayViewController.m
//  IGuess
//
//  Created by xia on 3/6/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZPlayViewController.h"
#import "XZResultViewController.h"
#import "XZWordGuessingGame.h"
#import "XZResultDetailItem.h"
#import "XZVideoEngine.h"
#import "XZCountDownView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface XZPlayViewController ()

@property (nonatomic, strong) XZWordGuessingGame *game;
@property (nonatomic, strong) XZVideoEngine      *videoEngine;
@property (nonatomic, strong) XZCountDownView    *countDownView;

@property (nonatomic, weak) IBOutlet UIButton *controlButton;
@property (nonatomic, weak) IBOutlet UIButton *passButton;
@property (nonatomic, weak) IBOutlet UIButton *failButton;
@property (nonatomic, weak) IBOutlet UILabel *countDownLabel;
@property (nonatomic, weak) IBOutlet UILabel *puzzleLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *passBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *failBottomConstraint;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer

- (IBAction)guessRight;
- (IBAction)guessWrong;
- (IBAction)pauseOrPlay;

@end

@implementation XZPlayViewController
{
    NSTimer *gameTimer;
    NSTimer *coverTimer;
    UIImage *pauseImage;
    UIImage *playImage;
    NSInteger second;
    NSInteger tmpCount;
}

#pragma mark - Life cycle
//- (void)awakeFromNib {
//    DDLogDebug(@"awakeFromNib");
//}

- (void)viewDidLoad {
//    DDLogDebug(@"viewDidLoad");
    [super viewDidLoad];    // 添加自定义倒计时view
    self.countDownView.frame = self.view.frame;
    NSLog(@"2self.view.frame: %f, %f", self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.countDownView];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
//    DDLogDebug(@"initWithCoder");
    if ((self = [super initWithCoder:aDecoder])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
//    DDLogDebug(@"viewWillAppear");
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    pauseImage = [UIImage imageNamed:@"pause.png"];
    playImage = [UIImage imageNamed:@"play.png"];
    
    // 准备启动游戏
    [self.game startGame];
    self.puzzleLabel.text = [self.game getNextPuzzle];
    self.countDownLabel.text = nil;
}

- (void)viewDidAppear:(BOOL)animated {
//    DDLogDebug(@"viewDidAppear");
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
    
    // 倒计时蒙版阻塞3s
    second = 3;
    [self startCoverCountDown];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 3.0f]];
//    for (int i=0; i<3; i++) {
//        sleep(1);
//        [self.countDownView setText:[NSString stringWithFormat:@"%d",3-i]];
//    }
    [self.countDownView removeFromSuperview];
    
    // 动画调整布局，添加摄像头layer
    if (self.game.record.boolValue == 1) {
        // 布局动画
        [self initVideoAnimation];
//        self.puzzleLabel.font = [UIFont fontWithName:@"Arial" size:40];
        // 启动视频录制
        if (_videoEngine == nil) {
            // 此处的尺寸，仅影响preview layer的frame，与视频文件尺寸无关
            CGRect videoFrame = CGRectMake(0, 50, 375, 200);
            [self.videoEngine previewLayer].frame = videoFrame;
            [self.view.layer insertSublayer:[self.videoEngine previewLayer] atIndex:0];
        }

        [self.videoEngine startUp];
        [self.videoEngine startCapture];
    }

    self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.game.duration+1];
    [self startGameCountDown];
    
}

- (void)viewWillDisappear:(BOOL)animated {
//    DDLogDebug(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogDebug(@"viewDidDisappear");
    [self.videoEngine shutdown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
//    DDLogDebug(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 切后台，或进程异常退出保护
- (void)applicationDidEnterBackground {
    if ([_controlButton.currentBackgroundImage isEqual: pauseImage] ) {
        // 切换后台前，游戏未暂停
        [self pauseCountDown:gameTimer];
        tmpCount = self.countDownLabel.text.intValue;
        DDLogDebug(@"进行时切后台，暂停");
        
        // 此处应加上视频的暂停录制
        
    } else {
        DDLogDebug(@"暂停时切后台，不做处理");
    }
}

- (void)applicationDidEnterForeground {
    if ([_controlButton.currentBackgroundImage isEqual: pauseImage]) {
        DDLogDebug(@"恢复前台，继续");
        // 恢复倒计时label数据
        self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)tmpCount];
        [self resumeCountDown:gameTimer];
        
        if (self.countDownLabel.text.intValue < 10) {
            NSAttributedString *text = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue]
                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            self.countDownLabel.attributedText = text;
        } else {
            self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue];
        }
        
        // 此处应加上视频的恢复录制
        
    } else {
        DDLogDebug(@"恢复前台，保持暂停");
    }
}

- (void)applicationWillTerminate {
    [self.game stopGame];
    [self.videoEngine shutdown];
    self.puzzleLabel.text = nil;
    DDLogDebug(@"过程中被异常终止，保存结果成功");
}

#pragma mark - getter
- (XZVideoEngine *)videoEngine {
    if (_videoEngine == nil) {
        _videoEngine = [[XZVideoEngine alloc] init];
        //        _videoEngine.delegate = self;
    }
    return _videoEngine;
}

- (XZWordGuessingGame *)game {
    if (!_game) {
        _game = [[XZWordGuessingGame alloc]init];
    }
    return _game;
}

- (XZCountDownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[XZCountDownView alloc]init];
    }
    return _countDownView;
}

#pragma mark - Alert view
// 蒙版倒计时开始
- (void)startCoverCountDown {
    NSTimeInterval interval = 1;
    if (![gameTimer isValid]) {
        coverTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(updateCoverCountDown)
                                               userInfo:nil
                                                repeats:YES];
    }
    [coverTimer setFireDate:[NSDate distantPast]];
}


// 游戏倒计时开始
- (void)startGameCountDown {
    NSTimeInterval interval = 1;
    if (![gameTimer isValid]) {
        gameTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(updateGameCountDown)
                                               userInfo:nil
                                                repeats:YES];
    }
    [gameTimer setFireDate:[NSDate date]];
}


// 倒计时结束，释放定时器
- (void)stopCountDown:(NSTimer *)timer {
    if ([timer isValid] == YES) {
        [timer invalidate];
        timer = nil;
    }
}

// 暂停游戏
- (void)pauseCountDown:(NSTimer *)timer {
    [timer setFireDate:[NSDate distantFuture]];
    DDLogVerbose(@"暂停成功");
}

// 暂停后恢复游戏
- (void)resumeCountDown:(NSTimer *)timer {
    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
    DDLogVerbose(@"恢复成功");
}

- (void)updateCoverCountDown {
    if (second < 1) {
        [self stopCountDown:coverTimer];
    } else {
        [self.countDownView setText:[NSString stringWithFormat:@"%ld", (long)second]];
        second --;
    }
}

// 游戏倒计时处理
- (void)updateGameCountDown {
    int count = self.countDownLabel.text.intValue;
    if (--count < 0) {
        // 倒计时结束，停止游戏，显示结果
        [self stopCountDown:gameTimer];
        [self.game stopGame];
        
        // 停止视频录制，保存
        if (self.game.record.boolValue == 1) {
            [self saveVideo];
            [self.videoEngine shutdown];
        }
        
        NSInteger passCount = 0;
        NSInteger failCount = 0;
        for (XZResultDetailItem *item in self.game.results) {
            if ([item.result isEqualToString: @"pass"]) {
                passCount += 1;
            } else {
                failCount += 1;
            }
        }
        
        // 游戏结束强制弹框
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"游戏结束"
                                            message:[NSString stringWithFormat:@"PASS: %ld\nFAIL: %ld",(long)passCount, (long)failCount]
                                            // 视频录制功能暂时不开放
//                                            message:[NSString stringWithFormat:@"PASS: %ld\n FAIL: %ld\n 如有录制视频,请在本地相册查看",(long)passCount, (long)failCount]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"再来一轮"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action)
                                 {
                                     [self.game startGame];
                                     self.puzzleLabel.text = [self.game getNextPuzzle];
                                     self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.game.duration + 1];
                                     [self startGameCountDown];
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
        if (count <= 10) {
            NSAttributedString *text = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%d", count]
                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            self.countDownLabel.attributedText = text;
        } else {
            self.countDownLabel.text = [NSString stringWithFormat:@"%d", count];
        }
    }
}

#pragma mark - Event response
- (IBAction)guessRight {
    [self.game guessRight];
    [self puzzlesAnimation];
    self.puzzleLabel.text = [self.game getNextPuzzle];

}

- (IBAction)guessWrong {
    [self.game guessWrong];
    [self puzzlesAnimation];
    self.puzzleLabel.text = [self.game getNextPuzzle];
}

- (IBAction)pauseOrPlay {
    if ([self.controlButton.currentBackgroundImage isEqual: pauseImage]) {
        [self.controlButton setBackgroundImage:playImage forState:UIControlStateNormal];
        [self pauseCountDown:gameTimer];
    } else if ([self.controlButton.currentBackgroundImage isEqual: playImage]) {
        [self.controlButton setBackgroundImage:pauseImage forState:UIControlStateNormal];
        [self resumeCountDown:gameTimer];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDetailToo"]) {
        XZResultViewController *controller = (XZResultViewController *)segue.destinationViewController;
        controller.results = sender;
    }
}

- (void)dismissViews:(XZResultViewController *)controller{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - animation
- (void)initVideoAnimation {
//    NSInteger offset = 200;
    
    self.topConstraint.constant += 200;
    self.passBottomConstraint.constant -= 40;
    self.failBottomConstraint.constant -= 40;
    
    [UIView animateWithDuration: 0.5
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: 5
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         [self.view layoutIfNeeded];
    } completion: nil];
    
}

- (void)puzzlesAnimation {
    NSInteger offset = 300;
    if (self.puzzleLabel.text != nil) {
        // label由左横滑进屏幕
        CGPoint puzzleCenter = self.puzzleLabel.center;
        puzzleCenter.x -= offset;
        self.puzzleLabel.center = puzzleCenter;
        
        puzzleCenter.x += offset;
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.puzzleLabel.center = puzzleCenter;
                         }
                         completion:nil];
    }
    
}

#pragma mark - 视频录制相关
- (void)saveVideo {
//    [self.videoEngine stopCaptureHandler:nil];
//    DDLogDebug(@"videoPath: %@", _videoEngine.videoPath);
    if (_videoEngine.videoPath.length > 0) {
        [self.videoEngine stopCaptureHandler:nil];
    }else {
        DDLogError(@"请先录制视频");
    }
}

//#pragma mark - Apple相册选择代理
////选择了某个照片的回调函数/代理回调
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
//        //获取视频的名称
//        NSString * videoPath=[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
//        NSRange range =[videoPath rangeOfString:@"trim."];//匹配得到的下标
//        NSString *content=[videoPath substringFromIndex:range.location+5];
//        //视频的后缀
//        NSRange rangeSuffix=[content rangeOfString:@"."];
//        NSString *suffixName=[content substringFromIndex:rangeSuffix.location+1];
//        //如果视频是mov格式的则转为MP4的
//        if ([suffixName isEqualToString:@"MOV"]) {
//            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//            __weak typeof(self) weakSelf = self;
//            [self.videoEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
//                
//                [weakSelf.moviePicker dismissViewControllerAnimated:YES
//                                                         completion:^{
//                    weakSelf.playerVC = [[MPMoviePlayerViewController alloc]
//                                         initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
//                    [[NSNotificationCenter defaultCenter] addObserver:self
//                                                             selector:@selector(playVideoFinished:)
//                                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                                               object:[weakSelf.playerVC moviePlayer]];
//                    [[weakSelf.playerVC moviePlayer] prepareToPlay];
//                    
//                    [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
//                    [[weakSelf.playerVC moviePlayer] play];
//                }];
//            }];
//        }
//    }
//}


@end
