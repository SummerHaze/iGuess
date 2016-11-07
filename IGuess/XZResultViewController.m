//
//  XZResultViewController.m
//  IGuess
//
//  Created by xia on 5/31/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZResultViewController.h"
#import "FMDatabase.h"
#import "XZResultDetailItem.h"
#import "XZPlayViewController.h"
#import "XZMeaningViewController.h"
#import "XZDBOperation.h"
#import "XZResultDetailCell.h"
#import "XZResultDetailItem.h"
#import "XZShareView.h"
#import "Masonry.h"
#import "XZStatisticView.h"

@interface XZResultViewController ()

@property (nonatomic) IBOutlet UIBarButtonItem *shareBarButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) XZShareView *shareView;


@end

@implementation XZResultViewController
{
    NSArray *notes;
    NSMutableArray *words;
    NSInteger shareViewHeight;
    CGRect statusRect;
    float yOffset;
    
    NSInteger pass;
    NSInteger fail;
}

#pragma mark - Life cycle
//- (id)initWithCoder:(NSCoder *)aDecoder {
//    if ((self = [super initWithCoder:aDecoder])) {
//        self.hidesBottomBarWhenPushed = YES;
//    }
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=[[UIView alloc]init];
    // self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)viewWillAppear:(BOOL)animated {
    // 数据库读取
    XZDBOperation *operation = [[XZDBOperation alloc]init];
    NSString *sql = @"SELECT * FROM notes ";
    notes = [operation getResultsFromDB:sql];
    
    // 设置分享button action
    self.shareBarButton.target = self;
    self.shareBarButton.action = @selector(share);
    
    // 计算pass和fail词语数量
    XZResultDetailItem *item = [[XZResultDetailItem alloc]init];
    for (item in self.results) {
        if ([item.result isEqualToString:@"pass"]) {
            pass += 1;
        } else {
            fail += 1;
        }
    }
    
    // 给顶部的statisticView赋值
    globalPassCounts = pass;
    globalFailCounts = fail;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter
- (XZShareView *)shareView {
    if (!_shareView) {
        _shareView = [[XZShareView alloc]init];
    }
    return _shareView;
}

#pragma mark - Event response
- (IBAction)back {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowMeaning"]) {
        XZMeaningViewController *controller = segue.destinationViewController;
        controller.name = sender;
    }
}

- (void)share {
    shareType = 1; // 分享结果详情页

    [self.view addSubview:self.shareView];
    
//    statusRect = [[UIApplication sharedApplication] statusBarFrame];
//    shareViewHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - statusRect.size.height;
    
    shareViewHeight = self.view.frame.size.height;
//    DDLogDebug(@"tableview.x: %f,  tableview.y: %f,  tableview.height: %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.view.frame.size.height);
    
    self.shareView.frame = CGRectMake(0,
                                      120,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height
                                      );
    
    [UIView animateWithDuration: 1
                          delay: 0
         usingSpringWithDamping: 0.7
          initialSpringVelocity: 2
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         self.shareView.frame = CGRectMake(0,
                                                           0,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height);}
                     completion: nil];
    
//    self.tableView.scrollEnabled = NO;
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZResultDetailCell *cell = (XZResultDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"CurrentResult" forIndexPath:indexPath];
    
    XZResultDetailItem *item = self.results[indexPath.row];
    NSInteger count = [notes count];
    
    // 获取生词本内的词语，决定页面button的初始状态
    // notes为空，则所有词语都应该处于待添加状态
    if ([notes count] == 0) {
        [cell.addButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    }
    for (XZResultDetailItem *detail in notes) {
        if ([detail.name isEqualToString:item.name]) {
            DDLogInfo(@"词条[%@]已添加进生词本", item.name);
            [cell.addButton setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateNormal];
            break;
        } else {
            count --;
            if (count == 0) {
                [cell.addButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            }
        }
    }

    // 猜词结果展示
    if ([item.result isEqualToString: @"fail"]) {
        NSAttributedString *text = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@     %@", item.name, item.result.uppercaseString]
                                                                  attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        
        cell.resultLabel.attributedText = text;
    } else {
        cell.resultLabel.text = [NSString stringWithFormat:@"%@     %@", item.name, item.result.uppercaseString];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    XZResultDetailItem *item = self.results[indexPath.row];
    [self performSegueWithIdentifier:@"ShowMeaning" sender:item.name];
}

#pragma mark - ResultDetaiCell delegate
- (XZResultDetailItem *)getResultDetailItem:(XZResultDetailCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    XZResultDetailItem *item = self.results[indexPath.row];
    return item;
}

//#pragma mark - UIScrollView delegate
//// 滑动tableView后再点击分享，保证shareView依然在屏幕最底端
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    yOffset = scrollView.contentOffset.y;
//}


@end
