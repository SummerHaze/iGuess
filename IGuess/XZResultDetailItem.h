//
//  XZResultDetailItem.h
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZResultDetailItem : NSObject

/**
 *  词条名称
 */
@property (nonatomic) NSString *name;

/**
 *  词条ID
 */
@property (nonatomic) NSString *wordId;

/**
 *  猜词轮数
 */
@property NSInteger round;

/**
 *  猜词结果
 */
@property (nonatomic, weak) NSString *result;


@end
