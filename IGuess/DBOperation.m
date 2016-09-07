//
//  DBOperation.m
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "DBOperation.h"
#import "FMDatabase.h"

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
        for (NSDictionary *singleRecord in results){
            DDLogDebug(@"当前保存的猜词结果为: %@", singleRecord);
            if (![db executeUpdate:sql withParameterDictionary:singleRecord]) {
                DDLogError(@"保存一轮猜词结果到%@失败", name);
                return;
            };
        }
    }
    
    [db close];
}

@end