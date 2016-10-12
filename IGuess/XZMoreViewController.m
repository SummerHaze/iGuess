//
//  XZMoreViewController.m
//  IGuess
//
//  Created by xia on 9/6/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZMoreViewController.h"
#import "XZDBOperation.h"

@interface XZMoreViewController ()

@property (nonatomic, weak) IBOutlet UILabel *countLabel;

@end

@implementation XZMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countLabel.text = [NSString stringWithFormat:@"Total Words Counts: %ld",(long)[self getWordsCount]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)getWordsCount {
    // 读取note中词条
    NSString *sql = @"SELECT * FROM notes";
    XZDBOperation *operation = [[XZDBOperation alloc]init];
    NSArray *words = [operation getResultsFromDB:sql];
    return [words count];
}



@end
