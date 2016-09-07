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

- (NSMutableArray *)getResultsFromDB:(NSString *)DBName sql:(NSString *)sql {
    // 从数据库里读取数据，存储到results里
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *name = [NSString stringWithFormat:@"%@.db",DBName];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:name];
    
    // 游戏开始时切换至history界面，无results.db，此时也要复制之
    if (![fm fileExistsAtPath:dbPath]) {
        NSError *error;
        NSString *resourcePath = [[NSBundle mainBundle]pathForResource:DBName ofType:@"db"];
        [fm copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogVerbose(@"%@打开失败", DBName);
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

- (void)saveResultsToDB:(NSString *)DBName sql:(NSString *)sql results:(NSArray *)results {
    // 将DB从工程目录拷贝到document目录，否则只读不可写
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *name = [NSString stringWithFormat:@"%@.db", DBName];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:name];
    NSString *resourcePath = [[NSBundle mainBundle]pathForResource:DBName ofType:@"db"];
    NSError *error;
    
    if (![fm fileExistsAtPath:dbPath]) {
        [fm copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
    
    DDLogVerbose(@"数据库%@保存路径: %@", name, dbPath);
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        DDLogError(@"打开数据库%@失败", name);
        return;
    }
    
    if (results != nil) {
        for (ResultDetailItem *item in results){
            DDLogDebug(@"当前保存的猜词结果为: %@", item);
            if (![db executeUpdate:sql withArgumentsInArray:@[item.result,
                                                              item.wordId,
                                                              [NSNumber numberWithInteger:item.round],
                                                              item.name]]) {
                DDLogError(@"保存一轮猜词结果到%@失败", name);
                return;
            };
        }
    }
    
    [db close];
}

@end