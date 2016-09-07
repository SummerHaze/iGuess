//
//  ResultDetailItem.h
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultDetailItem : NSObject

//词语名字
@property (nonatomic) NSString *name;
//词语ID
@property (nonatomic) NSString *wordId;
//词语轮数
@property NSInteger round;
//猜词结果
@property (nonatomic, weak) NSString *result;


@end
