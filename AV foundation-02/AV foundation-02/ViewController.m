//
//  ViewController.m
//  AV foundation-02
//
//  Created by Mr Liu on 2017/10/7.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import "ViewController.h"
#import "THPlayerController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<THPlayerControllerDelegate>

//必须强引用
@property(nonatomic,strong)THPlayerController *playerVC;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerVC = [[THPlayerController alloc]init];
    self.playerVC.delegate = self;
    
    
}

- (IBAction)playAction:(UIButton *)sender {

    if (!self.playerVC.isPlaying) {
        [self.playerVC play];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        [self.playerVC stop];
        [sender setTitle:@"停止" forState:UIControlStateNormal];
    }
    sender.selected = !sender.selected;
}


- (void)playbackStopped {
    self.playButton.selected = NO;
     [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
}

- (void)playbackBegan {
    self.playButton.selected = YES;
     [self.playButton setTitle:@"停止" forState:UIControlStateNormal];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
