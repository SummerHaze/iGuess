//
//  HistoryViewController.m
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryItem.h"
#import "FMDatabase.h"
#import "ItemDetail.h"
#import "ItemDetailViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController
{
    NSMutableArray *results; //记录从数据库中读取的游戏数据
    NSMutableArray *items; //按round分类后的results
    NSInteger maxRounds; //每次取数据的最大条数（即游戏轮数）
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//本tableview一共有几行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (void)getResultsFromDB {
    maxRounds = 100;
    results = [[NSMutableArray alloc]initWithCapacity:10];
    
    //从数据库里读取数据，存储到results里
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"record.db"];
    //    NSString *dbPath = [[NSBundle mainBundle]pathForResource:@"record" ofType:@"db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return;
    }
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM chengyuResult"];
    FMResultSet *s = [db executeQuery:query];
    while ([s next]) {
        ItemDetail *item = [[ItemDetail alloc]init];
        item.wordId = [s stringForColumn:@"id"];
        item.name = [s stringForColumn:@"name"];
        item.result = [s stringForColumn:@"result"];
        item.round = [s intForColumn:@"round"];
        [results addObject:item];
    }
    [db close];
}

//将results以round分组
- (void)processResultsByRound {
    // 将results按照游戏轮数round处理成items
    items = [[NSMutableArray alloc]initWithCapacity:maxRounds];
    
    //默认词条的round安装递增顺序排列
    ItemDetail *lastItem = [results lastObject];
    NSInteger max = lastItem.round;
    
    //在items中初始化max个空Array元素，否则addobject时报错。这里要再想个更合理的办法
    for (int i=0; i<max; i++) {
        NSMutableArray *innerItems = [[NSMutableArray alloc]init];
        [items addObject:innerItems];
    }
    
    for (int i=0; i<[results count]; i++) {
        ItemDetail *item = results[i];
        [items[item.round -1] addObject:results[i]];
    }
}

//统计每轮的游戏数据，用以显示在history list中
- (NSMutableArray *)statResults:(NSMutableArray *)result
{
    ItemDetail *idetail = [[ItemDetail alloc]init];
    NSMutableArray *statResults = [[NSMutableArray alloc]init];
    for (int i=0; i<[items count]; i++) {
        HistoryItem *hitem = [[HistoryItem alloc]init];
        hitem.round = i+1;
        for (int j=0; j<[items[i] count]; j++) {
            idetail = items[i][j];
            if ([idetail.result isEqualToString:@"pass"]) {
                hitem.passNumber += 1;
            } else {
                hitem.failNumber += 1;
            }
        }
        //获取每轮游戏最后一个词条的时间，作为playTime
        idetail = [items[i] lastObject];
        hitem.playTime= [NSDate dateWithTimeIntervalSince1970:(idetail.wordId.doubleValue/1000)];
        
        [statResults addObject:hitem];
    }
    return statResults;
}

//本tableview的每行data（row）是什么
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryItem" forIndexPath:indexPath];
    
    //显示当次游戏轮数的label，以后可优化成日期
    UILabel *roundLabel = (UILabel *)[cell viewWithTag:1000];
    //显示当次游戏统计结果的label
    UILabel *statLabel = (UILabel *)[cell viewWithTag:1001];
    
    NSMutableArray *statResults = [self statResults:results];
    HistoryItem *item = statResults[indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];

    NSString *time = [dateFormat stringFromDate:item.playTime];
    roundLabel.text = [NSString stringWithFormat:@"%@",time];
    statLabel.text = [NSString stringWithFormat:@"PASS: %ld,  FAIL: %ld",(long)item.passNumber,(long)item.failNumber];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IndexPath: %@", [indexPath description]);
    [self performSegueWithIdentifier:@"ShowDetail" sender:tableView.indexPathForSelectedRow];
}

- (NSMutableArray *)getItems:(ItemDetailViewController *)controller
{
    return items;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
        ItemDetailViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.index = sender;
    }
}

//- (IBAction)back {
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//}

@end
