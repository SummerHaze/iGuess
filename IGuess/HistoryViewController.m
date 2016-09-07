//  
//  HistoryViewController.m
//  IGuess
//  
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//  

#import "HistoryViewController.h"
#import "ResultItem.h"
#import "FMDatabase.h"
#import "ResultDetailItem.h"
#import "ResultDetailViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController
{
    NSMutableArray *results; // 记录从数据库中读取的游戏数据
    NSMutableArray *items; // 按round分类后的results
    NSInteger maxRounds; // 每次取数据的最大条数（即游戏轮数）
    NSString *_type;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadType];
    [self getResultsFromDB];
    [self processResultsByRound];
}

- (void)viewWillAppear:(BOOL)animated {
    [self getResultsFromDB];
    [self processResultsByRound];
    [self.tableView reloadData];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //  Dispose of any resources that can be recreated.
}

- (void)loadType {
    // 加载词库
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _type = [defaults stringForKey:@"type"];
    DDLogVerbose(@"history页面加载词库类型为: %@", _type);
}

- (void)getResultsFromDB {
    maxRounds = 100;
    results = [[NSMutableArray alloc]initWithCapacity:10];
    
    // 从数据库里读取数据，存储到results里
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"results.db"];
    
    // 游戏开始时切换至history界面，无record.db，此时也要复制之
    if (![fm fileExistsAtPath:dbPath]) {
        NSError *error;
        NSString *resourcePath = [[NSBundle mainBundle]pathForResource:@"results" ofType:@"db"];
        [fm copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogVerbose(@"results.db打开失败");
        return;
    }
    
    NSString *query;
    if ([_type isEqualToString: @"成语"]) {
        query = [NSString stringWithFormat:@"SELECT * FROM chengyuResult"];
    } else if ([_type isEqualToString: @"计算机"]) {
        query = [NSString stringWithFormat:@"SELECT * FROM jisuanjiResult"];
    } else if ([_type isEqualToString: @"布袋戏"]) {
        query = [NSString stringWithFormat:@"SELECT * FROM budaixiResult"];
    }
    
    FMResultSet *s = [db executeQuery:query];
    while ([s next]) {
        ResultDetailItem *item = [[ResultDetailItem alloc]init];
        item.wordId = [s stringForColumn:@"id"];
        item.name = [s stringForColumn:@"name"];
        item.result = [s stringForColumn:@"result"];
        item.round = [s intForColumn:@"round"];
        [results addObject:item];
    }
    [db close];
}

// 将results以round分组
- (void)processResultsByRound {
    // 将results按照游戏轮数round处理成items
    items = [[NSMutableArray alloc]initWithCapacity:maxRounds];
    
    // 默认词条的round按照递增顺序排列
    ResultDetailItem *lastItem = [results lastObject];
    NSInteger max = lastItem.round;
    
    // 在items中初始化max个空Array元素，否则addobject时报错。这里要再想个更合理的办法
    for (int i=0; i<max; i++) {
        NSMutableArray *innerItems = [[NSMutableArray alloc]init];
        [items addObject:innerItems];
    }
    
    for (int i=0; i<[results count]; i++) {
        ResultDetailItem *item = results[i];
        [items[item.round -1] addObject:results[i]];
    }
}

// 统计每轮的游戏数据，用以显示在history list中
- (NSMutableArray *)statResults:(NSMutableArray *)result
{
    ResultDetailItem *idetail = [[ResultDetailItem alloc]init];
    NSMutableArray *statResults = [[NSMutableArray alloc]init];
    for (int i=0; i<[items count]; i++) {
        ResultItem *hitem = [[ResultItem alloc]init];
        hitem.round = i+1;
        for (int j=0; j<[items[i] count]; j++) {
            idetail = items[i][j];
            if ([idetail.result isEqualToString:@"pass"]) {
                hitem.passNumber += 1;
            } else {
                hitem.failNumber += 1;
            }
        }
        // 获取每轮游戏最后一个词条的时间，作为playTime
        idetail = [items[i] lastObject];
        hitem.playTime= [NSDate dateWithTimeIntervalSince1970:(idetail.wordId.doubleValue/1000)];
        
        [statResults addObject:hitem];
    }
    return statResults;
}

- (NSMutableArray *)getItems:(ResultDetailViewController *)controller
{
    return items;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
        ResultDetailViewController *controller = segue.destinationViewController;
        controller.hidesBottomBarWhenPushed = YES;
        controller.delegate = self;
        controller.index = sender;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryItem" forIndexPath:indexPath];
    
    // 显示当次游戏轮数的label，以后可优化成日期
    UILabel *roundLabel = (UILabel *)[cell viewWithTag:1000];
    // 显示当次游戏统计结果的label
    UILabel *statLabel = (UILabel *)[cell viewWithTag:1001];
    
    NSMutableArray *statResults = [self statResults:results];
    ResultItem *item = statResults[indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];

    NSString *time = [dateFormat stringFromDate:item.playTime];
    roundLabel.text = [NSString stringWithFormat:@"%@",time];
    statLabel.text = [NSString stringWithFormat:@"PASS: %ld,  FAIL: %ld",(long)item.passNumber,(long)item.failNumber];
    return cell;
}

#pragma mark – Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DDLogVerbose(@"IndexPath: %@", [indexPath description]);
    [self performSegueWithIdentifier:@"ShowDetail" sender:tableView.indexPathForSelectedRow];
}

@end
