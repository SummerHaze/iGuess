//
//  Setting.h
//  IGuess
//
//  Created by xia on 9/8/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

/**
 *  加载游戏设置
 *
 *  @return 返回设置页设置的字典
 */
- (NSDictionary *)loadSettings;

/**
 *  保存duration设置
 *
 *  @param duration 游戏时长
 */
- (void)saveDuraionSettings:(NSInteger)duration;

/**
 *  保存common设置
 *
 *  @param name  待保存的设置名称
 *  @param value 待保存的设置值
 */
- (void)saveCommonSettings:(NSString *)name value:(NSString *)value;

@end
