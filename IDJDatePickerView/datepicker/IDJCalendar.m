//
//  IDJCalendar.m
//
//  Created by Lihaifeng on 11-11-28, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import "IDJCalendar.h"

@implementation IDJCalendar
@synthesize yearStart, yearEnd, greCal, era, year, month, day, weekday, weekdays;

- (id)initWithYearStart:(NSUInteger)start end:(NSUInteger)end {
    self=[super init];
    if (self) {
        self.yearStart=start;
        self.yearEnd=end;
        NSCalendar *cal=[[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        [cal setTimeZone:[NSTimeZone defaultTimeZone]];
        self.greCal=cal;
        [cal release];
        self.weekdays=[NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
        
        //设置当前时间的相关字段
        NSDate 	*currentDate = [NSDate date];
        NSDateComponents *dc = nil;
        dc = [cal components:CALENDAR_UNIT_FLAGS fromDate:currentDate];
        self.era=[NSString stringWithFormat:@"%d", dc.era];
        self.year=[NSString stringWithFormat:@"%d", dc.year];
        self.month=[NSString stringWithFormat:@"%d", dc.month];
        self.day=[NSString stringWithFormat:@"%d", dc.day];
        self.weekday=[NSString stringWithFormat:@"%d", dc.weekday];
    }
    return self;
}

- (NSMutableArray *)yearsInRange {
    NSMutableArray * array=[[NSMutableArray alloc]initWithCapacity:yearEnd-yearStart+1];
    for (int i=yearStart; i<=yearEnd; i++) {
        [array addObject:[NSString stringWithFormat:@"%d", i]];
    }
    return [array autorelease];;
}

//公历的一年只有12个月
- (NSMutableArray *)monthsInYear:(NSUInteger)_year {
    NSMutableArray *array=[[NSMutableArray alloc]initWithCapacity:MONTH_COUNTS_IN_YEAR_GRE];
    for (int i=0; i<MONTH_COUNTS_IN_YEAR_GRE; i++) {
        [array addObject:[NSString stringWithFormat:@"%d", i+1]];
    }
    return [array autorelease];
}

- (NSMutableArray *)daysInMonth:(NSString *)_month year:(NSUInteger)_year {
    NSMutableArray *myDays=[[NSMutableArray alloc]initWithCapacity:DAY_COUNTS_IN_YEAR__GRE];
    NSDateComponents *dc=[[NSDateComponents alloc]init];
    dc.year=_year;
    dc.month=[_month intValue];
    dc.day=1;
    NSDate *date=[greCal dateFromComponents:dc];
    //计算date所在的月份有多少天
    NSRange range=[greCal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    for (int i=0; i<range.length; i++) {
        [myDays addObject:[NSString stringWithFormat:@"%d", i+1]];
    }
    [dc release];
    return [myDays autorelease];
}

- (void)dealloc {
    [greCal release];
    [era release];
    [year release];
    [month release];
    [day release];
    [weekday release];
    [weekdays release];
    [super dealloc];
}
@end
