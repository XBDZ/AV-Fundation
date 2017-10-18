//
//  THPlayerController.m
//  AV foundation-02
//
//  Created by Mr Liu on 2017/10/8.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import "THPlayerController.h"
#import <AVFoundation/AVFoundation.h>

@interface THPlayerController()

@property(nonatomic)BOOL playing;

@property(nonatomic,strong)NSArray *players;


@end

@implementation THPlayerController


-(instancetype)init
{
    self = [super init];
    if (self) {
        AVAudioPlayer *guitarPlayer = [self playerForFile:@"guitar"];
        AVAudioPlayer *bassPlayer = [self playerForFile:@"bass"];
        AVAudioPlayer *drumsPlayer = [self playerForFile:@"drums"];
        _players = @[guitarPlayer,bassPlayer,drumsPlayer];
 
        
        //注册中断的通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        //注册线路变化的通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        
        
    }
    return self;
}

-(AVAudioPlayer *)playerForFile:(NSString *)name
{
    NSURL *fileURL = [[NSBundle mainBundle]URLForResource:name withExtension:@"caf"];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
    if (player) {
        player.numberOfLoops = -1;
        player.enableRate = YES;
        [player prepareToPlay];
    }else{
        NSLog(@"error:%@",[error localizedDescription]);
    }
    return player;
}

-(void)play
{
    if (!self.playing) {
        NSTimeInterval delayTime = [self.players[0] deviceCurrentTime] + 0.01;
        for (AVAudioPlayer *player in self.players) {
            [player playAtTime:delayTime];
        }
        self.playing = YES;
    }
}

-(void)stop
{
    if (self.playing) {
        for (AVAudioPlayer *player in self.players) {
            [player stop];
            player.currentTime = 0.0f;
        }
        self.playing = NO;
    }
}

-(void)adjustRate:(float)rate
{
    for (AVAudioPlayer *player in self.players) {
        player.rate = rate;
    }
}

-(void)adjustPan:(float)pan forPlayerAtIndex:(NSInteger)index
{
    if ([self isValidIndex:index]) {
        AVAudioPlayer *player = self.players[index];
        player.pan = pan;
    }
}

-(BOOL)isValidIndex:(NSInteger)index
{
    return index == 0 || index < self.players.count;
}

-(void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {//中断开始
        [self stop];
        if ([self.delegate respondsToSelector:@selector(playbackStopped)]) {
            [self.delegate playbackStopped];
        }
        
    }else{
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
       
        if (options == AVAudioSessionInterruptionOptionShouldResume) { //中断恢复
             [self play];
            if ([self.delegate respondsToSelector:@selector(playbackBegin)]) {
                [self.delegate playbackBegin];
            }
        }
    }
}

-(void)handleRouteChange:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *previonRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *previousOutput = previonRoute.outputs[0];
        NSString *porType = previousOutput.portType;
        if ([porType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self stop];
            [self.delegate playbackStopped];
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




















@end
