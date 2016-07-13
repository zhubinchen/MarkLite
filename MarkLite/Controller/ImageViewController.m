//
//  ImageViewController.m
//  MarkLite
//
//  Created by zhubch on 6/27/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "ImageViewController.h"
#import "Configure.h"

@interface ImageViewController ()

@property (nonatomic,weak) IBOutlet UILabel *tipsLable;
@property (nonatomic,weak) IBOutlet UILabel *lowLable;
@property (nonatomic,weak) IBOutlet UILabel *highLable;
@property (nonatomic,weak) IBOutlet UISlider *slider;
@property (nonatomic,weak) IBOutlet UIView *view2;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.slider.value = [Configure sharedConfigure].imageResolution;
    _tipsLable.text = ZHLS(@"ImageResolutionTips");
    _lowLable.text = ZHLS(@"Low");
    _highLable.text = ZHLS(@"High");
}

- (void)viewDidLayoutSubviews
{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
    
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 69.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
}

/*
 图床
 创建笔记
 共享为PDF或Web页面
 iCloud同步
 导出到印象笔记*/
- (IBAction)compressionQualityChanged:(UISlider*)sender{
    [Configure sharedConfigure].imageResolution = sender.value;
}

@end
