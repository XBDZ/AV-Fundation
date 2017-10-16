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
        AVAudioPlayer *guitarPlayer = [self playerForFile:@""];
        AVAudioPlayer *bassPlayer = [self playerForFile:@""];
        AVAudioPlayer *drumsPlayer = [self playerForFile:@""];
        _players = @[guitarPlayer,bassPlayer,drumsPlayer];
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
    if (!self.playing) {
        for (AVAudioPlayer *player in self.players) {
            [player stop];
            player.currentTime = 0.0f;
        }
        self.playing = YES;
    }
}





@end
