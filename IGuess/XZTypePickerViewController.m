//
//  XZTypePickerViewController.m
//  IGuess
//
//  Created by xia on 8/27/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZTypePickerViewController.h"

@interface XZTypePickerViewController ()

@end

@implementation XZTypePickerViewController
{
    NSArray *_types;
}

#pragma mark – life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=[[UIView alloc]init];
    _types = @[@"成语", @"计算机", @"布袋戏"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_types count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell"];
    
    NSString *type = _types[indexPath.row];
    cell.textLabel.text = type;
    
    return cell;
}

#pragma mark – Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *typeName = _types[indexPath.row];
    [self.delegate typePicker:self didPickType:typeName];
}


@end
