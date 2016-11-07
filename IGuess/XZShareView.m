//
//  XZShareView.m
//  IGuess
//
//  Created by xia on 10/27/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZShareView.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "UIImage+WaterMark.h"
#import "XZStatisticView.h"


#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height


NSInteger shareType; // 0：分享App，1：分享结果详情页

@interface XZShareView()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *WXFriends;
@property (nonatomic, strong) UIButton *WXMoments;
@property (nonatomic, strong) UIButton *QQFriends;
@property (nonatomic, strong) UIButton *QZone;
@property (nonatomic, strong) UIView *line;  // 分割线
@property (nonatomic, strong) UIButton *cancel;

@end

@implementation XZShareView
{
    UIView *screenShotView;
    UITableView *tableView;
    
    NSInteger shotWitdh;
    NSInteger shotHeight;
    NSInteger statusBarHeight;
    NSInteger navigationBarHeight;
    NSInteger tabBarHeight;
    
    NSInteger backViewHeight;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {        
        // 初始化背景view
        self.backView = [[UIView alloc]init];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.alpha = 1;
        
        // 初始化分享控件
        self.WXFriends = [[UIButton alloc]init];
        self.WXMoments = [[UIButton alloc]init];
        self.QQFriends = [[UIButton alloc]init];
        self.QZone = [[UIButton alloc]init];
        self.line = [[UIView alloc]init];
        self.cancel = [[UIButton alloc]init];
        
        // 设置各分享空间icon
        [self.WXFriends setBackgroundImage:[UIImage imageNamed:@"share_weixin_friends"] forState:UIControlStateNormal];
        [self.WXMoments setBackgroundImage:[UIImage imageNamed:@"share_weixin_moments"] forState:UIControlStateNormal];
        [self.QQFriends setBackgroundImage:[UIImage imageNamed:@"share_qq"] forState:UIControlStateNormal];
        [self.QZone setBackgroundImage:[UIImage imageNamed:@"share_qzone"] forState:UIControlStateNormal];
        [self.line setBackgroundColor:[UIColor lightGrayColor]];
        [self.cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        // button绑定事件
        self.WXFriends.enabled = YES;
        self.WXMoments.enabled = YES;
        self.cancel.enabled = YES;
        
        // 11.2 summ qq互联平台的认证失败，暂时不支持
        self.QQFriends.enabled = NO;
        self.QZone.enabled = NO;
        
        
        [self.WXFriends addTarget:self action:@selector(shareToWeiXinFriends) forControlEvents:UIControlEventTouchUpInside];
        [self.WXMoments addTarget:self action:@selector(shareToWeiXinMoments) forControlEvents:UIControlEventTouchUpInside];
        [self.QQFriends addTarget:self action:@selector(shareToQQFriends) forControlEvents:UIControlEventTouchUpInside];
        [self.QZone addTarget:self action:@selector(shareToQZone) forControlEvents:UIControlEventTouchUpInside];
        [self.cancel addTarget:self action:@selector(cancelShare) forControlEvents:UIControlEventTouchUpInside];

        // 添加到父view
        [self addSubview:self.backView];
        [self.backView addSubview:self.WXFriends];
        [self.backView addSubview:self.WXMoments];
        [self.backView addSubview:self.QQFriends];
        [self.backView addSubview:self.QZone];
        [self.backView addSubview:self.line];
        [self.backView addSubview:self.cancel];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    backViewHeight = 120; // 背景view高度
    self.backView.frame = CGRectMake(0, self.frame.size.height - backViewHeight, self.frame.size.width, backViewHeight);

    const NSInteger iconWidth = 45;  // 分享button宽度
    const NSInteger iconHeight = 45; // 分享button高度
    const NSInteger yOffset = 15;    // 分享button在y轴，相对于父view——backView的偏移
    NSInteger xSpace = (self.frame.size.width - iconWidth * 4)/5;
    
    // 4个分享button，y坐标相同，等高等宽
    self.WXFriends.frame = CGRectMake(xSpace, yOffset, iconWidth, iconHeight);
    self.WXMoments.frame = CGRectMake(xSpace * 2 + iconWidth, yOffset, iconWidth, iconHeight);
    self.QQFriends.frame = CGRectMake(xSpace * 3 + iconWidth * 2, yOffset, iconWidth, iconHeight);
    self.QZone.frame = CGRectMake(xSpace * 4 + iconWidth * 3, yOffset, iconWidth, iconHeight);

    self.line.frame = CGRectMake(0, yOffset * 2 + iconHeight, self.frame.size.width, 1);
    self.cancel.frame = CGRectMake((self.frame.size.width - 100)/2, self.line.frame.origin.y + (backViewHeight - self.line.frame.origin.y - 30)/2, 100, 30);
}

#pragma mark - Event response
- (void)shareToWeiXinFriends {
    screenShotView = (UIView *)self.superview;
    
    for (UIView *view in screenShotView.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            tableView = (UITableView *)view;
        }
    }
    
    [self removeFromSuperview];
    
    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;// 不使用文本信息
    sendReq.scene = 0; // 0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    //创建分享内容对象
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    [mediaMessage setThumbImage:[UIImage imageNamed:@"shareThumb"]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    
    //创建多媒体对象
    WXImageObject *imageObj = [WXImageObject object];
    
    // 分享App
    if (shareType == 0) {
        //    urlMessage.title = @"一起来玩猜猜看吧！";//分享标题
        //    urlMessage.description = @"简洁明了的猜词小游戏，那就是我";//分享描述
        NSData *imageData =UIImagePNGRepresentation([UIImage imageNamed:@"AppShare"]);
        imageObj.imageData = imageData;
    } else if (shareType == 1) {
        // UIImage *image = [self addSlaveImage:[self takeSecondViewScreenShot] toMasterImage:[self takeFirstViewScreenShot]];
        UIImage *image = [self takeSecondViewScreenShot];
        NSData *imageData = UIImagePNGRepresentation(image);
        imageObj.imageData = imageData;
    }
    
    //完成发送对象实例
    mediaMessage.mediaObject = imageObj;
    sendReq.message = mediaMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];

}

- (void)shareToWeiXinMoments {
    screenShotView = (UIView *)self.superview;
    
    [self removeFromSuperview];
    
    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;// 不使用文本信息
    sendReq.scene = 1; // 0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    //创建分享内容对象
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    
    //创建多媒体对象
    WXImageObject *imageObj = [WXImageObject object];
    
    // 分享App
    if (shareType == 0) {
        [mediaMessage setThumbImage:[UIImage imageNamed:@"shareThumb"]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"AppShare"]);
        imageObj.imageData = imageData;
    } else if (shareType == 1) {

    }
    
    //完成发送对象实例
    mediaMessage.mediaObject = imageObj;
    sendReq.message = mediaMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}

- (void)shareToQQFriends {
    [self removeFromSuperview];
    
}

- (void)shareToQZone {
    [self removeFromSuperview];
    
}

- (void)cancelShare {
    [self removeFromSuperview];
}



- (UIImage *)takeFirstViewScreenShot {
    UIImage *image = nil;
    XZStatisticView *statView;
    CGSize size = CGSizeMake(self.frame.size.width, 36);
    
    /*
     *UIGraphicsBeginImageContextWithOptions有三个参数
     *size    bitmap上下文的大小，就是生成图片的size
     *opaque  是否不透明，当指定为YES的时候图片的质量会比较好
     *scale   缩放比例，指定为0.0表示使用手机主屏幕的缩放比例
     */
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    for (XZStatisticView *view in screenShotView.subviews) {
        if ([view isKindOfClass:[XZStatisticView class]]) {
            statView = (XZStatisticView *)view;
        }
    }
    
    //此处我截取的是TableView的header.
    [statView.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    if (image != nil) {
        return image;
    }else {
        return nil;
    }

}

- (UIImage *)takeSecondViewScreenShot {
    UIImage *image = nil;
    UIImage *imageNew = nil;
    float yPoint = 0;
    
    // 计算tableView的内容在屏幕上会显示的页数
    int page = ceil(tableView.contentSize.height / tableView.frame.size.height);
    NSLog(@"tableview's size: %f, %f", tableView.contentSize.height, tableView.frame.size.height);
    
    // 保存tableView当前的偏移量
    CGPoint savedContentOffset = tableView.contentOffset;
    CGRect savedFrame = tableView.frame;
    
    UIGraphicsBeginImageContextWithOptions(tableView.contentSize, YES, 0.0);
    
    for (int i = 0; i < page; i++) {
        CGPoint currentPoint = CGPointMake(0, yPoint);
        
        tableView.contentOffset = currentPoint;
        tableView.frame = CGRectMake(0, yPoint, tableView.frame.size.width, tableView.frame.size.height);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [tableView.layer renderInContext:context];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        // tableView拖到最后一页时，tableView.layer内容均加载到内存（summ 猜测）
        if ((imageNew != nil) && (i == page - 1)) {
            imageNew = [self addSlaveImage:image toMasterImage:imageNew];
        } else {
            imageNew = [self takeFirstViewScreenShot];
        }
        
        yPoint += tableView.frame.size.height;
    }
    
    // 关闭context
    UIGraphicsEndImageContext();
    
    // 恢复tableView的偏移量
    tableView.contentOffset = savedContentOffset;
    tableView.frame = savedFrame;

    if (imageNew != nil) {
        return imageNew;
    } else {
        return nil;
    }

}

// 图片拼接
- (UIImage *)addSlaveImage:(UIImage *)slaveImage toMasterImage:(UIImage *)masterImage {
    CGSize size;
    size.width = masterImage.size.width;
    size.height = masterImage.size.height + slaveImage.size.height;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    //Draw masterImage
    [masterImage drawInRect:CGRectMake(0, 0, masterImage.size.width, masterImage.size.height)];
    
    //Draw slaveImage
    [slaveImage drawInRect:CGRectMake(0, masterImage.size.height, masterImage.size.width, slaveImage.size.height)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)saveToDisk:(UIImage *)image {
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/ScreenShot_%f.png",dirPath,[NSDate timeIntervalSinceReferenceDate]];
    NSLog(@"保存路径：%@", path);
    // 处理图片
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    [imageData writeToFile:path atomically:YES];

    NSLog(@"保存成功");
}

- (void)calculateHeight {
    UIResponder *responder = self.nextResponder;
    while (![responder isKindOfClass: [UIViewController class]] && ![responder isKindOfClass: [UIWindow class]]) {
        responder = [responder nextResponder];
    }
    if ([responder isKindOfClass: [UIViewController class]]) {
        UIViewController *viewController = (UIViewController *)responder;
        navigationBarHeight = viewController.navigationController.navigationBar.frame.size.height;
        tabBarHeight = viewController.tabBarController.tabBar.frame.size.height;
    }
}

// 打水印
- (UIImage *)makeWaterMark:(UIImage *)image {
    // 调用方法传入一个image对象,想要添加的文字和文字所在位置
    UIImage *imageWithWaterMark = [UIImage imageWithimage:image
                                     content:@"猜猜看吧\n呵呵呵\n嘻嘻嘻\n呼呼呼"
                                       frame:CGRectMake(100, 250, 100, 100)];
    
    return imageWithWaterMark;
}

@end
