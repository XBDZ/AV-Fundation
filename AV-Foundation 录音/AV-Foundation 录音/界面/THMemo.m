//
//  THMemo.m
//  AV-Foundation 录音
//
//  Created by apple on 17/10/20.
//  Copyright © 2017年 Mr Liu. All rights reserved.
//

#import "THMemo.h"

#define TITLE_KEY        @"title"
#define URL_KEY            @"url"
#define DATE_STRING_KEY    @"dateString"
#define TIME_STRING_KEY    @"timeString"

@implementation THMemo

+(instancetype)memoWithTitle:(NSString *)title url:(NSURL *)url
{
    return [[self alloc]initWithTitle:title url:url];
}

-(id)initWithTitle:(NSString *)title url:(NSURL *)url
{
    self = [super init];
    if (self) {
        _title = [title copy];
        _url = url;

        NSDate *date = [NSDate date];
        _dateString = [self dateStringWithDate:date];
        _timeString = [self timeStringWithDate:date];
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:TITLE_KEY];
    [aCoder encodeObject:self.url forKey:URL_KEY];
    [aCoder encodeObject:self.dateString forKey:DATE_STRING_KEY];
    [aCoder encodeObject:self.timeString forKey:TIME_STRING_KEY];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:TITLE_KEY];
        _url = [aDecoder decodeObjectForKey:URL_KEY];
        _dateString = [aDecoder decodeObjectForKey:DATE_STRING_KEY];
        _timeString = [aDecoder decodeObjectForKey:TIME_STRING_KEY];
    }
    return self;
}

- (NSString *)dateStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"MMddyyyy"];
    return [formatter stringFromDate:date];
}

- (NSString *)timeStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"HHmmss"];
    return [formatter stringFromDate:date];
}


- (NSDateFormatter *)formatterWithFormat:(NSString *)template {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    return formatter;
}

- (BOOL)deleteMemo {
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:self.url error:&error];
    if (!success) {
        NSLog(@"Unable to delete: %@", [error localizedDescription]);
    }
    return success;
}






@end
