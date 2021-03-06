//
//  XZHistory.m
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZHistory.h"
#import "XZDBOperation.h"
#import "XZResultDetailItem.h"
#import "XZResultItem.h"

@implementation XZHistory

- (NSMutableArray *)getResultsFromDB {
    NSString *sql = @"SELECT * FROM results";
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    XZDBOperation *operation = [[XZDBOperation alloc]init];
    results = [operation getResultsFromDB:sql];
    
    return results;
}

// 将results以round分组
- (NSMutableArray *)sortResultsByRound {
    NSMutableArray *results = [self getResultsFromDB];
    // 默认词条的round按照递增顺序排列
    XZResultDetailItem *lastItem = [results lastObject];
    NSInteger max = lastItem.round;
    
    // 将results按照游戏轮数round处理成items
    NSMutableArray *resultsSortedByRound = [[NSMutableArray alloc]initWithCapacity:max];
    
    // 在items中初始化max个空Array元素，否则addobject时报错。这里要再想个更合理的办法
    for (int i=0; i<max; i++) {
        NSMutableArray *innerItems = [[NSMutableArray alloc]init];
        [resultsSortedByRound addObject:innerItems];
    }
    
    for (int i=0; i<[results count]; i++) {
        XZResultDetailItem *item = results[i];
        [resultsSortedByRound[item.round -1] addObject:results[i]];
    }
    
    return resultsSortedByRound;
}

// 统计每轮的游戏数据，用以显示在history list中
- (NSMutableArray *)countResults:(NSMutableArray *)resultsSortedByRound {
//    NSMutableArray *resultsSortedByRound = [self sortResultsByRound];
    XZResultDetailItem *idetail = [[XZResultDetailItem alloc]init];
    NSMutableArray *resultsCountedByRound = [[NSMutableArray alloc]init];
    for (int i=0; i<[resultsSortedByRound count]; i++) {
        XZResultItem *item = [[XZResultItem alloc]init];
        item.round = i+1;
        for (int j=0; j<[resultsSortedByRound[i] count]; j++) {
            idetail = resultsSortedByRound[i][j];
            if ([idetail.result isEqualToString:@"pass"]) {
                item.passNumber += 1;
            } else {
                item.failNumber += 1;
            }
        }
        // 获取每轮游戏最后一个词条的时间，作为playTime
        idetail = [resultsSortedByRound[i] lastObject];
        item.playTime= [NSDate dateWithTimeIntervalSince1970:(idetail.wordId.doubleValue/1000)];
        
        [resultsCountedByRound addObject:item];
    }
    return resultsCountedByRound;
}

@end
