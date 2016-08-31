//
//  SettingsViewController.m
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "SettingsViewController.h"
#import "TypePickerViewController.h"

static const NSInteger tmpDuration = 10;

@interface SettingsViewController ()

@property (nonatomic ,retain) IBOutlet UISwitch *testDuration;
@property (nonatomic,retain) IBOutlet UISwitch *shortDuration;
@property (nonatomic,retain) IBOutlet UISwitch *mediumDuration;
@property (nonatomic,retain) IBOutlet UISwitch *longDuration;
@property (nonatomic,retain) IBOutlet UISwitch *notify;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;


@end

@implementation SettingsViewController
{
    NSDictionary *_dic;
    NSInteger _duration;      //时长
    BOOL _notification;       //通知开关
    NSString *_type;          //词库类型
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.testDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    //#endif
    [self.shortDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mediumDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.longDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.notify addTarget:self action:@selector(notifySwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self loadSettings];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSettings {
    // 加载游戏时长
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        _duration = [[settingsBefore objectForKey:@"duration"] intValue];
    } else {
        _duration = tmpDuration;
    }
    DDLogVerbose(@"setting页面加载游戏的时长为: %ld", (long)_duration);
    
    // 设置时长开关状态
    [self setDurationSwitchStatus];
    
    // 加载通知开关
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _notification = [defaults boolForKey:@"notification"];
    self.notify.on = _notification;
    DDLogVerbose(@"setting页面加载通知开关为: %d", _notification);
    
    // 加载词库
    _type = [defaults stringForKey:@"type"];
    DDLogVerbose(@"setting页面加载词库类型为: %@", _type);
    if (_type == nil) {
        _type = @"成语";
        [defaults setObject:_type forKey:@"type"];
        DDLogVerbose(@"setting页面加载词库类型为空，默认成语");
    }
    self.typeLabel.text = _type;
    
}


- (void)setDurationSwitchStatus {
    _dic = [NSDictionary dictionaryWithObjectsAndKeys:
            self.testDuration, @10,
            self.shortDuration, @60,
            self.mediumDuration, @120,
            self.longDuration, @180,
            nil];
    
    // 加载switch的原始状态
    [_dic enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
        UISwitch *s = obj;
        if (key.intValue == _duration ) {
            s.on = YES;
        } else {
            s.on = NO;
        }
    }];
}

- (void)switchValueChanged: (id)sender {
    UISwitch *control = (UISwitch *)sender;
    [_dic enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
        UISwitch *s = obj;
        if (control == s && control.on == YES) {
            _duration = key.integerValue;
            [s setOn:YES animated:YES];
        } else {
            [s setOn:NO animated:YES];
        }
    }];
    
    [self saveDuraionSettings];
}

- (void)notifySwitchValueChanged: (id)sender {
    UISwitch *control = (UISwitch *)sender;
    if (control.on == YES) {
        _notification = YES;
    } else {
        _notification = NO;
    }
    
    [self saveCommonSettings];
}

- (void)saveDuraionSettings {
    NSString *path = [self dataFilePath];
    
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
    [values addObject:[NSNumber numberWithInteger:_duration]];
    DDLogVerbose(@"setting页面保存游戏的时长为: %ld", (long)_duration);
    NSDictionary *settingsAfter = [[NSDictionary alloc]initWithObjects:values forKeys:keys];
    [NSKeyedArchiver archiveRootObject:settingsAfter toFile:path];
}

- (void)saveCommonSettings {
    // 通知开关保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_notification forKey:@"notification"];
    DDLogVerbose(@"setting页面保存通知开关为: %d", _notification);
    
    // 词库保存
    [defaults setObject:_type forKey:@"type"];
    DDLogVerbose(@"setting页面保存词库类型为: %@", _type);
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    return documentDirectory;
}

- (NSString *)dataFilePath {
    DDLogVerbose(@"dataFilePath : %@",[[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"]);
    return [[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"PLAY DURATION";
    } else if (section == 1){
        return @"COMMON";
    } else if (section == 2){
        return @"MORE";
    } else {
        return nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickType"]) {
        TypePickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark – TypePickerViewController delegate
- (void)typePicker:(TypePickerViewController *)controller didPickType:(NSString *)typeName {
    self.typeLabel.text = typeName;
    _type = typeName;
    [self saveCommonSettings];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark – Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"PickType" sender:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"PickType" sender:nil];
    }
}

@end
