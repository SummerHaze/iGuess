//
//  WordGuessingGame.m
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "WordGuessingGame.h"
#import "DBOperation.h"
#import "ResultDetailItem.h"

static const NSInteger TMP_DURATION = 10;
static const int INIT_ITEM_COUNTS = 300;  //首次取出来的词条数
static const NSInteger CHENGYU_COUNTS = 4634;
static const NSInteger BUDAIXI_COUNTS = 12400;
static const NSInteger JISUANJI_COUNTS = 132;


@implementation WordGuessingGame
{
    NSMutableArray *tmpResults;
    NSString *puzzleString;
    NSString *type;        //词库类型
    int passCounts;        //猜对的词条数
    int failCounts;        //猜错的词条数
}

// 开始新一轮游戏
- (void)startGame {
    // 加载设置
    [self loadSettings];
    
    // 数据库中读词条
    [self getWordsFromDB];
    
    // 初始化results数组
    self.results = [NSMutableArray arrayWithCapacity:INIT_ITEM_COUNTS];
    tmpResults = [NSMutableArray arrayWithCapacity:INIT_ITEM_COUNTS];

    DDLogError(@"游戏初始化成功");
}

// 获取下一个词条
- (NSString *)getNextPuzzle{
    NSString *nextPuzzle;
    nextPuzzle = [self.puzzles objectAtIndex:self.guessedWordsCounts];
    self.currentPuzzle = nextPuzzle;
    if (nextPuzzle != nil) {
        self.guessedWordsCounts += 1;
        return nextPuzzle;
    } else {
        DDLogError(@"词条用完！");
        return nil;
    }
}

// 结束游戏
- (void)stopGame {
    [self saveResultsToDB];
    [self saveRound];
    DDLogError(@"游戏结束");
}

#pragma mark - DBOperation
- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

// 从DB中随机取出词条对应的ID
- (void)getWordsFromDB {
    int random;
    int totalWordsCounts;
    NSString *query;
    NSMutableString *IDs = [[NSMutableString alloc]initWithString:@"("];
    
    if ([type isEqualToString: @"成语"]) {
        totalWordsCounts = CHENGYU_COUNTS;
    } else if ([type isEqualToString: @"计算机"]) {
        totalWordsCounts = JISUANJI_COUNTS;
    } else if ([type isEqualToString: @"布袋戏"]) {
        totalWordsCounts = BUDAIXI_COUNTS;
    } else {
        DDLogError(@"play页面加载的词库类型有误，类型为: %@", type);
    }
    
    if (totalWordsCounts > INIT_ITEM_COUNTS) {
        for (int i=1; i<=INIT_ITEM_COUNTS; i++) {
            random = [self getRandomNumber:1 to:totalWordsCounts];
            //去重
            BOOL contain = [IDs containsString:[NSString stringWithFormat:@"%d",random]];
            
            if (contain == NO) {
                if (i < INIT_ITEM_COUNTS) {
                    [IDs appendString:[NSString stringWithFormat:@"%d,",random]];
                } else {
                    [IDs appendString:[NSString stringWithFormat:@"%d)",random]];
                }
            } else {
                i--;
            }
        }
    }
    
    if ([type isEqualToString: @"成语"]) {
        query = [NSString stringWithFormat:@"SELECT * FROM chengyu where ID in %@",IDs];
    } else if ([type isEqualToString: @"计算机"]) {
        query = @"SELECT * FROM jisuanji order by random()";
    } else if ([type isEqualToString: @"布袋戏"]) {
        query = [NSString stringWithFormat:@"SELECT * FROM budaixi where ID in %@",IDs];
    } else {
        DDLogError(@"play页面加载的词库类型有误，类型为: %@", type);
    }
    
    DBOperation *operation = [[DBOperation alloc]init];
    self.puzzles = [operation getWordsFromDB:@"words" sql:query totalWordsCounts:totalWordsCounts initItemCounts:INIT_ITEM_COUNTS];
    
}

// 保存一轮所有的词条的猜词结果
- (void)saveResultsToDB{
    NSString *sql;
    if ([type isEqualToString: @"成语"]) {
        sql = @"INSERT INTO chengyuResult (result,id,round,name) VALUES(:result,:id,:round,:name);";
    } else if ([type isEqualToString: @"计算机"]) {
        sql = @"INSERT INTO jisuanjiResult (result,id,round,name) VALUES(:result,:id,:round,:name);";
    } else if ([type isEqualToString: @"布袋戏"]) {
        sql = @"INSERT INTO budaixiResult (result,id,round,name) VALUES(:result,:id,:round,:name);";
    }
    
    DBOperation *operation = [[DBOperation alloc]init];
    [operation saveToResults:sql results:tmpResults];
    
    self.results = [[NSMutableArray alloc]init];
    [self.results addObjectsFromArray:tmpResults];
    
}

// 保存一个词条的猜词结果
- (void)saveSingleResult:(NSString *)name result:(NSString *)result {
    // 要用毫秒时间戳形式存储游戏时间，否则点击过快可能造成两次的时间相同，添加进字典失败
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [dat timeIntervalSince1970]*1000;
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", interval];
    
    ResultDetailItem *item = [[ResultDetailItem alloc]init];
    item.wordId = timestamp;
    item.round = self.round;
    item.name = name;
    item.result = result;
    
    [tmpResults addObject:item];
}

- (void)guessRight {
    passCounts += 1;
    self.guessedWordsCounts += 1;
    [self saveSingleResult:self.currentPuzzle result:@"pass"];
};

- (void)guessWrong {
    failCounts += 1;
    self.guessedWordsCounts += 1;
    [self saveSingleResult:self.currentPuzzle result:@"fail"];
};


- (void)saveRound {
    NSString *path = [self plistFilePath];
    NSNumber *duration;
    
    // 先把duration拿出来，再跟round组成字典存进去。解决writeToFile覆盖导致设置duration后round置0的问题
    if ([tmpResults count] != 0) {
        if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
            NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
            duration = [settingsBefore objectForKey:@"duration"];
        } else {
            duration = [NSNumber numberWithInt:TMP_DURATION];
        }
        
        NSMutableArray *keys = [[NSMutableArray alloc]init];
        [keys addObject:@"round"];
        [keys addObject:@"duration"];
        NSMutableArray *values = [[NSMutableArray alloc]init];
        [values addObject:[NSNumber numberWithInt:self.round]];
        [values addObject:duration];
        NSDictionary *settingsAfter = [[NSDictionary alloc]initWithObjects:values forKeys:keys];
        [NSKeyedArchiver archiveRootObject:settingsAfter toFile:path];
    }
    
}

- (void)loadSettings {
    [self loadDuration];
    [self loadRound];
    [self loadType];
}

- (void)loadDuration {
    NSString *path = [self plistFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        self.duration = [[settingsBefore objectForKey:@"duration"] intValue];
    } else {
        self.duration = TMP_DURATION;
    }
    DDLogVerbose(@"play页面加载游戏的时长为: %ld", (long)self.duration);
}

- (void)loadRound {
    NSString *path = [self plistFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        self.round = [[settingsBefore objectForKey:@"round"] intValue] + 1;
    } else {
        self.round = 1;
    }
    DDLogVerbose(@"加载游戏的轮数为: %d", self.round);
}

- (void)loadType {
    // 加载词库
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    type = [defaults stringForKey:@"type"];
    DDLogVerbose(@"play页面加载词库类型为: %@", type);
    if (type == nil) {
        type = @"成语";
        [defaults setObject:type forKey:@"type"];
        DDLogVerbose(@"play页面加载词库类型为空，默认成语");
    }
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    return documentDirectory;
}

- (NSString *)plistFilePath {
//    DDLogVerbose(@"plistFilePath : %@",[[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"]);
    return [[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"];
}

@end
