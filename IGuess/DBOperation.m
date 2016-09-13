//
//  DBOperation.m
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "DBOperation.h"
#import "FMDatabase.h"
#import "ResultDetailItem.h"

@implementation DBOperation

- (NSMutableArray *)getWordsFromDB:(NSString *)DBName sql:(NSString *)sql totalWordsCounts:(int)totalWordsCounts initItemCounts:(int)initItemCounts {
    // 从DB中取出对应ID的数据
    FMDatabase *db = [FMDatabase databaseWithPath:[[NSBundle mainBundle]pathForResource:DBName ofType:@"db"]];
    if (![db open]) {
        DDLogError(@"打开%@.db失败", DBName);
        return nil;
    }
    
    FMResultSet *s = [db executeQuery:sql];
//    int wordId;
//    NSString *type;
    NSString *name;
    NSMutableArray *words;
    words = [NSMutableArray arrayWithCapacity:MIN(initItemCounts,totalWordsCounts)];
    while ([s next]) {
//        wordId = [s intForColumn:@"ID"];
//        type = [s stringForColumn:@"TYPE"];
        name = [s stringForColumn:@"NAME"];
        [words addObject:name];
    }
    [db close];
    
    return words;
    
}

- (NSMutableArray *)getResultsFromDB:(NSString *)sql {
    // 从数据库里读取数据，存储到results里
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"results.db"];
    
    // 游戏开始时切换至history界面，无results.db，此时也要复制之
    if (![fm fileExistsAtPath:dbPath]) {
        NSError *error;
        NSString *resourcePath = [[NSBundle mainBundle]pathForResource:@"results" ofType:@"db"];
        DDLogDebug(@"bundle路径为: %@", resourcePath);
        [fm copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogVerbose(@"%@打开results.db失败");
        return nil;
    }

    NSMutableArray *results = [[NSMutableArray alloc]init];
    FMResultSet *s = [db executeQuery:sql];
    while ([s next]) {
        ResultDetailItem *item = [[ResultDetailItem alloc]init];
        item.wordId = [s stringForColumn:@"id"];
        item.name = [s stringForColumn:@"name"];
        item.result = [s stringForColumn:@"result"];
        item.round = [s intForColumn:@"round"];
        [results addObject:item];
    }
    
    [db close];
    
    return results;
    
}

- (void)saveToResults:(NSString *)sql results:(NSArray *)results {
    // 将DB从工程目录拷贝到document目录，否则只读不可写
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"results.db"];
    NSString *resourcePath = [[NSBundle mainBundle]pathForResource:@"results" ofType:@"db"];
    NSError *error;
    
    if (![fm fileExistsAtPath:dbPath]) {
        [fm copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogError(@"打开results.db失败");
        return;
    }
    
    if (results != nil) {
        for (ResultDetailItem *item in results){
            DDLogDebug(@"保存词条: %@，结果:%@", item.name, item.result);
//            NSError *error;
            if (![db executeUpdate:sql
              withArgumentsInArray:@[item.result, item.wordId,[NSNumber numberWithInteger:item.round],item.name]]) {
                DDLogError(@"保存结果失败");
                return;
            };
        }
    }
    
    [db close];
}

- (void)deleteFromResults:(NSString *)sql {
    // 将DB从工程目录拷贝到document目录，否则只读不可写
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"results.db"];
    NSString *resourcePath = [[NSBundle mainBundle]pathForResource:@"results" ofType:@"db"];
    NSError *error;
    
    if (![fm fileExistsAtPath:dbPath]) {
        [fm copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogError(@"打开results.db失败");
        return;
    }

    if (![db executeUpdate:sql]) {
        DDLogError(@"删除条目失败");
        return;
    } else {
        DDLogDebug(@"删除条目成功");
    };

    [db close];
}

@end