//
//  XZVideoEngine.m
//  IGuess
//
//  Created by xia on 9/14/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "XZVideoEngine.h"
#import "XZVideoEncoder.h"
#import <Photos/Photos.h>

@interface XZVideoEngine() <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate> {
    CMTime _timeOffset;//录制的偏移CMTime
    CMTime _lastVideo;//记录上一次视频数据文件的CMTime
    CMTime _lastAudio;//记录上一次音频数据文件的CMTime
    
    NSInteger _cx;//视频分辨的宽
    NSInteger _cy;//视频分辨的高
    int _channels;//音频通道
    Float64 _samplerate;//音频采样率
}

@property (strong, nonatomic) AVCaptureSession           *recordSession;//捕获视频的会话
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
@property (strong, nonatomic) AVCaptureDeviceInput       *backCameraInput;//后置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *frontCameraInput;//前置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *audioMicInput;//麦克风输入
@property (strong, nonatomic) AVCaptureConnection        *audioConnection;//音频录制连接
@property (strong, nonatomic) AVCaptureConnection        *videoConnection;//视频录制连接
@property (strong, nonatomic) AVCaptureVideoDataOutput   *videoOutput;//视频输出
@property (strong, nonatomic) AVCaptureAudioDataOutput   *audioOutput;//音频输出
@property (copy  , nonatomic) dispatch_queue_t           captureQueue;//录制的队列
@property (strong, nonatomic) XZVideoEncoder           *videoEncoder;//录制编码

@property (atomic, assign) BOOL isCapturing;//正在录制
@property (atomic, assign) BOOL isPaused;//是否暂停
@property (atomic, assign) BOOL isDisconnected;//是否中断
@property (atomic, assign) CMTime startTime;//开始录制的时间
@property (atomic, assign) CGFloat currentRecordTime;//当前录制时间

@end

@implementation XZVideoEngine

#pragma mark - public方法
//启动录制
- (void)startUp {
    //    NSLog(@"启动录制功能");
    self.startTime = CMTimeMake(0, 0);
    self.isCapturing = NO;
    self.isPaused = NO;
    self.isDisconnected = NO;
    [self.recordSession startRunning];

}

//关闭录制
- (void)shutdown {
    _startTime = CMTimeMake(0, 0);
    if (_recordSession) {
        [_recordSession stopRunning];
    }
    [_videoEncoder finishWithCompletionHandler:^{
        NSLog(@"录制完成");
    }];
}

//开始录制
- (void) startCapture {
    @synchronized(self) {
        if (!self.isCapturing) {
            //            NSLog(@"开始录制");
            self.videoEncoder = nil;
            self.isPaused = NO;
            self.isDisconnected = NO;
            _timeOffset = CMTimeMake(0, 0);
            self.isCapturing = YES;
        }
    }
}
//暂停录制
- (void) pauseCapture {
    @synchronized(self) {
        if (self.isCapturing) {
            self.isPaused = YES;
            self.isDisconnected = YES;
        }
    }
}
//继续录制
- (void) resumeCapture {
    @synchronized(self) {
        if (self.isPaused) {
            //            NSLog(@"继续录制");
            self.isPaused = NO;
        }
    }
}

//停止录制
- (void)stopCaptureHandler:(void (^)(UIImage *movieImage))handler {
    @synchronized(self) {
        if (self.isCapturing) {
            NSString *path = self.videoEncoder.path;
            NSURL *url = [NSURL fileURLWithPath:path];
            self.isCapturing = NO;
            dispatch_async(_captureQueue, ^{
                [self.videoEncoder finishWithCompletionHandler:^{
                    self.isCapturing = NO;
                    self.videoEncoder = nil;
//                    self.startTime = CMTimeMake(0, 0);
//                    self.currentRecordTime = 0;
//                    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
//                        });
//                    }
                    
                    // 相册操作
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^ {
                        // 请求创建Asset
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];}
                                                      completionHandler:^(BOOL success, NSError * _Nullable error) {
                                                          NSLog(@"视频保存成功");}
                     ];
//                    [self movieToImageHandler:handler]; // 获取视频第一帧图片
                }];
            });
        }
    }
}

//// 将mov文件转为MP4文件
//- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler {
//    AVAsset *video = [AVAsset assetWithURL:mediaURL];
//    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPreset1280x720];
//    exportSession.shouldOptimizeForNetworkUse = YES;
//    exportSession.outputFileType = AVFileTypeMPEG4;
//    NSString * basePath=[self getVideoCacheDir];
//    
//    self.videoPath = [basePath stringByAppendingPathComponent:[self getFileName:@"video" format:@"mp4"]];
//    exportSession.outputURL = [NSURL fileURLWithPath:self.videoPath];
//    [exportSession exportAsynchronouslyWithCompletionHandler:^{
//        [self movieToImageHandler:handler];
//    }];
//}
//
//#pragma mark - private方法
////获取视频第一帧的图片
//- (void)movieToImageHandler:(void (^)(UIImage *movieImage))handler {
//    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
//    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    generator.appliesPreferredTrackTransform = TRUE;
//    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
//    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
//    AVAssetImageGeneratorCompletionHandler generatorHandler =
//    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
//        if (result == AVAssetImageGeneratorSucceeded) {
//            UIImage *thumbImg = [UIImage imageWithCGImage:im];
//            if (handler) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    handler(thumbImg);
//                });
//            }
//        }
//    };
//    [generator generateCGImagesAsynchronouslyForTimes:
//    [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
//}

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //通过AVCaptureSession初始化
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.recordSession];
        //设置比例为铺满全屏
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}

//捕获视频的会话
- (AVCaptureSession *)recordSession {
    if (_recordSession == nil) {
        _recordSession = [[AVCaptureSession alloc] init];
        //添加后置摄像头的输入
        if ([_recordSession canAddInput:self.backCameraInput]) {
            [_recordSession addInput:self.backCameraInput];
        }
        //添加后置麦克风的输入
        if ([_recordSession canAddInput:self.audioMicInput]) {
            [_recordSession addInput:self.audioMicInput];
        }
        //添加视频输出
        if ([_recordSession canAddOutput:self.videoOutput]) {
            [_recordSession addOutput:self.videoOutput];
            //设置视频的分辨率
            // 此处设置的分辨率，影响视频输出流的尺寸
            _cx = 1280;
            _cy = 720;
        }
        //添加音频输出
        if ([_recordSession canAddOutput:self.audioOutput]) {
            [_recordSession addOutput:self.audioOutput];
        }
        //设置视频录制的方向
        DDLogDebug(@"support video orientation : %d", self.videoConnection.isVideoOrientationSupported);
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _recordSession;
}

#pragma mark - AVFoundation input
//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            DDLogError(@"获取后置摄像头失败");
        }
    }
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            DDLogError(@"获取前置摄像头失败");
        }
    }
    return _frontCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            DDLogError(@"获取麦克风失败");
        }
    }
    return _audioMicInput;
}

#pragma mark - AVFoundation output
//视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        // 设置delegate，在captureQueue中调用captureOutput获取frame。queue必须是serial queue，保证frame的有序传递
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
        // 设置硬件解码器输出格式，提高转码效率
        NSDictionary* capSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _videoOutput.videoSettings = capSettings;
    }
    return _videoOutput;
}

//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _audioOutput;
}

//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


//切换前后置摄像头
//- (void)changeCameraInputDeviceisFront:(BOOL)isFront {
//    if (isFront) {
//        [self.recordSession stopRunning];
//        [self.recordSession removeInput:self.backCameraInput];
//        if ([self.recordSession canAddInput:self.frontCameraInput]) {
//            [self changeCameraAnimation];
//            [self.recordSession addInput:self.frontCameraInput];
//        }
//    }else {
//        [self.recordSession stopRunning];
//        [self.recordSession removeInput:self.frontCameraInput];
//        if ([self.recordSession canAddInput:self.backCameraInput]) {
//            [self changeCameraAnimation];
//            [self.recordSession addInput:self.backCameraInput];
//        }
//    }
//}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//开启闪光灯
- (void)openFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOff) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOn;
        backCamera.flashMode = AVCaptureFlashModeOn;
        [backCamera unlockForConfiguration];
    }
}
//关闭闪光灯
- (void)closeFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOn) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.flashMode = AVCaptureTorchModeOff;
        [backCamera unlockForConfiguration];
    }
}

//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("iguess.xzrecordengine.capture", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}


#pragma mark - 存储视频
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    BOOL isVideo = YES;
    @synchronized(self) {
        if (!self.isCapturing || self.isPaused) {
            return;
        }
        if (captureOutput != self.videoOutput) {
            isVideo = NO;
        }
        //初始化编码器，当有音频和视频参数时创建编码器
        if ((self.videoEncoder == nil) && !isVideo) {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            [self setAudioFormat:fmt];
            
            NSString *videoFileName = [self getFileName:@"video" format:@"mp4"];
            self.videoPath = [[self getVideoCacheDir] stringByAppendingPathComponent:videoFileName];
            self.videoEncoder = [XZVideoEncoder encoderForPath:self.videoPath Height:_cy width:_cx channels:_channels samples:_samplerate];
        }
//        //判断是否中断录制过
//        if (self.isDisconnected) {
//            if (isVideo) {
//                return;
//            }
//            self.isDisconnected = NO;
//            // 计算暂停的时间
//            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//            CMTime last = isVideo ? _lastVideo : _lastAudio;
//            if (last.flags & kCMTimeFlags_Valid) {
//                if (_timeOffset.flags & kCMTimeFlags_Valid) {
//                    pts = CMTimeSubtract(pts, _timeOffset);
//                }
//                CMTime offset = CMTimeSubtract(pts, last);
//                if (_timeOffset.value == 0) {
//                    _timeOffset = offset;
//                }else {
//                    _timeOffset = CMTimeAdd(_timeOffset, offset);
//                }
//            }
//            _lastVideo.flags = 0;
//            _lastAudio.flags = 0;
//        }
        // 增加sampleBuffer的引用计时,这样我们可以释放这个或修改这个数据，防止在修改时被释放
        CFRetain(sampleBuffer);
        if (_timeOffset.value > 0) {
            CFRelease(sampleBuffer);
            //根据得到的timeOffset调整
            sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
        }
//        // 记录暂停上一次录制的时间
//        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
//        if (dur.value > 0) {
//            pts = CMTimeAdd(pts, dur);
//        }
//        if (isVideo) {
//            _lastVideo = pts;
//        } else {
//            _lastAudio = pts;
//        }
    }
//    CMTime dur = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//    if (self.startTime.value == 0) {
//        self.startTime = dur;
//    }
//    CMTime sub = CMTimeSubtract(dur, self.startTime);
//    self.currentRecordTime = CMTimeGetSeconds(sub);
//    if (self.currentRecordTime > self.maxRecordTime) {
//        if (self.currentRecordTime - self.maxRecordTime < 0.1) {
//            if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
//                });
//            }
//        }
//        return;
//    }
//    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
//        });
//    }
    // 进行数据编码
    [self.videoEncoder encodeFrame:sampleBuffer isVideo:isVideo];
    CFRelease(sampleBuffer);
}

//设置音频格式
- (void)setAudioFormat:(CMFormatDescriptionRef)fmt {
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    _samplerate = asbd->mSampleRate;
    _channels = asbd->mChannelsPerFrame;
    
}

//获得视频存放文件夹
- (NSString *)getVideoCacheDir {
    NSString *videoCacheDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"] ;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
      // summ 很奇怪，为什么要判断videos下面是否有文件？先注释掉
//    // 该existed仅能表示videoCacheDir中是否有文件或文件夹，路径本身是否是文件夹的判断结果，存储在isDir中
//    BOOL existed = [fileManager fileExistsAtPath:videoCacheDir isDirectory:&isDir];
//    // 本身不是文件夹，或目录下没有文件和文件夹，则创建videos文件夹
//    if ( !(isDir == YES && existed == YES) ) {
//        [fileManager createDirectoryAtPath:videoCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
//    };
    
    // 仅判断路径本身不是文件夹，否则创建
    if (isDir == NO) {
        [fileManager createDirectoryAtPath:videoCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    };
    
    return videoCacheDir;
}

- (NSString *)getFileName:(NSString *)type format:(NSString *)format {
    // 当前时间戳
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    // 当前时间
    NSDate *NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    // 按照formatter格式，格式化时间
    NSString *timeStr = [formatter stringFromDate:NowDate];
    // 保存的文件名
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",type,timeStr,format];
    
    return fileName;
}

//调整媒体数据的时间
- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

#pragma mark - 切换动画
//- (void)changeCameraAnimation {
//    CATransition *changeAnimation = [CATransition animation];
//    changeAnimation.delegate = self;
//    changeAnimation.duration = 0.45;
//    changeAnimation.type = @"oglFlip";
//    changeAnimation.subtype = kCATransitionFromRight;
//    changeAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
//    [self.previewLayer addAnimation:changeAnimation forKey:@"changeAnimation"];
//}
//
//- (void)animationDidStart:(CAAnimation *)animated {
//    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
//    [self.recordSession startRunning];
//}



@end
