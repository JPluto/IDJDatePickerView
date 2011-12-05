//
//  循环滚动视图，这个类实现了UIScrollView上的内容循环滚动的效果，但要注意每一个添加在这个类中的views中的UIView长宽必须必须恰好是UIScrollView的内容区域的长宽
//  ScrollComponent.h
//
//  Created by Lihaifeng on 11-11-25, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IDJScrollComponentDelegate;

@interface IDJScrollComponent : UIScrollView<UIScrollViewDelegate> {
	NSArray *views;
	int curentIdx;
    id<IDJScrollComponentDelegate> idjsDelegate;
}
@property (retain, nonatomic) NSArray *views;
@property (assign, nonatomic) int curentIdx;
@property (assign, nonatomic) id<IDJScrollComponentDelegate> idjsDelegate;
- (id)initWithFrame:(CGRect)rect withViews:(NSArray*)_views;
@end

@protocol IDJScrollComponentDelegate <NSObject>
//通知父容器我已经停止滚动
@required - (void)stopScroll:(IDJScrollComponent *)sc;
@end

