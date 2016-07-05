//
//  SettingsViewController.m
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDuration];
    
    [self.shortDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mediumDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.longDuration addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

    //这个方法太蠢了，不忍直视
    if (self.duration == 60) {
        self.shortDuration.on = YES;
        self.mediumDuration.on = NO;
        self.longDuration.on = NO;
    } else if(self.duration == 120) {
        self.shortDuration.on = NO;
        self.mediumDuration.on = YES;
        self.longDuration.on = NO;
    } else if(self.duration == 180) {
        self.shortDuration.on = NO;
        self.mediumDuration.on = NO;
        self.longDuration.on = YES;
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
//
//        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
//        NSNumber *number = [unarchiver decodeObjectForKey:@"duration"]; //decode后的数据为对象，不能直接复制给int
//        self.duration = [number intValue];
//        NSLog(@"summ setting-load duration: %ld", (long)self.duration);
//        [unarchiver finishDecoding];
    } else {
        self.duration = 60;
    }
}

- (void)saveDuration {
    
    NSString *path = [self dataFilePath];
    NSNumber *round;
    
    //先把round拿出来，再跟duration组成字典存进去。解决writeToFile覆盖导致设置duration后round置0的问题
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *settingsBefore=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        round = [settingsBefore objectForKey:@"round"];
//        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
//        number = [unarchiver decodeObjectForKey:@"round"]; //decode后的数据为对象，不能直接复制给int
//        [unarchiver finishDecoding];
    } else {
        round = [NSNumber numberWithInt:1];
    }
    
    NSMutableArray *keys = [[NSMutableArray alloc]init];
    [keys addObject:@"round"];
    [keys addObject:@"duration"];
    NSMutableArray *values = [[NSMutableArray alloc]init];
    [values addObject:round];
    [values addObject:[NSNumber numberWithInteger:self.duration]];
    NSDictionary *settingsAfter = [[NSDictionary alloc]initWithObjects:values forKeys:keys];
    [NSKeyedArchiver archiveRootObject:settingsAfter toFile:path];
//    NSMutableData *data = [[NSMutableData alloc]init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
//    NSLog(@"summ setting-save duration: %ld", (long)self.duration);
//    [archiver encodeObject:[NSString stringWithFormat:@"%ld",(long)self.duration] forKey:@"duration"];
//    [archiver finishEncoding];
//    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    return documentDirectory;
}

- (NSString *)dataFilePath {
    NSLog(@"dataFilePath : %@",[[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"]);
    return [[self documentsDirectory]stringByAppendingPathComponent:@"Settings.plist"];
}

//- (IBAction)back{

//    [self dismissViewControllerAnimated:YES completion:nil];
    
//    UIAlertController *alertController =
//    [UIAlertController alertControllerWithTitle:@"设置错误！"
//                                        message:@"请确认只有一个开关开启"
//                                 preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
//                                                      style:UIAlertActionStyleDefault
//                                                    handler:nil];
//    [alertController addAction:confirm];
//    
//    //获取开关的状态，当且只有1个开关开，其他开关关时，设置才有效。否则报错
//    NSMutableArray *switches = [[NSMutableArray alloc]init];
//    [switches addObject:[NSNumber numberWithBool:self.shortDuration.on]];
//    [switches addObject:[NSNumber numberWithBool:self.mediumDuration.on]];
//    [switches addObject:[NSNumber numberWithBool:self.longDuration.on]];
//    
//    NSUInteger position = [switches indexOfObject:[NSNumber numberWithBool:YES]];
//    
//    if (position != NSNotFound) {
//        [switches removeObjectAtIndex:position];
//        if ([switches indexOfObject:[NSNumber numberWithBool:YES]] == NSNotFound) {
//            //把开关状态存储下来
//            self.duration = 60 * (position + 1);
//            [self saveDuration];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//    } else {
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
//}

- (void)switchValueChanged:(id)sender {
    UISwitch *control = (UISwitch *)sender;
    if (control == self.shortDuration) {
        if (self.shortDuration.on == YES) {
            self.duration = 60;
            [self.mediumDuration setOn:NO animated:YES];
            [self.longDuration setOn:NO animated:YES];
        }
    } else if (control == self.mediumDuration) {
        if (self.mediumDuration.on == YES) {
            self.duration = 120;
            [self.shortDuration setOn:NO animated:YES];
            [self.longDuration setOn:NO animated:YES];
        }
    } else if (control == self.longDuration) {
        if (self.longDuration.on == YES) {
            self.duration = 180;
            [self.mediumDuration setOn:NO animated:YES];
            [self.shortDuration setOn:NO animated:YES];
        }
    }
    
    [self saveDuration];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"PLAY DURATION";
    } else {
        return nil;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
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
