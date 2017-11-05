//
//  THMemo.h
//  AV-Foundation 录音
//
//  Created by apple on 17/10/20.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THMemo : NSObject<NSCoding>

@property(nonatomic,copy,readonly)NSString *title;
@property(nonatomic,strong,readonly)NSURL *url;
@property(nonatomic,copy,readonly)NSString *dateString;
@property(nonatomic,copy,readonly)NSString *timeString;


+(instancetype)memoWithTitle:(NSString *)title url:(NSURL *)url;

-(BOOL)deleteMemo;




@end
