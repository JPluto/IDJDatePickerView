//
//  日期选择器的视图类
//  IDJDatePickerView.h
//
//  Created by Lihaifeng on 11-11-22, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDJChineseCalendar.h"
#import "IDJPickerView.h"
#define YEAR_START 1970//滚轮显示的起始年份
#define YEAR_END 2049//滚轮显示的结束年份

@protocol IDJDatePickerViewDelegate;

//日历显示的类型
enum calendarType {
    Gregorian1=1,
    Chinese1
};

@interface IDJDatePickerView : UIView<IDJPickerViewDelegate>{
    int type;
    NSMutableArray *years;//第一列的数据容器
    NSMutableArray *months;//第二列的数据容器
    NSMutableArray *days;//第三列的数据容器
    IDJCalendar *cal;//日期类
    IDJPickerView *picker;
    id<IDJDatePickerViewDelegate> delegate;
}
@property (nonatomic, assign) id<IDJDatePickerViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame type:(int)_type;
@end

@protocol IDJDatePickerViewDelegate <NSObject>
//通知使用这个控件的类，用户选取的日期
- (void)notifyNewCalendar:(IDJCalendar *)cal;
@end
