//
//  NSDate+KDXFormatDate.h
//  koudaixiang
//
//  Created by Blankwonder on 4/9/11.
//  Copyright 2011 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (KDXFormatDate) 

- (NSString *)stringByMessageFormat;
- (NSString *)stringByMessageFormatLongFormat:(BOOL)longFormat;
- (NSString *)stringByMouthDayHourMinuteStyle;
- (NSString *)stringByHourMinuteStyle;
- (NSString *)stringByConvertToDateOnly;
- (NSString *)stringByConvertToUNIXTimeStamp;

- (NSNumber *)numberByConvertToUNIXTimeStamp;

- (NSString *)stringByConvertToRecentFormat;
- (NSString *)stringByConvertToRecentFormatUsingWeekday:(BOOL)weekday;

@end
