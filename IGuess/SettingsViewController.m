//
//  SettingsViewController.m
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "SettingsViewController.h"
#import "TypePickerViewController.h"
#import "Setting.h"

@interface SettingsViewController ()

@property (nonatomic ,retain) IBOutlet UISwitch *testDurationSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *shortDurationSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *mediumDurationSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *longDurationSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *notificationSwitch;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;

@property (nonatomic, strong) Setting *setting;


@end

@implementation SettingsViewController
{
    NSDictionary *dic;
    NSDictionary *_settings;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           self.testDurationSwitch, @10,
           self.shortDurationSwitch, @60,
           self.mediumDurationSwitch, @120,
           self.longDurationSwitch, @180,
           nil];
    
    _settings = [self.setting loadSettings];
    [self initSwitchesStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.testDurationSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.shortDurationSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mediumDurationSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.longDurationSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.notificationSwitch addTarget:self action:@selector(notifySwitchValueChanged:) forControlEvents:UIControlEventValueChanged];

}

- (Setting *)setting {
    if (!_setting) {
        _setting = [[Setting alloc]init];
    }
    return _setting;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSwitchesStatus {
    // duration开关
    [dic enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
        UISwitch *s = obj;
        NSNumber *d = [_settings objectForKey:@"duration"];
        if (key.integerValue == d.integerValue) {
            s.on = YES;
        } else {
            s.on = NO;
        }
    }];
    
    // notification开关
    NSNumber *n = [_settings objectForKey:@"notification"];
    if (n.integerValue == 0) {
        self.notificationSwitch.on = NO;
    } else {
        self.notificationSwitch.on = YES;
    }
    
}

#pragma mark - Notification response
- (void)switchValueChanged: (id)sender {
    UISwitch *control = (UISwitch *)sender;
    __block NSInteger duration;
    [dic enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
        UISwitch *s = obj;
        if (control == s && control.on == YES) {
            duration = key.integerValue;
            [s setOn:YES animated:YES];
        } else {
            [s setOn:NO animated:YES];
        }
    }];
    
    [self.setting saveDuraionSettings:duration];
}

- (void)notifySwitchValueChanged: (id)sender {
    UISwitch *control = (UISwitch *)sender;
    if (control.on == YES) {
        [self.setting saveCommonSettings:@"notification" value:@"YES"];
    } else {
        [self.setting saveCommonSettings:@"notification" value:@"NO"];
    }
    
    
}

#pragma mark - Event response
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickType"]) {
        TypePickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark – TypePickerViewController delegate
- (void)typePicker:(TypePickerViewController *)controller didPickType:(NSString *)typeName {
    self.typeLabel.text = typeName;
    [self.setting saveCommonSettings:@"type" value:typeName];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"PLAY DURATION";
    } else if (section == 1){
        return @"COMMON";
    } else {
        return nil;
    }
}

@end
