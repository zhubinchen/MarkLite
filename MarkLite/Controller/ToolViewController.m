//
//  ToolViewController.m
//  MarkLite
//
//  Created by zhubch on 15/4/8.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "ToolViewController.h"
#import "HTTPServer.h"
#import "FileManager.h"
#import "QRCodeGenerator.h"

@interface ToolViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolPanelHeight;
@property (weak, nonatomic) IBOutlet UIView *toolView;

@end

@implementation ToolViewController
{
    HTTPServer *server;
    NSArray *toolViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    for (UIView *v in self.toolView.subviews) {
        if (v.tag == 0) {
            v.hidden = NO;
        }else {
            v.hidden = YES;
        }
    }

    [self layoutFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutFrame) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)layoutFrame
{
    float w = [UIScreen mainScreen].bounds.size.width;
    float h = [UIScreen mainScreen].bounds.size.height;
    if (kIsPhone) {
        self.toolPanelHeight.constant = 0.4*h;
    } else {
        self.toolPanelHeight.constant = w > h ? h*0.5 : h*0.5;
    }
}

- (IBAction)toolBtnClicked:(UIButton*)sender {
    for (UIView *v in self.toolView.subviews) {
        if (v.tag == sender.tag) {
            v.hidden = NO;
        }else {
            v.hidden = YES;
        }
    }
}

@end
