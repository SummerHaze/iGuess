//
//  VideoViewController.m
//  IGuess
//
//  Created by xia on 9/14/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XZVideoEngine.h"

@interface XZVideoViewController ()

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
@property (strong, nonatomic) XZVideoEngine         *videoEngine;

@end

@implementation XZVideoViewController
{
    
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
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    if (_videoEngine == nil) {
        CGRect videoFrame = CGRectMake(50, 50, 200, 200);
        [self.videoEngine previewLayer].frame = videoFrame;
//        self.view.bounds;
        [self.view.layer insertSublayer:[self.videoEngine previewLayer] atIndex:0];
    }
    [self.videoEngine startUp];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.videoEngine shutdown];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter
- (XZVideoEngine *)videoEngine {
    if (_videoEngine == nil) {
        _videoEngine = [[XZVideoEngine alloc] init];
//        _videoEngine.delegate = self;
    }
    return _videoEngine;
}

@end
