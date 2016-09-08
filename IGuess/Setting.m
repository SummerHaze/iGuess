//
//  Setting.m
//  IGuess
//
//  Created by xia on 9/8/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "Setting.h"

static const NSInteger tmpDuration = 10;

@interface Setting()

@property (nonatomic) NSInteger duration;
@property (nonatomic) BOOL notification;
@property (nonatomic, copy) NSString *type;

@end

@implementation Setting


- (NSDictionary *)loadSettings {
    
    // 游戏时长
    NSString *path = [self plistFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        self.duration = [[settingsBefore objectForKey:@"duration"] intValue];
    } else {
        self.duration = tmpDuration;  // 容错，如果duration为空，则默认置为10s
    }
    DDLogVerbose(@"setting >>> 加载 >>> 时长: %ld", (long)self.duration);
    
    // 通知开关状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.notification = [defaults boolForKey:@"notification"];
    DDLogVerbose(@"setting >>> 加载 >>> 通知: %d", self.notification);
    
    // 词库类型
    self.type = [defaults stringForKey:@"type"];
    DDLogVerbose(@"setting >>> 加载 >>> 词库: %@", self.type);
    if (self.type == nil) {
        self.type = @"成语";
        [defaults setObject:self.type forKey:@"type"];
        DDLogVerbose(@"setting >>> 加载 >>> 词库为空，默认成语");
    }
    
    NSDictionary *settings = [[NSDictionary alloc]initWithObjects:@[[NSNumber numberWithInteger:self.duration],
                                                                  [NSNumber numberWithBool:self.notification],
                                                                  self.type]
                                                          forKeys:@[@"duration",
                                                                   @"notification",
                                                                   @"type"]];
    
    return settings;
}

- (void)saveDuraionSettings:(NSInteger)duration {
    if (duration != 0) {
        NSString *path = [self plistFilePath];
        
        // 游戏时长保存
        NSNumber *round;
        //先把round拿出来，再与duration组成字典存进去。解决writeToFile覆盖导致设置duration后round置0的问题
        if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
            NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
            round = [settingsBefore objectForKey:@"round"];
        } else {
            round = [NSNumber numberWithInt:0];
        }
        
        NSMutableArray *keys = [[NSMutableArray alloc]init];
        [keys addObject:@"round"];
        [keys addObject:@"duration"];
        NSMutableArray *values = [[NSMutableArray alloc]init];
        [values addObject:round];
        [values addObject:[NSNumber numberWithInteger:duration]];
        DDLogVerbose(@"setting >> 保存 >> 时长: %ld", (long)duration);
        
        NSDictionary *settingsAfter = [[NSDictionary alloc]initWithObjects:values forKeys:keys];
        [NSKeyedArchiver archiveRootObject:settingsAfter toFile:path];
    }

}

- (void)saveCommonSettings:(NSString *)name value:(NSString *)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([name isEqualToString:@"notification"]) {
        // 通知开关保存
        [defaults setBool:value.boolValue forKey:@"notification"];
        DDLogVerbose(@"setting >> 保存 >> 通知: %d", value.boolValue);
    } else if ([name isEqualToString:@"type"]) {
        // 词库保存
        if (value != nil) {
            [defaults setObject:value forKey:@"type"];
            DDLogVerbose(@"setting >> 保存 >> 词库: %@", value);
        }
    }
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    return documentDirectory;
}

- (NSString *)plistFilePath {
//    DDLogVerbose(@"plistFilePath : %@",[[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"]);
    return [[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"];
}



@end
