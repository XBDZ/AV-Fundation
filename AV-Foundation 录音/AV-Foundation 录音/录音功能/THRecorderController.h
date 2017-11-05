//
//  THRecorderController.h
//  AV-Foundation 录音
//
//  Created by apple on 17/10/20.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class THMemo;

@protocol THRecorderControllerDelegate <NSObject>

-(void)interruptionBegan;

@end

@interface THRecorderController : NSObject

@property (nonatomic, readonly) NSString *formattedCurrentTime;
@property(nonatomic,weak)id<THRecorderControllerDelegate>delegate;


-(BOOL)record;

-(void)pause;

-(void)stopWithCompletionHandle:(void(^)(BOOL))handler;

-(void)saveRecordingWithName:(NSString *)name completionHandel:(void(^)(BOOL,id))handel;

-(BOOL)playbackMemo:(THMemo *)memo;

@end
