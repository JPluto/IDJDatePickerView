//
//  IDJPickerView.m
//
//  Created by Lihaifeng on 11-12-1, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import "IDJPickerView.h"
#import "IDJScrollComponent.h"

//私有方法
@interface IDJPickerView (Private)
- (void)_setBackgroundImage;
- (void)_setWheelView;
- (void)_setTableViews:(NSUInteger)scroll;
- (void)_setSelectionArea;
- (void)createPickerView;
@end

@implementation IDJPickerView
@synthesize delegate, bg, picker_wheel_left, picker_wheel_right,picker_wheel_center, picker_wheel_seperated_line, picker_selection_left, picker_selection_right, picker_selection_center;

#pragma mark -init method-
- (id)initWithFrame:(CGRect)frame dataLoop:(BOOL)_loop{
    self = [super initWithFrame:frame];
    if (self) {
        dataLoop=_loop;
    }
    return self;
}

//因为创建该视图需要委托传递的相关信息，所以createPickerView方法的调用要在委托设置之后调用
- (void)setDelegate:(id<IDJPickerViewDelegate>)_delegate{
    delegate=_delegate;
    [self createPickerView];
}

//构建视图
- (void)createPickerView {
    if (!self.bg) {
        self.bg=[UIImage imageNamed:@"date_bg.png"];
    }
    if (!self.picker_wheel_left) {
        self.picker_wheel_left=[UIImage imageNamed:@"date_wheel_left.png"];
    }
    if (!self.picker_wheel_right) {
        self.picker_wheel_right=[UIImage imageNamed:@"date_wheel_right.png"];
    }
    if (!self.picker_wheel_center) {
        self.picker_wheel_center=[UIImage imageNamed:@"date_wheel_center.png"];
    }
    if (!self.picker_wheel_seperated_line) {
        self.picker_wheel_seperated_line=[UIImage imageNamed:@"date_wheel_seperated_line.png"];
    }
    if (!self.picker_selection_left) {
        self.picker_selection_left=[UIImage imageNamed:@"date_selection_left.png"];
    }
    if (!self.picker_selection_right) {
        self.picker_selection_right=[UIImage imageNamed:@"date_selection_right.png"];
    }
    if (!self.picker_selection_center) {
        self.picker_selection_center=[UIImage imageNamed:@"date_selection_center.png"];
    }
    [self _setBackgroundImage];
    //通过每一列滚轮的宽度比例计算所占wheelCenterView宽度的百分比
    NSArray *array=[[delegate scrollWidthProportion] componentsSeparatedByString:@":"];
    CGFloat total=0.0;
    for (int i=0; i<array.count; i++) {
        total+=[[array objectAtIndex:i]floatValue];
    }
    _scrollWidthProportion=[[NSMutableArray alloc]initWithCapacity:array.count];
    for (int i=0; i<array.count; i++) {
        [_scrollWidthProportion addObject:[NSString stringWithFormat:@"%f", [[array objectAtIndex:i]floatValue]/total]];
    }
    //通过_scrollWidthProportion里的百分比的个数，就知道有多少列滚轮
    _scrolls=[[NSMutableArray alloc]initWithCapacity:_scrollWidthProportion.count];
    [self _setWheelView];
    
    _cellCountInVisible=[delegate numberOfCellsInVisible];
    _selectionPosition=[delegate selectionPosition];
    if (_selectionPosition>=_cellCountInVisible) {
        NSException *e=[NSException
                        exceptionWithName: @"IDJException"
                        reason: @"The _selectionPosition must be less than _cellCountInVisible."
                        userInfo:nil];
        @throw e;
    }
    [self _setSelectionArea];
    [self _setTableViews:INT_MAX];
}

#pragma mark -Assemble UI Elements-
//设置背景
- (void)_setBackgroundImage {
    UIImageView *bgImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bgImage.image=[self.bg resizableImageWithCapInsets:UIEdgeInsetsMake(self.bg.size.height/2, self.bg.size.width/2, self.bg.size.height/2, self.bg.size.width/2)];
    [self addSubview:bgImage];
    [bgImage release];
}

//设置滚轮的贴图
- (void)_setWheelView {
    //左侧
    UIImageView *wheelLeftView=[[UIImageView alloc]initWithFrame:CGRectMake(0+WHEEL_SPACE, 0+WHEEL_SPACE, self.picker_wheel_left.size.width, self.picker_wheel_left.size.height)];
    wheelLeftView.image=self.picker_wheel_left;
    [self addSubview:wheelLeftView];
    [wheelLeftView release];
    
    //右侧
    UIImageView *wheelRightView=[[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-WHEEL_SPACE-self.picker_wheel_right.size.width, wheelLeftView.frame.origin.y, self.picker_wheel_right.size.width, self.picker_wheel_right.size.height)];
    wheelRightView.image=self.picker_wheel_right;
    [self addSubview:wheelRightView];
    [wheelRightView release];
    
    //中间平铺
    wheelCenterView=[[UIImageView alloc]initWithFrame:CGRectMake(wheelLeftView.frame.origin.x+wheelLeftView.frame.size.width, wheelLeftView.frame.origin.y, wheelRightView.frame.origin.x-(wheelLeftView.frame.origin.x+wheelLeftView.frame.size.width), self.picker_wheel_center.size.height)];
    wheelCenterView.image=[self.picker_wheel_center resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self addSubview:wheelCenterView];
    //因为滚轮的长度为了方便计算，会按照其实际大小显示，因此会远大于父视图_wheelCenterView的高度，所以需要对子视图做裁减
    wheelCenterView.clipsToBounds=YES;
    
    //分隔线的数量比滚轮的个数少一个
    int offsetY=0;
    for (int i=1; i<_scrollWidthProportion.count; i++) {
        offsetY+=[[_scrollWidthProportion objectAtIndex:i-1]floatValue]*wheelCenterView.bounds.size.width;
        UIImageView *wheelSeperatedLineView=[[UIImageView alloc]initWithFrame:CGRectMake(wheelCenterView.frame.origin.x+offsetY+self.picker_wheel_seperated_line.size.width*(i-1), wheelCenterView.frame.origin.y, self.picker_wheel_seperated_line.size.width, self.picker_wheel_seperated_line.size.height)];
        wheelSeperatedLineView.image=self.picker_wheel_seperated_line;
        [self addSubview:wheelSeperatedLineView];
        [wheelSeperatedLineView release];
    }
}

//设置滚轮的列表容器
- (void)_setTableViews:(NSUInteger)scroll {
    if (dataLoop) {
        CGFloat x=0.0;
        int start=0;
        int counts=_scrollWidthProportion.count;
        //当scroll为INT_MAX的时候，表示第一次创建选择器的时候，其他值表示运行时改变某一列滚轮的数据
        if (scroll==INT_MAX) {
            _numberOfCellsInScroll=[[NSMutableArray alloc]initWithCapacity:_scrollWidthProportion.count];
        } else {
            start=scroll;
            counts=scroll+1;
        }
        for (int i=start; i<counts; i++) {
            int numberOfCells=[delegate numberOfCellsInScroll:i];
            if (scroll==INT_MAX) {
                //记录每一列的Cell的个数到_numberOfCellsInScroll
                [_numberOfCellsInScroll addObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            } else {
                [_numberOfCellsInScroll replaceObjectAtIndex:scroll withObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            }
            NSMutableArray *views=[[NSMutableArray alloc]initWithCapacity:3];
            //计算每一列滚轮的实际高度
            CGFloat height=wheelCenterView.frame.size.height/_cellCountInVisible*numberOfCells;
            if (height<wheelCenterView.frame.size.height) {
                NSException *e=[NSException
                                exceptionWithName: @"IDJException"
                                reason: @"The number of row must be greater and equal to the height of wheelCenterView."
                                userInfo:nil];
                @throw e;
            }
            //每个IDJScrollComponent上有3个内容重复的UITableView，但这个细节在内部隐藏，对于使用这个类的人来说，只传递一份数据。在滚轮滚动的时候，我们永远使第2个UITableView上的Cell展示在选中区域，也就是说第1个和第3个UITableView只是用来向上向下滚动的时候，不出现空白而准备的。
            for (int j=0; j<3; j++) {
                UITableView *tv=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [[_scrollWidthProportion objectAtIndex:i]floatValue]*wheelCenterView.bounds.size.width, height) style:UITableViewStylePlain];
                tv.dataSource=self;
                tv.delegate=self;
                tv.scrollEnabled=NO;//禁止滚动，因为UITableView此时只是用来作为一个数据承载的视图，滚动的事情交给它的父视图IDJScrollComponent来做
                tv.backgroundColor=[UIColor clearColor];
                tv.separatorStyle=UITableViewCellSeparatorStyleNone;
                tv.showsVerticalScrollIndicator=NO;
                [views addObject:tv];
                [tv release];
            }
            if (scroll==INT_MAX) {
                x+=(i==0?0:[[_scrollWidthProportion objectAtIndex:i-1]floatValue]*wheelCenterView.bounds.size.width);
            } else {
                for (int m=0; m<=i; m++) {
                    x+=(m==0?0:[[_scrollWidthProportion objectAtIndex:m-1]floatValue]*wheelCenterView.bounds.size.width);
                }
            }
            //每个滚轮是一个IDJScrollComponent
            IDJScrollComponent *scrollComponent=[[IDJScrollComponent alloc]initWithFrame:CGRectMake(0+x+2, 0+3, [[_scrollWidthProportion objectAtIndex:i]floatValue]*wheelCenterView.bounds.size.width, height) withViews:views];
            [views release];
            scrollComponent.idjsDelegate=self;
            [wheelCenterView addSubview:scrollComponent];
            if (scroll==INT_MAX) {
                [_scrolls addObject:scrollComponent];
            } else {
                [_scrolls replaceObjectAtIndex:scroll withObject:scrollComponent];
            }
            [scrollComponent release];
        }
    } else {
        CGFloat x=0.0;
        int start=0;
        int counts=_scrollWidthProportion.count;
        //当scroll为INT_MAX的时候，表示第一次创建选择器的时候，其他值表示运行时改变某一列滚轮的数据
        if (scroll==INT_MAX) {
            _numberOfCellsInScroll=[[NSMutableArray alloc]initWithCapacity:_scrollWidthProportion.count];
        } else {
            start=scroll;
            counts=scroll+1;
        }
        for (int i=start; i<counts; i++) {
            int numberOfCells=[delegate numberOfCellsInScroll:i];
            if (scroll==INT_MAX) {
                //记录每一列的Cell的个数到_numberOfCellsInScroll
                [_numberOfCellsInScroll addObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            } else {
                [_numberOfCellsInScroll replaceObjectAtIndex:scroll withObject:[NSString stringWithFormat:@"%d", numberOfCells]];
            }
            if (scroll==INT_MAX) {
                x+=(i==0?0:[[_scrollWidthProportion objectAtIndex:i-1]floatValue]*wheelCenterView.bounds.size.width);
            } else {
                for (int m=0; m<=i; m++) {
                    x+=(m==0?0:[[_scrollWidthProportion objectAtIndex:m-1]floatValue]*wheelCenterView.bounds.size.width);
                }
            }
            CGFloat height=wheelCenterView.frame.size.height/_cellCountInVisible*_cellCountInVisible;
            //每个滚轮是一个UITableView
            UITableView *tv=[[UITableView alloc]initWithFrame:CGRectMake(0+x+2, 0+3, [[_scrollWidthProportion objectAtIndex:i]floatValue]*wheelCenterView.bounds.size.width, height) style:UITableViewStylePlain];
            tv.dataSource=self;
            tv.delegate=self;
            tv.scrollEnabled=YES;//允许滚动，因为此时UITableView既做为数据承载的视图，又做为滚动的视图
            tv.backgroundColor=[UIColor clearColor];
            tv.separatorStyle=UITableViewCellSeparatorStyleNone;
            tv.showsVerticalScrollIndicator=NO;
            tv.bounces=NO;
            tv.decelerationRate=0;
            [wheelCenterView addSubview:tv];
            if (scroll==INT_MAX) {
                [_scrolls addObject:tv];
            } else {
                [_scrolls replaceObjectAtIndex:scroll withObject:tv];
            }
            [tv release];
        }
    }
}

//设置选中区域的图片
- (void)_setSelectionArea {
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    CGFloat selectionY=rowHeight*_selectionPosition+WHEEL_SPACE;
    //左侧
    UIImageView *selectionLeftView=[[UIImageView alloc]initWithFrame:CGRectMake(0, selectionY, self.picker_selection_left.size.width, self.picker_selection_left.size.height)];
    selectionLeftView.image=self.picker_selection_left;
    selectionLeftView.alpha=0.5;
    [self addSubview:selectionLeftView];
    [selectionLeftView release];
    
    //右侧
    UIImageView *selectionRightView=[[UIImageView alloc]initWithFrame:CGRectMake(0+self.bounds.size.width-self.picker_selection_right.size.width, selectionY, self.picker_selection_right.size.width, self.picker_selection_right.size.height)];
    selectionRightView.image=self.picker_selection_right;
    selectionRightView.alpha=0.5;
    [self addSubview:selectionRightView];
    [selectionRightView release];
    
    //中间平铺
    UIImageView *selectionCenterView=[[UIImageView alloc]initWithFrame:CGRectMake(selectionLeftView.frame.origin.x+selectionLeftView.frame.size.width, selectionY, selectionRightView.frame.origin.x-(selectionLeftView.frame.origin.x+selectionLeftView.frame.size.width), self.picker_selection_center.size.height)];
    selectionCenterView.image=[self.picker_selection_center resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    selectionCenterView.alpha=0.5;
    [self addSubview:selectionCenterView];
    [selectionCenterView release];
}

#pragma mark -UITableView-
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (dataLoop) {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if ([_scrolls objectAtIndex:i]==[tableView superview]) {
                return [[_numberOfCellsInScroll objectAtIndex:i]intValue];
            }
        }
    } else {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if ([_scrolls objectAtIndex:i]==tableView) {
                //普通滚动的时候，需要对UITableView的前后增加空的Cell，保证每一个Cell可以滚动到选中区域
                int count=[[_numberOfCellsInScroll objectAtIndex:i]intValue]+_selectionPosition+(_cellCountInVisible-(_selectionPosition+1));
                return count;
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=nil;
    if (dataLoop) {
        static NSString *CellIdentifier=@"IDJPickerCell";
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    } else {
        //普通滚动的时候，不需要重复UITableView的数据，因此取消Cell的复用机制
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (dataLoop) {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if ([_scrolls objectAtIndex:i]==[tableView superview]) {
                [delegate viewForCell:indexPath.row inScroll:i reusingCell:cell];
                break;
            }
        }
    } else {
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            if (indexPath.row>=0&&indexPath.row<_selectionPosition) {
                //普通滚动的时候，需要对UITableView的前后增加空的Cell，保证每一个Cell可以滚动到选中区域
                if ([_scrolls objectAtIndex:i]==tableView) {
                    cell.textLabel.text=@"";
                    break;
                }
            } else if (indexPath.row>=_selectionPosition&&indexPath.row<_selectionPosition+[[_numberOfCellsInScroll objectAtIndex:i]intValue]) {
                if ([_scrolls objectAtIndex:i]==tableView) {
                    //由于为了滚动的方便，前后有我们伪造的空数据，因此为了与调用这个类的类提供的索引相对应，indexPath.row需要减去_selectionPosition
                    [delegate viewForCell:indexPath.row-_selectionPosition inScroll:i reusingCell:cell];
                    break;
                }
            } else {
                //普通滚动的时候，需要对UITableView的前后增加空的Cell，保证每一个Cell可以滚动到选中区域
                if ([_scrolls objectAtIndex:i]==tableView) {
                    cell.textLabel.text=@"";
                    break;
                }
            }
        }
    }
    return [cell autorelease];
}

#pragma mark -Action Handle-
- (void)selectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll {
    UIScrollView *sc=[_scrolls objectAtIndex:scroll];
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    //在循环滚动的时候，我们始终要让每一个IDJScrollComponent上的三个重复的UITableView中的第二个上某个元素显示在选中区域，第一个、第三个的UITableView只是在用户滚动的时候，看上去始终是在循环滚动
    if (dataLoop) {
        [sc setContentOffset:CGPointMake(sc.contentOffset.x, (cell+1-(_selectionPosition+1)+[[_numberOfCellsInScroll objectAtIndex:scroll]intValue])*rowHeight) animated:YES];
    } else {
        [sc setContentOffset:CGPointMake(sc.contentOffset.x, cell*rowHeight) animated:YES];
    }
}

//处理滚动列表停止滚动的事件-循环滚动
- (void)stopScroll:(IDJScrollComponent *)sc{
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    //滚动列表，使距离中间的选择区域最近的Cell始终保持在选择区域，因为用户的滚动很可能让滚轮处于当不当正不正的位置，这里使用round()的四舍五入函数，实际就是哪个Cell在中间的区域占据的高度超过自身的高度的一半，谁就滚动到中间选中的区域
    [sc setContentOffset:CGPointMake(sc.contentOffset.x, round(sc.contentOffset.y/rowHeight)*rowHeight) animated:YES];
    NSUInteger cellCountsOffset=round(sc.contentOffset.y/rowHeight);
    int counts=[[_numberOfCellsInScroll objectAtIndex:[_scrolls indexOfObject:sc]]intValue];
    int whichCell=(cellCountsOffset+_selectionPosition)%counts;
    [delegate didSelectCell:whichCell inScroll:[_scrolls indexOfObject:sc]];
}

//处理滚动列表停止滚动的事件-普通滚动
- (void)stopScrollNoLoop:(UIScrollView *)sc{
    CGFloat rowHeight=wheelCenterView.frame.size.height/_cellCountInVisible;
    //滚动列表，使距离中间的选择区域最近的Cell始终保持在选择区域，因为用户的滚动很可能让滚轮处于当不当正不正的位置，这里使用round()的四舍五入函数，实际就是哪个Cell在中间的区域占据的高度超过自身的高度的一半，谁就滚动到中间选中的区域
    [sc setContentOffset:CGPointMake(sc.contentOffset.x, round(sc.contentOffset.y/rowHeight)*rowHeight) animated:YES];
    NSUInteger cellCountsOffset=round(sc.contentOffset.y/rowHeight);
    int whichCell=cellCountsOffset;
    [delegate didSelectCell:whichCell inScroll:[_scrolls indexOfObject:sc]];
}

//处理滚动列表停止滚动的事件-普通滚动
-(void)scrollViewDidEndDragging:(UIScrollView *)sc willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self stopScrollNoLoop:sc];
    }
}

//处理滚动列表停止滚动的事件-普通滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sc{
    [self stopScrollNoLoop:sc];
}

//将视图的触摸事件传递给列表容器，覆盖此方法的原因是wheelCenterView是一个UIImageView，它会阻断其上的子视图的触摸响应，而我们的滚轮IDJScrollComponent、UITableView以wheelCenterView为父视图，所以不重写这个方法，你会发现滚轮根本无法滚动。
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    [super hitTest:point withEvent:event];
    if ([self pointInside:point withEvent:event]) {
        //将当前的View的坐标转换为相对于self.wheelCenterView的坐标，判定哪一列的滚轮被用户点击，然后就触摸事件转发过去
        CGPoint sc_point=[self convertPoint:point toView:wheelCenterView];
        int x_less=0;
        int x_greater=0;
        for (int i=0; i<_scrollWidthProportion.count; i++) {
            x_less+=(i==0?0.0:wheelCenterView.bounds.size.width*[[_scrollWidthProportion objectAtIndex:i-1]floatValue]);
            x_greater+=wheelCenterView.bounds.size.width*[[_scrollWidthProportion objectAtIndex:i]floatValue];
            if (sc_point.x>x_less&&sc_point.x<x_greater&&sc_point.y>0&&sc_point.y<wheelCenterView.bounds.size.height) {
                return [_scrolls objectAtIndex:i];
            }
        }
        return self;
    } else {
        return nil;
    }
}

- (void)reloadScroll:(NSUInteger)scroll {
    UIScrollView *sc=[_scrolls objectAtIndex:scroll];
    //移除原来的IDJScrollComponent，创建一个新的IDJScrollComponent
    [sc removeFromSuperview];
    [self _setTableViews:scroll];
}

#pragma mark -dealloc-
- (void)dealloc{
    [_scrolls release];
    [_scrollWidthProportion release];
    [wheelCenterView release];
    [_numberOfCellsInScroll release];
    [bg release];
    [picker_wheel_left release];
    [picker_wheel_right release];
    [picker_wheel_center release];
    [picker_selection_left release];
    [picker_selection_right release];
    [picker_selection_center release];
}

@end
