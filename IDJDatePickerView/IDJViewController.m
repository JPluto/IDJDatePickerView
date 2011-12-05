//
//  IDJViewController.m
//  DJUIDatePickerView
//
//  Created by Lihaifeng on 11-11-22, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import "IDJViewController.h"
#import "IDJTimePickerView.h"

@implementation IDJViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    //公历日期选择器
    IDJDatePickerView *djdateGregorianView=[[IDJDatePickerView alloc]initWithFrame:CGRectMake(10, 10, 300, 200) type:Gregorian1];
    [self.view addSubview:djdateGregorianView];
    djdateGregorianView.delegate=self;
    [djdateGregorianView release];
    
    //农历日期选择器
    IDJDatePickerView *djdateChineseView=[[IDJDatePickerView alloc]initWithFrame:CGRectMake(10, 10+200+10, 300, 200) type:Chinese1];
    [self.view addSubview:djdateChineseView];
    djdateChineseView.delegate=self;
    [djdateChineseView release];
    
//    //时间选择器
//    IDJTimePickerView *timePickerView=[[IDJTimePickerView alloc]initWithFrame:CGRectMake(10, 10, 300, 200)];
//    [self.view addSubview:timePickerView];
//    [timePickerView release];
    
}

//接收日期选择器选项变化的通知
- (void)notifyNewCalendar:(IDJCalendar *)cal {
    if ([cal isMemberOfClass:[IDJCalendar class]]) {
        NSLog(@"%@:era=%@, year=%@, month=%@, day=%@, weekday=%@", cal, cal.era, cal.year, cal.month, cal.day, cal.weekday);
    } else if ([cal isMemberOfClass:[IDJChineseCalendar class]]) {
        IDJChineseCalendar *_cal=(IDJChineseCalendar *)cal;
        NSLog(@"%@:era=%@, year=%@, month=%@, day=%@, weekday=%@, animal=%@", cal, cal.era, cal.year, cal.month, cal.day, cal.weekday, _cal.animal);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
