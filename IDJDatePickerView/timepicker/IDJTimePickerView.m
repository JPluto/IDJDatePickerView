//
//  IDJTimePickerView.m
//
//  Created by Lihaifeng on 11-12-2, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import "IDJTimePickerView.h"

@implementation IDJTimePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        hours=[NSArray arrayWithObjects:@"0小时", @"1小时", @"2小时", @"3小时", nil];
        [hours retain];
        minutes=[NSArray arrayWithObjects:@"5分", @"10分", @"15分", @"30分", nil];
        [minutes retain];
        picker=[[IDJPickerView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) dataLoop:NO];
        picker.delegate=self;
        [self addSubview:picker];
    }
    return self;
}

//指定每一列的滚轮上的Cell的个数
- (NSUInteger)numberOfCellsInScroll:(NSUInteger)scroll {
    switch (scroll) {
        case 0:
            return hours.count;
            break;
        case 1:
            return minutes.count;
            break;    
        default:
            return 0;
            break;
    }
}

//指定每一列滚轮所占整体宽度的比例，以:分隔
- (NSString *)scrollWidthProportion {
    return @"1.8:1";
}

//指定有多少个Cell显示在可视区域
- (NSUInteger)numberOfCellsInVisible {
    return 4;
}

//为指定滚轮上的指定位置的Cell设置内容
- (void)viewForCell:(NSUInteger)cell inScroll:(NSUInteger)scroll reusingCell:(UITableViewCell *)tc {
    tc.textLabel.font=[UIFont systemFontOfSize:15.0];
    tc.textLabel.textAlignment=UITextAlignmentCenter;
    switch (scroll) {
        case 0:
            tc.textLabel.text=[hours objectAtIndex:cell];
            break;
        case 1:
            tc.textLabel.text=[minutes objectAtIndex:cell];
            break;
        default:
            break;
    }
}

//设置选中条的位置
- (NSUInteger)selectionPosition {
    return 2;
}

//当滚轮停止滚动的时候，通知调用者哪一列滚轮的哪一个Cell被选中
- (void)didSelectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll {
    switch (scroll) {
        case 0:
            NSLog(@"%@", [hours objectAtIndex:cell]);
            break;
        case 1:
            NSLog(@"%@", [minutes objectAtIndex:cell]);
            break;
        default:
            break;
    }
}

- (void)dealloc{
    [hours release];
    [minutes release];
    [picker release];
}

@end
