//
//  THPlayerController.h
//  AV foundation-02
//
//  Created by Mr Liu on 2017/10/8.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THPlayerController : NSObject

@property(nonatomic,readonly,getter=isPlaring) BOOL playing;


-(void)play;

-(void)stop;

-(void)adjustRate:(float)rate;

-(void)adjustPan:(float)pan forPlayerAtIndex:(NSInteger)index;

-(void)adjustVolume:(float)Volume forPlayerAtIndex:(NSInteger)index;


@end
