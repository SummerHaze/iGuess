//
//  ItemDetailViewController.m
//  IGuess
//
//  Created by xia on 5/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ItemDetail.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController
{
    NSMutableArray *_lists;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _lists = [self.delegate getItems:self];
}
 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_lists[self.index.row] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ItemDetail *item = _lists[self.index.row][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@    %@", item.name, item.result.uppercaseString];
    
    return cell;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _lists = [[NSMutableArray alloc]initWithCapacity:20];
//        [self.delegate getItems:self]; //init里，对象未建立，不能设置delegate
    }
    
    return self;
}


@end
