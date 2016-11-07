//
//  XZNoteViewController.m
//  IGuess
//
//  Created by xia on 9/9/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZNoteViewController.h"
#import "XZCardView.h"
#import "XZDBOperation.h"
#import "XZResultDetailItem.h"
#import "XZMeaningViewController.h"
#import "Masonry.h"

@interface XZNoteViewController()

@property (nonatomic, strong) XZCardView *cardView;
@property (nonatomic, strong) UILabel *guideLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation XZNoteViewController
{
    NSMutableArray *words;
    NSMutableArray *indexRandomArray;
    NSMutableArray *tmpArray;
    NSInteger number;
    XZDBOperation *operation;
}

#pragma mark - Life cycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 读取note中词条
    NSString *sql = @"SELECT * FROM notes";
    operation = [[XZDBOperation alloc]init];
    words = [operation getResultsFromDB:sql];
    
    // 乱序后的卡片数组
    indexRandomArray = [self getIndexRandomArray:words];
    tmpArray = [NSMutableArray arrayWithArray:indexRandomArray];
    number = 0;
    /*
    if ([indexRandomArray count] == 0) {
        self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"placeholder"]];
        self.imageView.frame = CGRectMake(self.view.center.x-180/2, self.view.center.y-150, 180, 134);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.imageView];
    } else {
        */
        self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"placeholder2"]];
        self.imageView.frame = CGRectMake(self.view.center.x-180/2, self.view.center.y-100, 180, 90);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.imageView];
        ZLSwipeableView *swipeableView = [[ZLSwipeableView alloc] initWithFrame:CGRectZero];
        self.swipeableView = swipeableView;
        [self.view addSubview:self.swipeableView];
        
        self.swipeableView.dataSource = self;
        self.swipeableView.delegate = self;
        self.swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
        // 暂时只开放左滑和上滑
        self.swipeableView.allowedDirection = ZLSwipeableViewDirectionLeft | ZLSwipeableViewDirectionUp;
        
        NSDictionary *metrics = @{};
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"|-50-[swipeableView]-50-|"
                                   options:0
                                   metrics:metrics
                                   views:NSDictionaryOfVariableBindings(swipeableView)]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-120-[swipeableView]-100-|"
                                   options:0
                                   metrics:metrics
                                   views:NSDictionaryOfVariableBindings(swipeableView)]];
        
        self.guideLabel = [[UILabel alloc]init];
        self.guideLabel.text = @"手势：向左滑出——展示下个，向上滑出——删除词条";
        self.guideLabel.font = [UIFont fontWithName:@"Arial" size:13];
        self.guideLabel.textAlignment = NSTextAlignmentCenter;
        self.guideLabel.numberOfLines = 1;
        [self.guideLabel setTextColor:[UIColor grayColor]];
        [self.view addSubview:self.guideLabel];
   // }
}

- (void)viewWillAppear:(BOOL)animated {
    // 页面底部指示label
    [self.guideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@44);
    }];
}

- (void)viewDidLayoutSubviews {
    [self.swipeableView loadViewsIfNeeded];
}

#pragma mark - ZLSwipeableViewDelegates
- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
    // 记录当前显示的词条index
    number += 1;
    
    // 上滑删除
    if (direction == ZLSwipeableViewDirectionUp) {
        XZResultDetailItem *item = tmpArray[number - 1];
        
        // 把生词从db中删掉
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM notes WHERE ROUND=%ld and NAME=\"%@\"",(long)item.round, item.name];
        [operation deleteFromResults:sql];
    }
    
    NSLog(@"did swipe in direction: %zd", direction);
}

#pragma mark - ZLSwipeableViewDataSource
- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    int index = 0;
    self.cardView = [[XZCardView alloc] initWithFrame:swipeableView.bounds];
    self.cardView.delegate = self;
    if ([indexRandomArray count] > 0) {
        XZResultDetailItem *item = indexRandomArray[index];
        [self.cardView setLabel:item.name];
        [indexRandomArray removeObjectAtIndex:index];
        return self.cardView;
    } else {
        return nil;
    }
    
}

// 卡片顺序随机出
- (NSMutableArray *)getIndexRandomArray:(NSMutableArray *)array {
    NSMutableArray *newArr = [NSMutableArray new];
    NSInteger initCounts = [words count];
    for (int i=0; i<initCounts; i++) {
        NSInteger count = [words count];
        int index = arc4random() % count;
        [newArr addObject:array[index]];
        [array removeObjectAtIndex:index];
    }
    return newArr;
}

#pragma mark - XZCardView Delegate
- (void)showMeaningWebview:(XZCardView *)cardView; {
    XZResultDetailItem *item = tmpArray[number];
    XZMeaningViewController *controller = [[XZMeaningViewController alloc]init];
    [controller setName:item.name];
    [self.navigationController pushViewController:controller animated:NO];
}

@end
