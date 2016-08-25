//
//  PlayViewController.m
//  IGuess
//
//  Created by xia on 3/6/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "PlayViewController.h"
#import "FMDatabase.h"
#import "ItemDetailViewController.h"
#import "ResultViewController.h"
#import "HomeViewController.h"

@interface PlayViewController ()

@property (nonatomic, weak) IBOutlet UIButton *controlButton;
@property (nonatomic, weak) IBOutlet UIButton *passButton;
@property (nonatomic, weak) IBOutlet UIButton *failButton;
@property (nonatomic, weak) IBOutlet UILabel *countDownLabel;
@property (nonatomic, weak) IBOutlet UILabel *puzzleLabel;

@end

@implementation PlayViewController
{
    NSMutableArray *puzzles;    //谜面
    NSMutableArray *results;    //总结果
    NSMutableArray *tmpResults;
    NSString *puzzleValue;
    NSTimer *timer;
    UIImage *_pauseImage;
    UIImage *_playImage;
    int _totalWordCounts;   //数据库中的词条总数
    int _guessedWordCounts; //已经猜词的词条总数量
    int _initWordCounts;    //初始化时随机读取的词条数量
    int _duration;          //游戏总时间
    int _round;             //游戏轮数
    int _passCounts;        //猜对的词条数
    int _failCounts;        //猜错的词条数
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
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
    
    self.hidesBottomBarWhenPushed = YES;
    
    return self;
}

//切后台，或进程异常退出保护
- (void)applicationDidEnterBackground {
    if ([_controlButton.currentBackgroundImage isEqual: _pauseImage] ) {
        //切换后台前，游戏未暂停
        DDLogDebug(@"游戏进行时切后台，暂停");
        self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue + 1];
        [self pauseGame];
    } else {
        DDLogDebug(@"游戏暂停时切后台，不做处理");
    }
}

- (void)applicationDidEnterForeground {
    if ([_controlButton.currentBackgroundImage isEqual: _pauseImage] ) {
        DDLogDebug(@"游戏恢复前台，继续");
        self.countDownLabel.text = [NSString stringWithFormat:@"%d", self.countDownLabel.text.intValue + 1];
        [self resumeGame];
        
    } else {
        DDLogDebug(@"游戏恢复前台，保持暂停");
    }
}

- (void)applicationWillTerminate {
    [self stopGame];
    DDLogDebug(@"游戏过程中被异常终止，保存结果成功");
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    
//    self.failButton = (UIButton *)[self.view viewWithTag:5000];
//    self.passButton = (UIButton *)[self.view viewWithTag:5001];
//    self.controlButton = (UIButton *)[self.view viewWithTag:4000];
    
    _pauseImage = [UIImage imageNamed:@"pause.png"];
    _playImage = [UIImage imageNamed:@"play.png"];
    
    [self startNewGame];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 开始新一轮游戏
- (void)startNewGame {
    [self getWordsFromDB];
    
//    // 初始化alertview
//    [self showAlertView];
    
    // 初始化records数组
    results = [NSMutableArray arrayWithCapacity:300];
    
    // 显示下一个词条
    [self goToNextPuzzle];
    
    // 加载round和countDown设置
    [self loadSettings];
//    [self updateCountDownLabel:_duration];
    self.countDownLabel.text = [NSString stringWithFormat:@"%d", _duration + 1];
//    DDLogDebug(@"init label value: %@", self.countDownLabel.text);
    
    // 启动倒计时
    [self startCountDown];
    
    DDLogError(@"游戏初始化成功");
}

// 结束游戏
- (void)stopGame {
    [self saveResults];
    [self saveRound];
    self.puzzleLabel.text = nil;
    DDLogError(@"游戏结束");
}

// 暂停游戏
- (void)pauseGame {
    [self pauseCountDown];
    self.failButton.enabled = NO;
    self.passButton.enabled = NO;
    DDLogVerbose(@"游戏暂停成功");
    
}

// 暂停后恢复游戏
- (void)resumeGame {
    [self resumeCountDown];
    self.failButton.enabled = YES;
    self.passButton.enabled = YES;
    DDLogVerbose(@"游戏恢复成功");
}

- (void)getWordsFromDB {
    // 从DB中随机取出词条对应的ID
    _initWordCounts = 300; // 一次游戏取出的词条个数
    _totalWordCounts = 4634; // 数据库中词条总个数
    int random;
    NSMutableString *IDs = [[NSMutableString alloc]initWithString:@"("];
    
    for (int i=1; i<=_initWordCounts; i++) {
        random = [self getRandomNumber:1 to:_totalWordCounts];
        //去重
        BOOL contain = [IDs containsString:[NSString stringWithFormat:@"%d",random]];
        
        if (contain == NO) {
            if (i < _initWordCounts) {
                [IDs appendString:[NSString stringWithFormat:@"%d,",random]];
            } else {
                [IDs appendString:[NSString stringWithFormat:@"%d)",random]];
            }
        } else {
            i--;
        }
    }
//    DDLogVerbose(@"random IDs: %@",IDs);
    
    // 从DB中取出对应ID的数据
    NSString *dbPath = [[NSBundle mainBundle]pathForResource:@"words" ofType:@"db"];
//    DDLogVerbose(@"mainbundle:%@", dbPath);
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogError(@"打开words.db失败");
        return;
    }
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM chengyu where ID in %@",IDs];
    FMResultSet *s = [db executeQuery:query];
    int id;
    NSString *type;
    NSString *name;
    puzzles = [NSMutableArray arrayWithCapacity:300];
    while ([s next]) {
        id = [s intForColumn:@"ID"];
        type = [s stringForColumn:@"TYPE"];
        name = [s stringForColumn:@"NAME"];
        [puzzles addObject:name];
    }
    [db close];
    
}


//- (void)showAlertView {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"倒计时" message:@"234" preferredStyle:UIAlertControllerStyleAlert];
//    
//    _leftTime = 3;
//    NSTimeInterval seconds = 1;
//    self.countDownLabel.text = [NSString stringWithFormat:@"%d", _leftTime ];
//    timer = [NSTimer scheduledTimerWithTimeInterval:seconds
//                                             target:self
//                                           selector:@selector(showStopAlert)
//                                           userInfo:nil
//                                            repeats:YES];
//    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
//    
//    [self presentViewController:alertController animated:NO completion:nil];
//}


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

// 倒计时暂停
- (void)pauseCountDown {
    [timer setFireDate:[NSDate distantFuture]];
}

// 倒计时恢复
- (void)resumeCountDown {
    [timer setFireDate:[NSDate date]];
}


// 倒计时结束后，强制弹框结束游戏
- (void)updateCountDown {
    int count = self.countDownLabel.text.intValue;
    if (--count < 0) {
        // 倒计时结束，停止游戏，显示结果
        [self stopCountDown];
        [self stopGame];
        
        NSInteger passCount = 0;
        NSInteger failCount = 0;
        for (NSDictionary *record in tmpResults) {
            if ([[record objectForKey:@"result"] isEqualToString: @"pass"]) {
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
                                                                [self startNewGame];
                                                            }];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"查看结果"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                                            {
                                                                [self showResult];
                                                            }];
        [alertController addAction:cancel];
        [alertController addAction:confirm];
        [self presentViewController:alertController animated:NO completion:nil];
        
    } else {
        // 倒计时未结束，仅更新countDownLabel
//        [self updateCountDownLabel:count];
        self.countDownLabel.text =[NSString stringWithFormat:@"%d", count];
    }
}

// 猜对
- (IBAction)guessRight {
    _passCounts += 1;
    _guessedWordCounts += 1;
    [self saveResult:puzzleValue result:@"pass"];
    [self goToNextPuzzle];
};

// 猜错
- (IBAction)guessWrong {
    _failCounts += 1;
    _guessedWordCounts += 1;
    [self saveResult:puzzleValue result:@"fail"];
    [self goToNextPuzzle];
};


- (void)goToNextPuzzle {
    puzzleValue = [puzzles objectAtIndex:_guessedWordCounts];
    _guessedWordCounts += 1;
    self.puzzleLabel.text = puzzleValue;
}


- (void)cancelShowResult {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showResult {
    [self performSegueWithIdentifier:@"ShowOneTimeDetail" sender:tmpResults];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowOneTimeDetail"]) {
//        UINavigationController *navigationController = segue.destinationViewController;
        ResultViewController *controller = (ResultViewController *)segue.destinationViewController;
        controller.results = sender;
//        controller.hidesBottomBarWhenPushed = NO;
//        controller.delegate = self;
    }
}

// 保存一个词条的猜词结果
- (void)saveResult:(NSString *)name result:(NSString *)result {
    NSMutableDictionary *singleRecord = [NSMutableDictionary dictionary];
    
    // 要用毫秒时间戳形式存储游戏时间，否则点击过快可能造成两次的时间相同，添加进字典失败
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [dat timeIntervalSince1970]*1000;
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", interval];
    
    [singleRecord setObject:timestamp forKey:@"id"]; //猜词词条时间戳
    [singleRecord setObject:[NSString stringWithFormat:@"%ld",(long)_round] forKey:@"round"];
    [singleRecord setObject:name forKey:@"name"];
    [singleRecord setObject:result forKey:@"result"];
    
    [results addObject:singleRecord];
}

// 保存一轮所有的词条的猜词结果
- (void)saveResults {
    // 将DB从工程目录拷贝到document目录，否则只读不可写
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"record.db"];
    NSString *resourcePath = [[NSBundle mainBundle]pathForResource:@"record" ofType:@"db"];
    NSError *error;
    
    if (![fm fileExistsAtPath:dbPath]) {
        [fm copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    
    // 从DB中取出对应ID的数据
    DDLogVerbose(@"chengyuResult数据表保存路径: %@", dbPath);
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogVerbose(@"打开数据库失败");
        return;
    }
    NSString *sql = @"INSERT INTO chengyuResult (result,id,round,name) VALUES(:result,:id,:round,:name);";
    if (results != nil) {
        for (NSDictionary *singleRecord in results){
            if (![db executeUpdate:sql withParameterDictionary:singleRecord]) {
                DDLogVerbose(@"保存一轮猜词结果到数据库失败");
                return;
            };
        }
    }

    [db close];
    
//    BOOL a = [fm copyItemAtPath:dbPath toPath:resourcePath error:&error];
    
    tmpResults = [[NSMutableArray alloc]init];
    [tmpResults addObjectsFromArray:results];
    [results removeAllObjects];
    
}

// 将round保存到本地
- (void)saveRound {
    NSString *path = [self dataFilePath];
    NSNumber *duration;
    
    // 先把duration拿出来，再跟round组成字典存进去。解决writeToFile覆盖导致设置duration后round置0的问题
    if ([tmpResults count] != 0) {
        if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
            NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
            duration = [settingsBefore objectForKey:@"duration"];
        } else {
            duration = [NSNumber numberWithInt:10];
        }
        
        NSMutableArray *keys = [[NSMutableArray alloc]init];
        [keys addObject:@"round"];
        [keys addObject:@"duration"];
        NSMutableArray *values = [[NSMutableArray alloc]init];
        [values addObject:[NSNumber numberWithInt:_round]];
        [values addObject:duration];
        NSDictionary *settingsAfter = [[NSDictionary alloc]initWithObjects:values forKeys:keys];
        [NSKeyedArchiver archiveRootObject:settingsAfter toFile:path];
    }
    
}

- (void)loadRound {
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        _round = [[settingsBefore objectForKey:@"round"] intValue] + 1;
    } else {
        _round = 1;
    }
    DDLogVerbose(@"加载游戏的轮数为: %d", _round);
}

- (void)loadSettings {
    _duration = (int)[self loadDuration];
    [self loadRound];
    
}

- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

- (NSInteger)loadDuration {
    NSInteger duration;
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        duration = [[settingsBefore objectForKey:@"duration"] intValue];
    } else {
        duration = 60;
    }
    DDLogVerbose(@"加载游戏的时长为: %ld", (long)duration);
    
    // 不知道什么导致加载的duration为10，偶现，暂时先规避
//    if (duration < 60) {
//        duration = 60;
//    }
    
    return duration;
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    return documentDirectory;
}

- (NSString *)dataFilePath {
//    DDLogVerbose(@"dataFilePath : %@",[[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"]);
    return [[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"];
}

- (IBAction)back {
    [self stopGame];
    [self.navigationController popViewControllerAnimated:self];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pauseOrPlay {
    if ([self.controlButton.currentBackgroundImage isEqual: _pauseImage]) {
        [self.controlButton setBackgroundImage:_playImage forState:UIControlStateNormal];
        [self pauseGame];
    } else if ([self.controlButton.currentBackgroundImage isEqual: _playImage]) {
        [self.controlButton setBackgroundImage:_pauseImage forState:UIControlStateNormal];
        [self resumeGame];
    }
}

// to be complemented
- (IBAction)deleteWordsFromDB {
    
}

- (void)dismissViews:(ResultViewController *)controller{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    DDLogVerbose(@"333self presenting:%@", self.presentingViewController);
//    DDLogVerbose(@"333self presented:%@", self.presentedViewController);
//    if (viewController == self) {
//        [self dismissViewControllerAnimated:NO completion:nil];
//    }
//}

@end
