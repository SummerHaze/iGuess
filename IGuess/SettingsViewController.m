//
//  SettingsViewController.m
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "SettingsViewController.h"
#import "TypePickerViewController.h"

@interface SettingsViewController ()

@property (nonatomic) IBOutlet UISwitch *testDuration;
@property (nonatomic) IBOutlet UISwitch *shortDuration;
@property (nonatomic) IBOutlet UISwitch *mediumDuration;
@property (nonatomic) IBOutlet UISwitch *longDuration;
@property (nonatomic) NSInteger duration;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;


@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDuration];
    
    [self.testDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.shortDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mediumDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.longDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

    //这个方法太蠢了，不忍直视
    if (self.duration == 60) {
        self.shortDuration.on = YES;
        self.mediumDuration.on = NO;
        self.longDuration.on = NO;
        self.testDuration.on = NO;
    } else if(self.duration == 120) {
        self.shortDuration.on = NO;
        self.mediumDuration.on = YES;
        self.longDuration.on = NO;
        self.testDuration.on = NO;
    } else if(self.duration == 180) {
        self.shortDuration.on = NO;
        self.mediumDuration.on = NO;
        self.longDuration.on = YES;
        self.testDuration.on = NO;
    } else if(self.duration == 10) {
        self.shortDuration.on = NO;
        self.mediumDuration.on = NO;
        self.longDuration.on = NO;
        self.testDuration.on = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDuration {
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        self.duration = [[settingsBefore objectForKey:@"duration"] intValue];
    } else {
        self.duration = 60;
    }
    DDLogVerbose(@"设置页面，加载的游戏时长为: %ld", (long)self.duration);
}

- (void)saveDuration {
    NSString *path = [self dataFilePath];
    NSNumber *round;
    
    //先把round拿出来，再与duration组成字典存进去。解决writeToFile覆盖导致设置duration后round置0的问题
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        round = [settingsBefore objectForKey:@"round"];
    } else {
        round = [NSNumber numberWithInt:1];
    }
    
    NSMutableArray *keys = [[NSMutableArray alloc]init];
    [keys addObject:@"round"];
    [keys addObject:@"duration"];
    NSMutableArray *values = [[NSMutableArray alloc]init];
    [values addObject:round];
    [values addObject:[NSNumber numberWithInteger:self.duration]];
    DDLogVerbose(@"保存游戏的时长为: %ld", (long)self.duration);
    NSDictionary *settingsAfter = [[NSDictionary alloc]initWithObjects:values forKeys:keys];
    [NSKeyedArchiver archiveRootObject:settingsAfter toFile:path];

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


- (void)switchValueChanged: (id)sender{
    UISwitch *control = (UISwitch *)sender;
    if (control == self.shortDuration) {
        if (self.shortDuration.on == YES) {
            self.duration = 60;
            [self.mediumDuration setOn:NO animated:YES];
            [self.longDuration setOn:NO animated:YES];
            [self.testDuration setOn:NO animated:YES];
        }
    } else if (control == self.mediumDuration) {
        if (self.mediumDuration.on == YES) {
            self.duration = 120;
            [self.shortDuration setOn:NO animated:YES];
            [self.longDuration setOn:NO animated:YES];
            [self.testDuration setOn:NO animated:YES];
        }
    } else if (control == self.longDuration) {
        if (self.longDuration.on == YES) {
            self.duration = 180;
            [self.mediumDuration setOn:NO animated:YES];
            [self.shortDuration setOn:NO animated:YES];
            [self.testDuration setOn:NO animated:YES];
        }
    } else if (control == self.testDuration) {
        if (self.testDuration.on == YES) {
            self.duration = 10;
            [self.mediumDuration setOn:NO animated:YES];
            [self.shortDuration setOn:NO animated:YES];
            [self.longDuration setOn:NO animated:YES];
        }
    }
    
    [self saveDuration];
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

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
