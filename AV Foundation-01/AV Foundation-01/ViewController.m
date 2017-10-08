//
//  ViewController.m
//  AV Foundation-01
//
//  Created by Mr Liu on 2017/10/7.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import "ViewController.h"
#import "THSpeechController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
}
- (IBAction)playAction:(UIButton *)sender {
    
    THSpeechController * sppeech = [THSpeechController speechController];
    [sppeech beginConversation];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
