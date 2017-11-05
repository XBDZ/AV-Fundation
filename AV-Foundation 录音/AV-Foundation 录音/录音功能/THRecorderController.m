//
//  THRecorderController.m
//  AV-Foundation 录音
//
//  Created by apple on 17/10/20.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//


#import "THRecorderController.h"
#import <AVFoundation/AVFoundation.h>
#import "THMemo.h"

@interface THRecorderController()<AVAudioRecorderDelegate>

@property(nonatomic,strong)AVAudioPlayer *player;

@property(nonatomic,strong)AVAudioRecorder *recoder;

@property(nonatomic,strong)void (^completionHandle)(BOOL);



@end

@implementation THRecorderController

/*
 音频格式支持的值
 kAudioFormatLinearPCM     保真度最高  文件最大
 kAudioFormatMPEG4AAC      保真度高  文件小
 kAudioFormatAppleLossless
 kAudioFormatAppleIMA4     保真度高  文件小
 kAudioFormatiLBC
 kAudioFormatULaw
 */

-(instancetype)init
{
    if (self = [super init]) {
        NSString *tmDir = NSTemporaryDirectory();
        NSString *filePath = [tmDir stringByAppendingPathComponent:@"memo.caf"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        NSDictionary *settings = @{
                                   AVFormatIDKey :@(kAudioFormatAppleIMA4),  //音频格式
                                   AVSampleRateKey :@44100.f,   //采样率
                                   AVNumberOfChannelsKey :@1,   //通道数 1表示单通道 2表示立体声
                                   AVEncoderBitDepthHintKey :@16,  //位深
                                   AVEncoderAudioQualityKey :@(AVAudioQualityMedium)
                                   };
        NSError *error;
        self.recoder = [[AVAudioRecorder alloc]initWithURL:fileURL settings:settings error:&error];
        
        if (self.recoder) {
            self.recoder.delegate = self;
            [self.recoder prepareToRecord];
        }else{
            NSLog(@"Error:%@",[error localizedDescription]);
        }
        
    }
    return self;
}

-(BOOL)record
{
    return [self.recoder record];
}

-(void)pause
{
    [self.recoder pause];
}

-(void)stopWithCompletionHandle:(void (^)(BOOL))handler
{
    self.completionHandle = handler;
    [self.recoder stop];
    
}
//录音完成代理方法
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)success
{
    if (self.completionHandle) {
        self.completionHandle(success);
    }
}

-(void)saveRecordingWithName:(NSString *)name completionHandel:(void (^)(BOOL, id))handel
{
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *filename = [NSString stringWithFormat:@"%@-%f.caf",name,timestamp];
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *destPath = [docsDir stringByAppendingPathComponent:filename];
    NSURL *srcURL = self.recoder.url;
    NSURL *destURL = [NSURL fileURLWithPath:destPath];
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]copyItemAtURL:srcURL toURL:destURL error:&error];
    if (success) {
        handel(YES,[THMemo memoWithTitle:name url:destURL]);
    }else{
        handel(NO,error);
    }
    
}
//回放录制的音频
-(BOOL)playbackMemo:(THMemo *)memo{
    [self.player stop];

    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:memo.url error:nil];
    if (self.player) {
        [self.player play];
        return YES;
    }
    return NO;
}

-(NSString *)formattedCurrentTime{
    
    NSInteger time = (NSInteger)self.recoder.currentTime;
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    return [NSString stringWithFormat:format,hours,minutes,seconds];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    if (self.delegate) {
        [self.delegate interruptionBegan];
    }
}



@end
