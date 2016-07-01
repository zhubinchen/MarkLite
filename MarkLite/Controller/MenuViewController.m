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

//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController
{
    NSArray *items;
    NSArray *imgNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选项";
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    if (kDevicePad) {
        items = @[@[@"iCloud 同步",@"图片云存储"],@[@"键盘辅助",@"编辑器字体",@"渲染样式"],@[@"好评鼓励",@"问题反馈"],@[@"关于"]];
        imgNames = @[@[@"Cloud",@"Quality"],@[@"Keyboard",@"Font",@"Style"],@[@"Star",@"FeedBack"],@[@"Info"]];
    }else{
        items = @[@[@"iCloud 同步",@"图片云存储"],@[@"键盘辅助",@"渲染样式"],@[@"好评鼓励",@"问题反馈"],@[@"关于"]];
        imgNames = @[@[@"Cloud",@"Quality"],@[@"Keyboard",@"Style"],@[@"Star",@"FeedBack"],@[@"Info"]];
    }
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchCloud:(UISwitch*)s{
    [Configure sharedConfigure].cloud = s.on;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuItem" forIndexPath:indexPath];
    
    cell.textLabel.text = items[indexPath.section][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imgNames[indexPath.section][indexPath.row]];
    if (indexPath.section == 0 && indexPath.row == 0) {
        UISwitch *s = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 10, 0, 0)];
        s.on = [Configure sharedConfigure].cloud;
        [s addTarget:self action:@selector(switchCloud:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:s];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        UISwitch *s = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 10, 0, 0)];
        s.on = [Configure sharedConfigure].keyboardAssist;
        [s addTarget:self action:@selector(switchKeyboard:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:s];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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
    if (indexPath.section == 0 && indexPath.row == 1) {
        UIViewController *vc = [[ImageViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 1) {
        if (kDevicePad && indexPath.row == 1) {
            [self performSegueWithIdentifier:@"font" sender:self];
        }
        if ((kDevicePhone && indexPath.row == 1) || (kDevicePad && indexPath.row == 2)) {
            
            UIViewController *vc = [[StyleViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"has_stared"];
             [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }else{
            NSString *url = @"mailto:cheng4741@gmail.com?subject=MarkLite%20Report&body=";
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        }
    }else if (indexPath.section == 3){
        UIViewController *vc = [[AboutViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
