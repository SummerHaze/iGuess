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
    UITableView *_screenShotView;
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
        self.QQFriends.enabled = YES;
        self.QZone.enabled = YES;
        self.cancel.enabled = YES;
        
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
    
//    [self mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.superview.mas_bottom);
//        //        make.left.equalTo(self.view.mas_left);
//        //        make.right.equalTo(self.view.mas_right);
//        //        make.height.equalTo(@44);
//    }];
    
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
    
    
//    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.superview.mas_bottom);
//        //        make.left.equalTo(self.view.mas_left);
//        //        make.right.equalTo(self.view.mas_right);
//        //        make.height.equalTo(@44);
//    }];
//    
//    [self calculateHeight];
    
}

#pragma mark - Event response
- (void)shareToWeiXinFriends {
    _screenShotView = (UITableView *)self.superview;
    _screenShotView.scrollEnabled = YES;
    
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
        NSData *imageData = [self getScreenShot];
        imageObj.imageData = imageData;
    }
    
    //完成发送对象实例
    mediaMessage.mediaObject = imageObj;
    sendReq.message = mediaMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];

}

- (void)shareToWeiXinMoments {
    _screenShotView = [[UITableView alloc]init];
    _screenShotView = (UITableView *)self.superview;
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
        NSData *imageData = [self getScreenShot];
        imageObj.imageData = imageData;
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
    
//    [UIView animateWithDuration: 1
//                          delay: 0
//         usingSpringWithDamping: 0.7
//          initialSpringVelocity: 2
//                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
//                     animations: ^{
//                         self.frame = CGRectMake(self.frame.origin.x,
//                                                self.frame.origin.y + self.frame.size.height,
//                                                self.frame.size.width,
//                                                self.frame.size.height);
//                     } completion: nil];
//    _screenShotView = (UITableView *)self.superview;
//    _screenShotView.scrollEnabled = YES;
    
    [self removeFromSuperview];
    
//    self.tabBarController.tabBar.hidden = YES;
    
}



- (NSData *)getScreenShot {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(_screenShotView.contentSize, YES, 0.0);
    
    //保存collectionView当前的偏移量
    CGPoint savedContentOffset = _screenShotView.contentOffset;
    CGRect saveFrame = _screenShotView.frame;
    
    //将collectionView的偏移量设置为(0,0)
    _screenShotView.contentOffset = CGPointZero;
    _screenShotView.frame = CGRectMake(0, 0, _screenShotView.contentSize.width, _screenShotView.contentSize.height);
    
    //在当前上下文中渲染出collectionView
    [_screenShotView.layer renderInContext: UIGraphicsGetCurrentContext()];
    //截取当前上下文生成Image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //恢复collectionView的偏移量
    _screenShotView.contentOffset = savedContentOffset;
    _screenShotView.frame = saveFrame;
    
    UIGraphicsEndImageContext();
    
    UIImage *imageWithWaterMark = [self makeWaterMark:image];
    
    if (imageWithWaterMark != nil) {
        return UIImagePNGRepresentation(imageWithWaterMark);
    }else {
        return nil;
    }
    
    

//    UIImage *image = [self takeScreenShot: _screenShotView];
//    NSData *imageData = UIImagePNGRepresentation(image);
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
//    [self saveToDisk:image];
//    
//    return imageData;

}

- (UIImage *)takeScreenShot:(UIView *)view {
    statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    shotWitdh = SCREEN_WIDTH;
    shotHeight = SCREEN_HEIGHT - statusBarHeight - navigationBarHeight;
    
    // 开启位图上下文
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    UIGraphicsBeginImageContext(CGSizeMake(SCREEN_WIDTH, shotHeight));
    
    // 获取当前上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
//    NSLog(@"2current context: %@",UIGraphicsGetCurrentContext());
    // 把图层渲染到上下文
    [view.layer renderInContext:context];
    // 从上下文取出图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
//    [image drawInRect:CGRectMake(0, 0 - statusBarHeight - navigationBarHeight, shotWitdh, shotHeight)];
//    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
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

- (UIImage *)makeWaterMark:(UIImage *)image {
    // 调用方法传入一个image对象,想要添加的文字和文字所在位置
    UIImage *imageWithWaterMark = [UIImage imageWithimage:image
                                     content:@"猜猜看吧\n呵呵呵\n嘻嘻嘻\n呼呼呼"
                                       frame:CGRectMake(100, 250, 100, 100)];
    
    return imageWithWaterMark;
}

@end
