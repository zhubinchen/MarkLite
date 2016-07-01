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

@property (nonatomic,weak) IBOutlet UIButton *purchaseBtn;
@property (nonatomic,weak) IBOutlet UISlider *slider;
@property (nonatomic,weak) IBOutlet UIView *view1;
@property (nonatomic,weak) IBOutlet UIView *view2;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"图片云存储";
    self.slider.value = [Configure sharedConfigure].compressionQuality;
    
    if ([Configure sharedConfigure].imageServer) {
        _purchaseBtn.enabled = YES;
        [_purchaseBtn setTitle:@"已开通" forState:UIControlStateNormal];
    }
}

- (void)viewDidLayoutSubviews
{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view1 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view1 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 89.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
}

- (IBAction)purchaseFunc:(id)sender {
    
    if (![Configure sharedConfigure].hasStared) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开通后即可将本地图片上传到云服务器，让你的文档在任何地方都能加载图片" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"好评开通", nil];
        alert.clickedButton = ^(NSInteger index,UIAlertView *alert){
            if (index == 1){
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            }
            [Configure sharedConfigure].imageServer = YES;
        };
        [alert show];
    }
}

/*
 图床
 创建笔记
 共享为PDF或Web页面
 iCloud同步
 导出到印象笔记*/


- (IBAction)compressionQualityChanged:(UISlider*)sender{
    [Configure sharedConfigure].compressionQuality = sender.value;
}

@end
