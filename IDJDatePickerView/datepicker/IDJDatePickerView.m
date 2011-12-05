//
//  DJDatePickerView.m
//
//  Created by Lihaifeng on 11-11-22, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import "IDJDatePickerView.h"
#import "IDJCalendarUtil.h"

@interface IDJDatePickerView (Private)
- (void)_setYears;
- (void)_setMonthsInYear:(NSUInteger)_year;
- (void)_setDaysInMonth:(NSString *)_month year:(NSUInteger)_year;
- (void)changeMonths;
- (void)changeDays;
@end

@implementation IDJDatePickerView
@synthesize delegate;

#pragma mark -init method-
- (id)initWithFrame:(CGRect)frame type:(int)_type
{
    self = [super initWithFrame:frame];
    if (self) {
        type=_type;
        if (type==Gregorian1) {
            cal=[[IDJCalendar alloc]initWithYearStart:YEAR_START end:YEAR_END];
        } else {
            cal=[[IDJChineseCalendar alloc]initWithYearStart:YEAR_START end:YEAR_END];
        }
        self.backgroundColor=[UIColor clearColor];
                
        [self _setYears];
        [self _setMonthsInYear:[cal.year intValue]];
        [self _setDaysInMonth:cal.month year:[cal.year intValue]];
        
        picker=[[IDJPickerView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) dataLoop:YES];
        picker.delegate=self;
        [self addSubview:picker];
        //程序启动后，我们需要让三个滚轮显示为当前的日期
        if (type==Gregorian1) {
            [picker selectCell:[years indexOfObject:cal.year] inScroll:0];
            [picker selectCell:[months indexOfObject:cal.month] inScroll:1];
            [picker selectCell:[days indexOfObject:cal.day] inScroll:2];
        } else if (type==Chinese1) {
            [picker selectCell:[years indexOfObject:[NSString stringWithFormat:@"%@-%@-%@", cal.era, ((IDJChineseCalendar *)cal).jiazi, cal.year]] inScroll:0];
            [picker selectCell:[months indexOfObject:cal.month] inScroll:1];
            [picker selectCell:[days indexOfObject:cal.day] inScroll:2];
        }
        [delegate notifyNewCalendar:cal];
    }
    return self;
}

#pragma mark -The function callback of IDJPickerView-
//指定每一列的滚轮上的Cell的个数
- (NSUInteger)numberOfCellsInScroll:(NSUInteger)scroll {
    switch (scroll) {
        case 0:
            return years.count;
            break;
        case 1:
            return months.count;
            break;
        case 2:
            return days.count;
            break;
        default:
            return 0;
            break;
    }
}

//指定每一列滚轮所占整体宽度的比例，以:分隔
- (NSString *)scrollWidthProportion {
    if (type==Gregorian1) {
        return @"1:1:2";
    } else if (type==Chinese1) {
        return @"2:1:1";
    } else {
        return nil; 
    }
}

//指定有多少个Cell显示在可视区域
- (NSUInteger)numberOfCellsInVisible {
    return 3;
}

//为指定滚轮上的指定位置的Cell设置内容
- (void)viewForCell:(NSUInteger)cell inScroll:(NSUInteger)scroll reusingCell:(UITableViewCell *)tc {
    tc.textLabel.textAlignment=UITextAlignmentCenter;
    tc.selectionStyle=UITableViewCellSelectionStyleNone;
    [tc.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    switch (scroll) {
        case 0:{
            NSString *str=[years objectAtIndex:cell];
            if (type==Chinese1) {
                NSArray *array=[str componentsSeparatedByString:@"-"];
                str=[NSString stringWithFormat:@"%@/%@", [((IDJChineseCalendar *)cal).chineseYears objectAtIndex:[[array objectAtIndex:1]intValue]-1], [array objectAtIndex:2]];
            }
            tc.textLabel.text=[NSString stringWithFormat:@"%@", str];
            break;
        }
        case 1:{
            NSString *str=[NSString stringWithFormat:@"%@", [months objectAtIndex:cell]];
            if (type==Chinese1) {
                NSArray *array=[str componentsSeparatedByString:@"-"];
                if ([[array objectAtIndex:0]isEqualToString:@"a"]) {
                    tc.textLabel.text=[((IDJChineseCalendar *)cal).chineseMonths objectAtIndex:[[array objectAtIndex:1]intValue]-1];
                } else {
                    tc.textLabel.text=[NSString stringWithFormat:@"%@%@", @"闰", [((IDJChineseCalendar *)cal).chineseMonths objectAtIndex:[[array objectAtIndex:1]intValue]-1]];
                }
            } else {
                tc.textLabel.text=[NSString stringWithFormat:@"%@%@", str, @"月"];
            }
            break;
        }
        case 2:{
            if (type==Gregorian1) {
                int day=[[days objectAtIndex:cell]intValue];
                int weekday=[IDJCalendarUtil weekDayWithSolarYear:[cal.year intValue] month:cal.month day:day];
                tc.textLabel.text=[NSString stringWithFormat:@"%d      %@", day, [cal.weekdays objectAtIndex:weekday]];
            } else {
                NSString *jieqi=[[IDJCalendarUtil jieqiWithYear:[cal.year intValue]]objectForKey:[NSString stringWithFormat:@"%@-%d", cal.month, [[days objectAtIndex:cell]intValue]]];
                if (!jieqi) {
                    tc.textLabel.text=[NSString stringWithFormat:@"%@", [((IDJChineseCalendar *)cal).chineseDays objectAtIndex:[[days objectAtIndex:cell]intValue]-1]];
                } else {
                    //NSLog(@"%@-%d-%@", cal.month, [[days objectAtIndex:cell]intValue], jieqi);
                    tc.textLabel.text=[NSString stringWithFormat:@"%@", jieqi];
                }
            }
            break;
        }
        default:
            break;
    }
}

//设置选中条的位置
- (NSUInteger)selectionPosition {
    return 1;
}

//当滚轮停止滚动的时候，通知调用者哪一列滚轮的哪一个Cell被选中
- (void)didSelectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll {
    switch (scroll) {
        case 0:{
            NSString *str=[years objectAtIndex:cell];
            if (type==Chinese1) {
                NSArray *array=[str componentsSeparatedByString:@"-"];
                str=[array objectAtIndex:2];
                NSString *pYear=[cal.year copy];
                cal.era=[array objectAtIndex:0];
                ((IDJChineseCalendar *)cal).jiazi=[array objectAtIndex:1];
                cal.year=str;
                //因为用户可能从2011年滚动，最后放手的时候，滚回了2011年，所以需要判断与上一次选中的年份是否不同，再联动月份的滚轮
                if (![pYear isEqualToString:cal.year]) {
                    [self changeMonths];
                }
            } else {
                cal.year=str;
                //因为公历的每年都是12个月，所以当年份变化的时候，只需要后面的天数联动
                [self changeDays];
            }
            break;
        }
        case 1:{
            NSString *pMonth=[cal.month copy];
            NSString *str=[months objectAtIndex:cell];
            cal.month=str;
            if (![pMonth isEqualToString:cal.month]) {
                //联动天数的滚轮
                [self changeDays];
            }
            break;
        }
        case 2:{
            cal.day=[days objectAtIndex:cell];
            break;
        }
        default:
            break;
    }
    
    if (type==Gregorian1) {
        cal.weekday=[NSString stringWithFormat:@"%d", [IDJCalendarUtil weekDayWithSolarYear:[cal.year intValue] month:cal.month day:[cal.day intValue]]];
    } else {
        cal.weekday=[NSString stringWithFormat:@"%d", [IDJCalendarUtil weekDayWithChineseYear:[cal.year intValue] month:cal.month day:[cal.day intValue]]];
        ((IDJChineseCalendar *)cal).animal=[IDJCalendarUtil animalWithJiazi:[((IDJChineseCalendar *)cal).jiazi intValue]];
    }
    [delegate notifyNewCalendar:cal];
}

#pragma mark -Calendar Data Handle-
//动态改变农历月份列表，因为公历的月份只有12个月，不需要跟随年份滚轮联动
- (void)changeMonths{
    if (type==Chinese1) {
        [self _setMonthsInYear:[cal.year intValue]];
        [picker reloadScroll:1];
        int cell=[months indexOfObject:cal.month];
        if (cell==NSNotFound) {
            cell=0;
            cal.month=[months objectAtIndex:0];
        }
        [picker selectCell:cell inScroll:1];
        //月份改变之后，天数进行联动
        [self changeDays];
    }
}

//动态改变日期列表
- (void)changeDays{
    [self _setDaysInMonth:cal.month year:[cal.year intValue]];
    [picker reloadScroll:2];
    int cell=[days indexOfObject:cal.day];
    //假如用户上次选择的是1月31日，当月份变为2月的时候，第三列的滚轮不可能再选中31日，我们设置默认的值为第一个。
    if (cell==NSNotFound) {
        cell=0;
        cal.day=[days objectAtIndex:0];
    }
    [picker selectCell:cell inScroll:2];
}

#pragma mark -Fill init Data-
//填充年份
- (void)_setYears {
    [years release];
    years=[[cal yearsInRange]retain];
}

//填充月份
- (void)_setMonthsInYear:(NSUInteger)_year {
    [months release];
    months=[[cal monthsInYear:_year]retain];
}

//填充天数
- (void)_setDaysInMonth:(NSString *)_month year:(NSUInteger)_year {
    [days release];
    days=[[cal daysInMonth:_month year:_year]retain];
}

#pragma mark -dealloc-
- (void)dealloc{
    [years release];
    [months release];
    [days release];
    [cal release];
    [picker release];
    [super dealloc];
}

@end
