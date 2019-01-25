//
//  MenuViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MenuViewController.h"
#import "Configure.h"
#import "AboutViewController.h"
#import "StyleViewController.h"
#import "ImageViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController
{
    NSArray *items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(@"Back") style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    if (kDevicePad) {
        items = @[
                    @[@"ImageResolution"],
                    @[@"AssistKeyboard",@"Font",@"Style"],
                    @[@"RateIt",@"Feedback"],
                    @[@"About"]
                ];
    }else{
        items = @[
                    @[@"ImageResolution"],
                    @[@"AssistKeyboard",@"Style"],
                    @[@"RateIt",@"Feedback"],
                    @[@"About"]
                  ];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = ZHLS(@"NavTitleOptions");
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchKeyboard:(UISwitch*)s{
    [Configure sharedConfigure].keyboardAssist = s.on;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSString *title = items[indexPath.section][indexPath.row];

    if ([title isEqualToString:@"AssistKeyboard"]) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        UISwitch *s = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 7, 0, 0)];
        s.on = [Configure sharedConfigure].keyboardAssist;
        [s addTarget:self action:@selector(switchKeyboard:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:s];
    }else{
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = ZHLS(title);

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = @{
                          @"ImageResolution":@"resolution",
                          @"AssistKeyboard":@"",
                          @"Font":@"font",
                          @"Style":@"style",
                          @"RateIt":@"rate",
                          @"Feedback":@"feedback",
                          @"About":@"about",};
    NSString *key = items[indexPath.section][indexPath.row];

    if ([dic[key] length] > 0) {
        SEL selector = NSSelectorFromString(dic[key]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, selector);
    }
}

- (void)resolution
{
    UIViewController *vc = [[ImageViewController alloc]init];
    vc.title = ZHLS(@"ImageResolution");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)font
{
    [self performSegueWithIdentifier:@"font" sender:self];
}

- (void)style
{
    UIViewController *vc = [[StyleViewController alloc]init];
    vc.title = ZHLS(@"Style");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rate
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
}

- (void)feedback
{
    NSString *url = @"mailto:cheng4741@gmail.com?subject=MarkLite%20Report&body=";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void)about
{
    UIViewController *vc = [[AboutViewController alloc]init];
    vc.title = ZHLS(@"About");
    [self.navigationController pushViewController:vc animated:YES];
}

@end
