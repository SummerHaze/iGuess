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
#import "XZVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XZVideoEngine.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface XZPlayViewController ()

@property (nonatomic, strong) XZWordGuessingGame *game;

@property (nonatomic, weak) IBOutlet UIButton *controlButton;
@property (nonatomic, weak) IBOutlet UIButton *passButton;
@property (nonatomic, weak) IBOutlet UIButton *failButton;
@property (nonatomic, weak) IBOutlet UILabel *countDownLabel;
@property (nonatomic, weak) IBOutlet UILabel *daojishiLabel;
@property (nonatomic, weak) IBOutlet UILabel *puzzleLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *puzzleTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *passTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *failTopConstraint;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
@property (strong, nonatomic) XZVideoEngine         *videoEngine;


- (IBAction)guessRight;
- (IBAction)guessWrong;
- (IBAction)pauseOrPlay;

@end

@implementation XZPlayViewController
{
    NSTimer *timer;
    UIImage *pauseImage;
    UIImage *playImage;
}

#pragma mark - Life cycle
- (id)initWithCoder:(NSCoder *)aDecoder {
//    DDLogDebug(@"initWithCoder");
    if ((self = [super initWithCoder:aDecoder])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

//- (void)awakeFromNib {
//    DDLogDebug(@"awakeFromNib");
//}

- (void)viewDidLoad {
//    DDLogDebug(@"viewDidLoad");
    [super viewDidLoad];
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
    self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.game.duration + 1];
    
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
    // 动画调整布局，添加摄像头layer
    if (self.game.record.boolValue == 1) {
        // 布局动画
        [self initVideoAnimation];
        // 启动视频录制
        if (_videoEngine == nil) {
            CGRect videoFrame = CGRectMake(0, 50, 375, 200);
            [self.videoEngine previewLayer].frame = videoFrame;
            [self.view.layer insertSublayer:[self.videoEngine previewLayer] atIndex:0];
        }
        [self.videoEngine startUp];
    }

    [self startCountDown];
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

//切后台，或进程异常退出保护
- (void)applicationDidEnterBackground {
    if ([_controlButton.currentBackgroundImage isEqual: pauseImage] ) {
        //切换后台前，游戏未暂停
        DDLogDebug(@"进行时切后台，暂停");
        self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue + 1];
        [self pauseCountDown];
        
        // 此处应加上视频的暂停录制
        
    } else {
        DDLogDebug(@"暂停时切后台，不做处理");
    }
}

- (void)applicationDidEnterForeground {
    if ([_controlButton.currentBackgroundImage isEqual: pauseImage]) {
        DDLogDebug(@"恢复前台，继续");
        self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue + 1];
        [self resumeCountDown];
        
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
        [self.videoEngine shutdown];
        [self saveVideo];
        
        NSInteger passCount = 0;
        NSInteger failCount = 0;
        for (XZResultDetailItem *item in self.game.results) {
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
        [self pauseCountDown];
    } else if ([self.controlButton.currentBackgroundImage isEqual: playImage]) {
        [self.controlButton setBackgroundImage:pauseImage forState:UIControlStateNormal];
        [self resumeCountDown];
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
    self.puzzleTopConstraint.constant -= 30;
    self.passTopConstraint.constant -= 40;
    self.failTopConstraint.constant -= 40;
    
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
    [self.videoEngine stopCaptureHandler:nil];
//    if (_videoEngine.videoPath.length > 0) {
//        [self.videoEngine stopCaptureHandler:nil];
//    }else {
//        DDLogError(@"请先录制视频");
//    }
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
