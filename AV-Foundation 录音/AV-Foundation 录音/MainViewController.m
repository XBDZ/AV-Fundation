//
//  ViewController.m
//  AV-Foundation 录音
//
//  Created by apple on 17/10/20.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#define MEMOS_ARCHIVE    @"memos.archive"

#import "MainViewController.h"
#import "THRecorderController.h"

#import "THMemoCell.h"
#import "THMemo.h"
@interface MainViewController ()<THRecorderControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)THRecorderController *controller;

@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSMutableArray *memos;

@end

@implementation MainViewController
static NSString * MEMO_CELL = @"memoCell";

-(NSMutableArray *)memos
{
    if (_memos == nil) {
        _memos = [NSMutableArray array];
    }
    return _memos;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controller = [[THRecorderController alloc]init];
    self.controller.delegate = self;
 
    UIImage *recordImage = [[UIImage imageNamed:@"record"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *pauseImage = [[UIImage imageNamed:@"pause"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *stopImage = [[UIImage imageNamed:@"stop"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *buttonBackImage = [[UIImage imageNamed:@"transport_bg"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    [self.recordBtn setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
    [self.recordBtn setImage:recordImage forState:UIControlStateNormal];
    [self.recordBtn setImage:pauseImage forState:UIControlStateSelected];
    [self.stopBtn setImage:stopImage forState:UIControlStateNormal];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *archivePath = [docsDir stringByAppendingPathComponent:MEMOS_ARCHIVE];
    NSURL *url = [NSURL fileURLWithPath:archivePath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        _memos = [NSMutableArray array];
    } else {
        _memos = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}
//录音按钮
- (IBAction)recordAction:(UIButton *)sender {
    if (![sender isSelected]) {
        [self startTimer];
        [self.controller record];
    }else{
        [self.controller pause];
    }
    [sender setSelected:![sender isSelected]];
}
//停止按钮
- (IBAction)stopAction:(UIButton *)sender {
    self.recordBtn.selected = NO;
    self.stopBtn.selected = NO;
    [self.controller stopWithCompletionHandle:^(BOOL result) {
        double delayInSeconds = 0.01;
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showSaveDialog];
        });
    }];
}


-(void)startTimer
{
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateTimeDisplay) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}
-(void)updateTimeDisplay
{
    self.timeLable.text = self.controller.formattedCurrentTime;
}

-(void)showSaveDialog
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Save Recording"
                                          message:@"Please provide a name"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"My Recording", @"Login");
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *filename = [alertController.textFields.firstObject text];
        [self.controller saveRecordingWithName:filename completionHandel:^(BOOL success, id object) {
            if (success) {
                [self.memos addObject:object];
                
                //把数组写入到沙盒
                NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *archivePath = [path stringByAppendingPathComponent:MEMOS_ARCHIVE];
                NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:self.memos];
                [fileData writeToURL:[NSURL fileURLWithPath:archivePath] atomically:YES];
                
                [self.tableView reloadData];
            }else{
                NSLog(@"Error saving file: %@", [object localizedDescription]);
            }
        }];
    }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
            
        [self presentViewController:alertController animated:YES completion:nil];
    
}
                               
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return self.memos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    THMemoCell *cell = [tableView dequeueReusableCellWithIdentifier:MEMO_CELL forIndexPath:indexPath];
    THMemo *memo = self.memos[indexPath.row];

    cell.memo = memo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    THMemo *memo = self.memos[indexPath.row];
    [self.controller playbackMemo:memo];
}


-(void)interruptionBegan
{
    self.recordBtn.selected = NO;
    [self.timer invalidate];
    self.timer = nil;
}

@end
