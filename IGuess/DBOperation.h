//
//  DBOperation.h
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBOperation : NSObject

/**
 *  从词库DB中查询并获取词条
 *
 *  @param DBName           DB名称，保存在project bundle中
 *  @param sql              query sql
 *  @param totalWordsCounts 待查询的table item总数
 *  @param initItemCounts   一次查询取出的词条数。没必要一次全部取出
 *
 *  @return 词条名称数组
 */
- (NSMutableArray *)getWordsFromDB:(NSString *)DBName sql:(NSString *)sql totalWordsCounts:(int)totalWordsCounts initItemCounts:(int)initItemCounts;

/**
 *  从结果DB中读取猜词结果
 *
 *  @param DBName DB名称，保存在project bundle中
 *  @param sql    insert sql
 *
 *  @return 猜词结果数据，其中存放ResultDetailItem对象
 */
- (NSMutableArray *)getResultsFromDB:(NSString *)DBName sql:(NSString *)sql;

/**
 *  存储猜词结果到results.db
 *
 *  @param sql     insert sql
 *  @param results 待存储的猜词结果，其中的item结构与results.db schema一致，否则报错
 */
- (void)saveToResults:(NSString *)sql results:(NSArray *)results;

/**
 *  <#Description#>
 *
 *  @param sql       <#sql description#>
 */
- (void)deleteFromResults:(NSString *)sql;

@end
