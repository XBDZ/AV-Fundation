//
//  THSpeechController.m
//  AV Foundation
//
//  Created by Mr Liu on 17/9/26.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import "THSpeechController.h"

@interface THSpeechController()

@property(nonatomic,strong)AVSpeechSynthesizer *synthesizer;

@property(nonatomic,strong)NSArray *voices;

@property(nonatomic,strong)NSArray *speechStrings;


@end

@implementation THSpeechController


+(instancetype)speechController
{
    return [[self alloc]init];
}

-(id)init
{
    self = [super init];
    if (self) {
        _synthesizer = [[AVSpeechSynthesizer alloc]init];
        
        _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],
                    [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]];
        _speechStrings = [self buildSpeechstrings];
        
    }
    return self;
}
-(NSArray *)buildSpeechstrings{
    
    return @[@"Hello AV Foundation ,How are You",
             @"Thanks for asking",
             @"Very!",
             @"Oh,they're all my babies",
             @"It was great to speak with you"];
    
}
-(void)beginConversation
{
    for (NSInteger i = 0; i < self.speechStrings.count; i++) {
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:self.speechStrings[i]];
        utterance.voice = self.voices[i % 2];
        utterance.rate = 0.4f;
        utterance.pitchMultiplier = 0.8f;
        utterance.postUtteranceDelay = 0.1f;
        [self.synthesizer speakUtterance:utterance];
    }
}






















@end
