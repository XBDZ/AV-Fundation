//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THPlayerController.h"
#import "THThumbnail.h"
#import <AVFoundation/AVFoundation.h>
#import "THTransport.h"
#import "THPlayerView.h"
#import "AVAsset+THAdditions.h"
#import "UIAlertView+THAdditions.h"
#import "THNotifications.h"

// AVPlayerItem's status property
#define STATUS_KEYPATH @"status"

// Refresh interval for timed observations of AVPlayer
#define REFRESH_INTERVAL 0.5f

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;


@interface THPlayerController () <THTransportDelegate>

@property (strong, nonatomic) THPlayerView *playerView;

@property(nonatomic,strong)AVAsset *asset;
@property(nonatomic,strong)AVPlayerItem *playerItem;
@property(nonatomic,strong)AVPlayer *player;

@property(nonatomic,weak)id<THTransport>transport;


@property(nonatomic,strong)id timeObserver;
@property(nonatomic,strong)id itemEndObserver;
@property(nonatomic,assign)float lastPlaybackRate;

// Listing 4.4

@end

@implementation THPlayerController

#pragma mark - Setup

- (id)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        
        _asset = [AVAsset assetWithURL:assetURL];
        [self prepareToPlay];
       
    }
    return self;
}

- (void)prepareToPlay {

    NSArray *keys = @[@"tracks",@"duration",@"commonMetadata"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    //添加一个视频的状态观察者
    [self.playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.transport = self.playerView.transport;
    self.transport.delegate = self;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                //监听播放器的时间
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                //设置当前时间和总时长，将时间和播放的媒体同步
                CMTime duration = self.playerItem.duration;
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                //设置视频的标题
                [self.transport setTitle:self.asset.title];
                //开始播放
                [self.player play];
                
            }else{
                [UIAlertView showAlertWithTitle:@"Error" message:@"Failed to load video"];
            }
        });
    }
    
}

#pragma mark - Time Observers
//定期监听事件
- (void)addPlayerItemTimeObserver {

    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    __weak THPlayerController *weakSelf = self;
    void (^callback)(CMTime time) = ^(CMTime time){
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
        
    };
    //定期监听
    [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:callback];
    
}
//条目结束监听
- (void)addItemEndObserverForPlayerItem {

    // Listing 4.9
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    __weak  THPlayerController *weakSelf = self;
    void (^callback)(NSNotification *note) = ^(NSNotification *notifacation){
        //重新定位播放头光标回到0的位置
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            //重新显示时间和搓擦条
            [weakSelf.transport playbackComplete];
        }];
    };
    self.itemEndObserver = [[NSNotificationCenter defaultCenter]addObserverForName:name object:self.playerItem queue:queue usingBlock:^(NSNotification * _Nonnull note) {
        
    }];
    
}
-(void)dealloc
{
    if (self.itemEndObserver) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self.itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        self.itemEndObserver = nil;
    }
}

#pragma mark - THTransportDelegate Methods

- (void)play {

    [self.player play];
    
}

- (void)pause {

    self.lastPlaybackRate = self.player.rate;
    
}
- (void)stop {

    [self.player setRate:0.0f];//相当于 pause 方法
    [self.transport playbackComplete];
}

- (void)jumpedToTime:(NSTimeInterval)time {

    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
    
}

- (void)scrubbingDidStart {

    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
}

- (void)scrubbedToTime:(NSTimeInterval)time {

    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
  
}

- (void)scrubbingDidEnd {

    [self addPlayerItemTimeObserver];
    if (self.lastPlaybackRate > 0.0f) {//视频已经播放过了
        [self.player play];
    }
}


#pragma mark - Thumbnail Generation

- (void)generateThumbnails {

    // Listing 4.14

}


- (void)loadMediaOptions {

    // Listing 4.16
    
}

- (void)subtitleSelected:(NSString *)subtitle {

    // Listing 4.17
    
}


#pragma mark - Housekeeping

- (UIView *)view {
    return self.playerView;
}

@end
