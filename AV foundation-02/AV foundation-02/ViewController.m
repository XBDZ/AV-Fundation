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
@interface ViewController ()

//必须强引用
@property(nonatomic,strong)THPlayerController *playerVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerVC = [[THPlayerController alloc]init];
    
    
}

- (IBAction)playAction:(UIButton *)sender {

    if (!self.playerVC.isPlaying) {
        [self.playerVC play];
    }
}

- (IBAction)stopAction:(UIButton *)sender {
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
