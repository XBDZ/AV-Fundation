//
//  THSpeechController.h
//  AV Foundation
//
//  Created by Mr Liu on 17/9/26.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface THSpeechController : NSObject

@property(nonatomic,strong,readonly)AVSpeechSynthesizer *synthesizer;


+(instancetype)speechController;

-(void)beginConversation;







@end
