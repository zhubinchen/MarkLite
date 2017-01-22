//
//  HomeViewController.m
//  MarkLite
//
//  Created by Bingcheng on 2016/11/30.
//  Copyright © 2016年 Bingcheng. All rights reserved.
//

#import "HomeViewController.h"
#import "MenuViewController.h"
#import "SeparatorLine.h"
#import "Configure.h"
#import "Item.h"

@interface HomeViewController ()

@property (nonatomic,weak) IBOutlet UIView *storageTypeView;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *storageTypeViewTop;
@property (nonatomic,weak) IBOutlet UIButton *localButton;
@property (nonatomic,weak) IBOutlet UIButton *cloudButton;
@property (nonatomic,weak) IBOutlet UIButton *dropboxButton;

@property (assign, nonatomic) StorageType storageType;
@property (nonatomic,weak) UINavigationController *menuVc;

@end

@implementation HomeViewController
{
    UIButton *titleButton;
    UIImageView *downImgView;
    UIControl *control;
    Item *next;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(segueToSettings)];
    
    titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    titleButton.frame = CGRectMake(0, 0, 200, 30);
    titleButton.titleLabel.font = [UIFont systemFontOfSize:18];
    titleButton.tintColor = kTitleColor;
    [titleButton addTarget:self action:@selector(chooseRoot) forControlEvents:UIControlEventTouchUpInside];
    downImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"down"]];
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    [titleView addSubview:titleButton];
    [titleView addSubview:downImgView];
    self.navigationItem.titleView = titleView;
    
    NSArray *titles = @[@"NavTitleLocalFile",@"NavTitleCloudFile",@"NavTitleDropbox"];
    [self.localButton setTitle:ZHLS(titles[0]) forState:UIControlStateNormal];
    [self.cloudButton setTitle:ZHLS(titles[1]) forState:UIControlStateNormal];
    [self.dropboxButton setTitle:ZHLS(titles[2]) forState:UIControlStateNormal];
    [self.localButton setTitleColor:kPrimaryColor forState:UIControlStateNormal];
    [self.cloudButton setTitleColor:kPrimaryColor forState:UIControlStateNormal];
    [self.dropboxButton setTitleColor:kPrimaryColor forState:UIControlStateNormal];
    self.storageType = StorageTypeLocal;
}

- (void)setRecievedItem:(Item *)recievedItem
{
    if (_menuVc) {
        [_menuVc dismissViewControllerAnimated:NO completion:^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
    }else{
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    [super setRecievedItem:recievedItem];
    [self performSegueWithIdentifier:@"edit" sender:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    SeparatorLine *line = [self.storageTypeView viewWithTag:1001];
    [line removeFromSuperview];
    
    line = [[SeparatorLine alloc]initWithStart:CGPointMake(10, 44) width:self.view.bounds.size.width - 20 color:kPrimaryColor];
    line.tag = 1001;
    [self.storageTypeView addSubview:line];
}

- (void)chooseRoot
{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(M_PI);

    if (control == nil) {
        control = [[UIControl alloc]initWithFrame:self.view.bounds];
        control.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
        [control addTarget:self action:@selector(chooseRoot) forControlEvents:UIControlEventTouchDown];
        [self.view insertSubview:control belowSubview:self.storageTypeView];
        self.storageTypeViewTop.constant = 0;
    }else{
        endAngle = CGAffineTransformMakeRotation(0);
        [control removeFromSuperview];
        control = nil;
        self.storageTypeViewTop.constant = -88;
    }

    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.view layoutIfNeeded];
        downImgView.transform = endAngle;
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)setTitle:(NSString *)title
{
    [titleButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)rootButtonClick:(UIButton*)sender
{
    self.storageType = sender.tag;
    [self reload];
    [self chooseRoot];
}

- (void)setStorageType:(StorageType)storageType
{
    NSArray *roots = @[[Item localRoot],[Item cloudRoot],[Item dropboxRoot]];
    self.root = roots[storageType];
    self.title = self.root.displayName;
    CGFloat w = [self.root.displayName sizeWithFont:[UIFont systemFontOfSize:18] maxSize:CGSizeMake(200, 30)].width;
    downImgView.frame = CGRectMake(100 + w * 0.5 + 2.5, 2.5, 25, 25);
}

- (void)segueToSettings
{
    MenuViewController *vc = [[MenuViewController alloc]init];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    self.menuVc = nav;
}

@end
