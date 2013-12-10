//
//  NSDate+KDXFormatDate.m
//  koudaixiang
//
//  Created by Blankwonder on 4/9/11.
//  Copyright 2011 Suixing Tech. All rights reserved.
//

#import "NSDate+KDXFormatDate.h"
#import "NSDate+Utilities.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]
#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

static NSDateFormatter *ShortDateFormatter;

@implementation NSDate (KDXFormatDate)

- (NSString *)stringByMessageFormat
{
    return [self stringByMessageFormatLongFormat:NO];
}

- (NSString *)stringByMessageFormatLongFormat:(BOOL)longFormat {
    if (ShortDateFormatter == nil) {
        ShortDateFormatter = [[NSDateFormatter alloc] init];
        [ShortDateFormatter setDateFormat:@"M月d日"];
        [ShortDateFormatter setLocale:[NSLocale currentLocale]];
    }
    
    NSTimeInterval minutes = [self timeIntervalSinceNow] / 60;
    
    minutes = - minutes;
    if (minutes < 1) {
        return @"刚才";
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%.0f分钟前", minutes];
    } else if (minutes < 60 * 24) {
        return [NSString stringWithFormat:@"%.0f小时前", minutes / 60];
    } else if (minutes < 60 * 24 * 7) {
        return [NSString stringWithFormat:@"%.0f天前", minutes / 60 / 24];
    } else {
        if (longFormat) {
            return [self stringByMouthDayHourMinuteStyle];
        } else {
            return [ShortDateFormatter stringFromDate:self];
        }
    }
}

- (NSString *)stringByMouthDayHourMinuteStyle
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M月d日hh:mm"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *output = [formatter stringFromDate:self];
    return output;
}

- (NSString *)stringByHourMinuteStyle
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *output = [formatter stringFromDate:self];
    return output;
}

- (NSString *)stringByConvertToDateOnly
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-MM-dd"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *output = [formatter stringFromDate:self];
    return output;
}

- (NSString *)stringByConvertToUNIXTimeStamp {
    return [NSString stringWithFormat:@"%.0f", [self timeIntervalSince1970]];
}

- (NSNumber *)numberByConvertToUNIXTimeStamp {
    return [NSNumber numberWithDouble:[self timeIntervalSince1970]];
}

- (NSString *)stringByConvertToRecentFormat {
    return [self stringByConvertToRecentFormatUsingWeekday:YES];
}

- (NSString *)stringByConvertToRecentFormatUsingWeekday:(BOOL)weekday {
    NSDateComponents *todayComps = [CURRENT_CALENDAR components:DATE_COMPONENTS
                                          fromDate:[NSDate date]];
    NSDateComponents *selfComps = [CURRENT_CALENDAR components:DATE_COMPONENTS
                                         fromDate:self];
    
    NSTimeInterval minutes = [self timeIntervalSinceNow] / 60;
    if (minutes < 0) {
        NSDateComponents *yesterdayComps = [CURRENT_CALENDAR components:DATE_COMPONENTS
                                                               fromDate:[NSDate dateWithDaysBeforeNow:1]];
        NSDateComponents *theDayBeforeYesterdayComps = [CURRENT_CALENDAR components:DATE_COMPONENTS
                                                                           fromDate:[NSDate dateWithDaysBeforeNow:2]];
        
        if (todayComps.year == selfComps.year &&
            todayComps.month == selfComps.month &&
            todayComps.day == selfComps.day) {
            minutes = - minutes;
            if (minutes < 1) {
                return @"刚才";
            } if (minutes < 60) {
                return [NSString stringWithFormat:@"%.0f分钟前", minutes];
            } else {
                return [NSString stringWithFormat:@"%.0f小时前", minutes / 60];
            }
        } else if (yesterdayComps.year == selfComps.year &&
                   yesterdayComps.month == selfComps.month &&
                   yesterdayComps.day == selfComps.day) {
            return @"昨天";
        } else if (theDayBeforeYesterdayComps.year == selfComps.year &&
                   theDayBeforeYesterdayComps.month == selfComps.month &&
                   theDayBeforeYesterdayComps.day == selfComps.day) {
            return @"前天";
        } else {
            if (!weekday) {
                return [NSString stringWithFormat:@"%d天前", [self daysBeforeDate:[NSDate date]]];
            }
            NSString *weekdayStr;
            switch (selfComps.weekday) {
                case 2: weekdayStr = @"一"; break;
                case 3: weekdayStr = @"二"; break;
                case 4: weekdayStr = @"三"; break;
                case 5: weekdayStr = @"四"; break;
                case 6: weekdayStr = @"五"; break;
                case 7: weekdayStr = @"六"; break;
                case 1: weekdayStr = @"日"; break;
                default: break;
            }
            NSInteger todayWeek = todayComps.week;
            if (todayComps.weekday == 1)
                todayWeek--;
            NSInteger selfWeek = selfComps.week;
            if (selfComps.weekday == 1)
                selfWeek--;
            
            if (todayWeek == selfWeek) {
                return [NSString stringWithFormat:@"本周%@", weekdayStr];
            } else if (todayWeek - 1 == selfWeek) {
                return [NSString stringWithFormat:@"上周%@", weekdayStr];
            } else {
                return [NSString stringWithFormat:@"%d天前", [self daysBeforeDate:[NSDate date]]];
            }
        }
    } else {
        NSDateComponents *tomorrowComps = [CURRENT_CALENDAR components:DATE_COMPONENTS
                                                              fromDate:[NSDate dateWithDaysFromNow:1]];
        NSDateComponents *theDayAferTomorrowComps = [CURRENT_CALENDAR components:DATE_COMPONENTS
                                                                        fromDate:[NSDate dateWithDaysFromNow:2]];
        if (todayComps.year == selfComps.year &&
            todayComps.month == selfComps.month &&
            todayComps.day == selfComps.day) {
            if (minutes < 1) {
                return @"现在";
            } if (minutes < 60) {
                return [NSString stringWithFormat:@"%.0f分钟后", minutes];
            } else  {
                return [NSString stringWithFormat:@"%.0f小时后", minutes / 60];
            }
        } else if (tomorrowComps.year == selfComps.year &&
                   tomorrowComps.month == selfComps.month &&
                   tomorrowComps.day == selfComps.day) {
            return @"明天";
        } else if (theDayAferTomorrowComps.year == selfComps.year &&
                   theDayAferTomorrowComps.month == selfComps.month &&
                   theDayAferTomorrowComps.day == selfComps.day) {
            return @"后天";
        } else {
            if (!weekday) {
                return [NSString stringWithFormat:@"%d天后", [self daysAfterDate:[NSDate date]]];
            }
            NSString *weekdayStr;
            switch (selfComps.weekday) {
                case 2: weekdayStr = @"一"; break;
                case 3: weekdayStr = @"二"; break;
                case 4: weekdayStr = @"三"; break;
                case 5: weekdayStr = @"四"; break;
                case 6: weekdayStr = @"五"; break;
                case 7: weekdayStr = @"六"; break;
                case 1: weekdayStr = @"日"; break;
                default: break;
            }
            NSInteger todayWeek = todayComps.week;
            if (todayComps.weekday == 1)
                todayWeek--;
            NSInteger selfWeek = selfComps.week;
            if (selfComps.weekday == 1)
                selfWeek--;
            
            if (todayWeek == selfWeek) {
                return [NSString stringWithFormat:@"本周%@", weekdayStr];
            } else if (todayWeek + 1 == selfWeek) {
                return [NSString stringWithFormat:@"下周%@", weekdayStr];
            } else {
                return [NSString stringWithFormat:@"%d天后", [self daysAfterDate:[NSDate date]]];
            }
        }
    }

}

@end
