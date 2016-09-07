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
 *  @param DBName           DB名称，DB保存在project bundle中
 *  @param sql              query sql
 *  @param totalWordsCounts 待查询的table item总数
 *  @param initItemCounts   一次查询取出的词条数。没必要一次全部取出
 *
 *  @return 词条名称数组
 */
- (NSMutableArray *)getWordsFromDB:(NSString *)DBName sql:(NSString *)sql totalWordsCounts:(int)totalWordsCounts initItemCounts:(int)initItemCounts;

/**
 *  <#Description#>
 *
 *  @param DBName          <#DBName description#>
 *  @param saveResultsToDB <#saveResultsToDB description#>
 *  @param DBName          <#DBName description#>
 *  @param sql             <#sql description#>
 *  @param results         <#results description#>
 *
 *  @return <#return value description#>
 */
- (NSMutableArray *)getResultsFromDB:(NSString *)DBName sql:(NSString *)sql;

/**
 *  存储猜词结果到数据库
 *
 *  @param DBName  DB名称，DB存储在project沙盒中
 *  @param sql     insert sql
 *  @param results 待存储的猜词结果，item结构与DB相同
 */
- (void)saveResultsToDB:(NSString *)DBName sql:(NSString *)sql results:(NSArray *)results;



@end
