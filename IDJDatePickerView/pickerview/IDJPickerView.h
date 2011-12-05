//
//  选择器的视图类
//  IDJPickerView.h
//
//  1.本类默认使用images目录下的图片创建皮肤，设置本类的frame的高度公式为 date_selection_*.png的高度+WHEEL_SPACE*2，本程序自带的date_selection_*.png的高度为177，所以选择器的高度应该为197，当然凑整200也是可以的，因为多3个像素不会影响显示效果的。本类的宽度会自适应的。如果你想换皮肤，要注意新图片的高度和你想给选择器设置的高度要满足上面的公式。选中区域的图片date_selection_*.png的高度也需要根据你的每一行的高度进行调整。
//  2.本类实现了普通滚动、循环滚动。普通滚动的时候，每一列滚轮都是一个UITableView。循环滚动的时候，每一列都是一个IDJScrollComponent，每个IDScrollComponent上面有三个重复的UITableView。由于UITableView和我自定义的IDJScrollComponent的弗雷都是UIScrollView，所以两种滚动的实现方式共用了一部分代码。这里要注意一个限制，就是循环滚动的时候，每一列的总行数应该不小于用户可以看到的行数，例如：你的可视区域要显示3行数据，但是你的数据只有一行或者两行，也就是填不满可视区域，此时你会收到异常。
//
//  Created by Lihaifeng on 11-12-1, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDJScrollComponent.h"
#define WHEEL_SPACE 10//滚轮区域与背景图的上边缘的垂直距离、左边缘的水平距离

@protocol IDJPickerViewDelegate;

@interface IDJPickerView : UIView <UITableViewDataSource, UITableViewDelegate, IDJScrollComponentDelegate> {
    NSMutableArray *_scrolls;//存放滚轮的容器，循环滚动的时候存放IDJScrollComponent，普通滚动的时候存放UITableView
    NSMutableArray *_scrollWidthProportion;//存放每一列滚轮所占的整体宽度的百分比，因此它也决定了有多少个滚轮
    NSUInteger _cellCountInVisible;//可视区域的Cell的个数，也就是展示多少行给用户看，因此它决定了每个Cell的高度
    NSUInteger _selectionPosition;//选中条的位置，它应该小于显示在可视区域的Cell的数量
    UIImageView *wheelCenterView;//滚轮区域的父视图
    NSMutableArray *_numberOfCellsInScroll;//每一列滚轮上的Cell的个数
    BOOL dataLoop;//数据是否循环显示
    id<IDJPickerViewDelegate> delegate;
    UIImage *bg;//背景图片，可以被程序拉伸
    UIImage *picker_wheel_left;//滚轮的左端图片
    UIImage *picker_wheel_right;//滚轮的右端图片
    UIImage *picker_wheel_center;//滚轮的中间图片，可以被程序横向拉伸
    UIImage *picker_wheel_seperated_line;//滚轮的分割线
    UIImage *picker_selection_left;//选择条的左端图片
    UIImage *picker_selection_right;//选择条的右端图片
    UIImage *picker_selection_center;//选择条的中间图片，可以被程序横向拉伸
}
@property (nonatomic, assign) id<IDJPickerViewDelegate> delegate;
@property (nonatomic, retain) UIImage *bg;
@property (nonatomic, retain) UIImage *picker_wheel_left;
@property (nonatomic, retain) UIImage *picker_wheel_right;
@property (nonatomic, retain) UIImage *picker_wheel_center;
@property (nonatomic, retain) UIImage *picker_wheel_seperated_line;
@property (nonatomic, retain) UIImage *picker_selection_left;
@property (nonatomic, retain) UIImage *picker_selection_right;
@property (nonatomic, retain) UIImage *picker_selection_center;
- (id)initWithFrame:(CGRect)frame dataLoop:(BOOL)_loop;
//让位置为scroll的滚轮上的位置为cell的内容成为选中区域
- (void)selectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll;
//重新加载某一列滚轮的数据
- (void)reloadScroll:(NSUInteger)scroll;
@end

@protocol IDJPickerViewDelegate<NSObject>
@required
//指定每一列的滚轮上的Cell的个数
- (NSUInteger)numberOfCellsInScroll:(NSUInteger)scroll;
//指定每一列滚轮所占整体宽度的比例，以:分隔
- (NSString *)scrollWidthProportion;
//指定有多少个Cell显示在可视区域
- (NSUInteger)numberOfCellsInVisible;
//设置选中条的位置
- (NSUInteger)selectionPosition;
//为指定滚轮上的指定位置的Cell设置内容
- (void)viewForCell:(NSUInteger)cell inScroll:(NSUInteger)scroll reusingCell:(UITableViewCell *)tc;
@optional
//当滚轮停止滚动的时候，通知调用者哪一列滚轮的哪一个Cell被选中
- (void)didSelectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll;
@end
