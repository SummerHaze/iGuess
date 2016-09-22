//
//  XZVideoEngine.h
//  IGuess
//
//  Created by xia on 9/14/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

@protocol XZVideoEngineDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@end


@interface XZVideoEngine : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (weak, nonatomic) id <XZVideoEngineDelegate> delegate;
@property (atomic, strong) NSString *videoPath;//视频路径
@property (atomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (atomic, assign) CGFloat maxRecordTime;//录制最长时间


//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *) previewLayer;
//启动录制功能
- (void) startUp;
//关闭录制功能
- (void) shutdown;
//开始录制
- (void) startCapture;
//暂停录制
- (void) pauseCapture;
//停止录制
- (void) stopCaptureHandler:(void (^)(UIImage *movieImage))handler;
//继续录制
- (void) resumeCapture;
//将mov的视频转成mp4
//- (void) changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler;

@end
