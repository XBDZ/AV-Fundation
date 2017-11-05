//
//  THMemoCell.m
//  AV-Foundation 录音
//
//  Created by apple on 17/10/20.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import "THMemoCell.h"
#import "THMemo.h"

@interface THMemoCell ()

@property (weak, nonatomic) IBOutlet UILabel *titLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@end

@implementation THMemoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setMemo:(THMemo *)memo
{
    _memo = memo;
    self.titLabel.text = memo.title;
//    NSLog(@"-------------%@",memo.dateString);
    self.dateLabel.text = memo.dateString;
    self.timeLabel.text = memo.timeString;
}





@end
