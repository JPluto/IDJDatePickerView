//
//  ScrollComponent.m
//
//  Created by Lihaifeng on 11-11-25, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import "IDJScrollComponent.h"

@interface IDJScrollComponent (Private)
- (void)layoutViews:(int)idx;
- (void)layoutBefore:(int)idx;
- (void)layoutNext:(int)idx;
- (void)layoutCurrent:(int)idx;
@end

@implementation IDJScrollComponent
@synthesize views, curentIdx, idjsDelegate;

- (id) initWithFrame:(CGRect)rect withViews:(NSArray*)_views
{
	self = [super initWithFrame:rect];
	if (self != nil) {
        self.backgroundColor=[UIColor clearColor];
		self.views = _views;
		self.contentSize = CGSizeMake(rect.size.width,rect.size.height*_views.count);
		self.pagingEnabled = NO;
        self.decelerationRate=0;
        self.bounces=NO;
		self.delegate = self;
		self.showsVerticalScrollIndicator = NO;
		curentIdx = 0;
		[self layoutViews:curentIdx];
	}
	return self;
}

- (void) dealloc{
	[views release];
	[super dealloc];
}

-(void)moveSubViews:(UIScrollView *)scrollView{
    float idx = scrollView.contentOffset.y / self.frame.size.height;
    for (int i=0; i<views.count; i++) {
        if (idx==i) {
            0 == idx ? --curentIdx : ++curentIdx;
            if(curentIdx < 0)
                curentIdx = [views count] -1;
            else if(curentIdx == [views count])
                curentIdx = 0;
            [self layoutViews:curentIdx];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self moveSubViews:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [idjsDelegate stopScroll:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[self moveSubViews:scrollView];
    [idjsDelegate stopScroll:self];
}

-(void)layoutViews:(int)idx{
	self.contentOffset = CGPointMake(0, self.frame.size.height);
    NSArray *subViews=[self subviews];
    for (UIView *v in subViews) {
        [v removeFromSuperview];
    }
	[self layoutBefore:idx];
	[self layoutNext:idx];
	[self layoutCurrent:idx];
}

-(void)layoutBefore:(int)idx{
	if( 0 == idx)
		idx = [views count];
	UIView *v = [views objectAtIndex:idx-1];
	v.center = CGPointMake(v.center.x, self.frame.size.height /2);
	[self addSubview:v];
}

-(void)layoutNext:(int)idx{
	if( [views count] - 1 == idx)
		idx = - 1;
	UIView *v = [views objectAtIndex:idx + 1];
	v.center = CGPointMake(v.center.x, self.frame.size.height /2 + self.frame.size.height * 2);
	[self addSubview:v];
}

-(void)layoutCurrent:(int)idx{
	UIView *v = [views objectAtIndex:idx ];
	v.center = CGPointMake(v.center.x, self.frame.size.height /2 + self.frame.size.height);
	[self addSubview:v];
}

@end
