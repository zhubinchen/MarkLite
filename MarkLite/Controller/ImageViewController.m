//
//  ImageViewController.m
//  MarkLite
//
//  Created by zhubch on 6/27/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "ImageViewController.h"
#import "Configure.h"

#define  kProductImageServerPro @"com.zhubch.MarkLite.imagerServerPro"

@interface ImageViewController ()

@property (nonatomic,weak) IBOutlet UIButton *purchaseBtn;
@property (nonatomic,weak) IBOutlet UISlider *slider;
@property (nonatomic,weak) IBOutlet UIView *view1;
@property (nonatomic,weak) IBOutlet UIView *view2;
@property (nonatomic,weak) IBOutlet UIView *view3;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"图片云存储";
    self.slider.value = [Configure sharedConfigure].compressionQuality;
    
    if ([Configure sharedConfigure].imageServer) {
        _purchaseBtn.enabled = NO;
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
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view3 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view1 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 89.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view3 addSubview:line];
}

- (IBAction)purchaseFunc:(id)sender {
    
    if (![Configure sharedConfigure].hasStared) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"一小时内最多上传10张" message:@"这个图床api是我在网上找的，有上传次数限制，无限制的要收费。你要是有免费好用的api可以告诉我！" delegate:nil cancelButtonTitle:@"先给个好评" otherButtonTitles:@"现在开通", nil];
        alert.clickedButton = ^(NSInteger index,UIAlertView *alert){
            if (index == 0){
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            }
            [Configure sharedConfigure].imageServer = YES;
            
            _purchaseBtn.enabled = NO;
            [_purchaseBtn setTitle:@"已开通" forState:UIControlStateNormal];
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
