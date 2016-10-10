//
//  XZDBOperation.m
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZDBOperation.h"
#import "FMDatabase.h"
#import "XZResultDetailItem.h"

@implementation XZDBOperation

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
        DDLogVerbose(@"打开results.db失败");
        return nil;
    }

    NSMutableArray *results = [[NSMutableArray alloc]init];
    FMResultSet *s = [db executeQuery:sql];
    while ([s next]) {
        XZResultDetailItem *item = [[XZResultDetailItem alloc]init];
        item.wordId = [s stringForColumn:@"id"];
        item.name = [s stringForColumn:@"name"];
        item.result = [s stringForColumn:@"result"];
        item.round = [s intForColumn:@"round"];
        [results addObject:item];
    }
    
    [db close];
    
    return results;
    
}

- (BOOL)saveToResults:(NSString *)sql results:(NSArray *)results {
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
        return NO;
    }
    
    if (results != nil) {
        for (XZResultDetailItem *item in results){
            DDLogDebug(@"保存词条: %@，结果:%@", item.name, item.result);
//            NSError *error;
            if (![db executeUpdate:sql
              withArgumentsInArray:@[item.result, item.wordId,[NSNumber numberWithInteger:item.round],item.name]]) {
                DDLogError(@"保存结果失败");
                return NO;
            };
        }
    }
    
    [db close];
    
    return YES;
}

- (BOOL)deleteFromResults:(NSString *)sql {
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
        return NO;
    }

    if (![db executeUpdate:sql]) {
        DDLogError(@"删除条目失败");
        return NO;
    } else {
        DDLogDebug(@"删除条目成功");
        return YES;
    };

    [db close];
    return YES;
}

@end