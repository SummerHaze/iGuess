//
//  Setting.h
//  IGuess
//
//  Created by xia on 9/8/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

- (NSDictionary *)loadSettings;

- (void)saveDuraionSettings:(NSInteger)duration;

- (void)saveCommonSettings:(NSString *)name value:(NSString *)value;

@end
