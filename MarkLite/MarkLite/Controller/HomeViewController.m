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

@property (nonatomic,weak) UINavigationController *menuVc;

@end

@implementation HomeViewController
{
    Item *next;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(segueToSettings)];
    
    self.title = @"MarkLite";
    self.root = [Item localRoot];
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

- (void)segueToSettings
{
    MenuViewController *vc = [[MenuViewController alloc]init];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    self.menuVc = nav;
}

@end
