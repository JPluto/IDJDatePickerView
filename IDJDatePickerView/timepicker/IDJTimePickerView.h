//
//  时间选择器
//  IDJTimePickerView.h
//
//  本类演示了滚动条、可视区域的行数都是可以任意设置的，选择条看起来比较大，因为图片没有更换为合适高度的图片。
//
//  Created by Lihaifeng on 11-12-2, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDJPickerView.h"

@interface IDJTimePickerView : UIView <IDJPickerViewDelegate> {
    IDJPickerView *picker;
    NSArray *hours;
    NSArray *minutes;
}
@end
