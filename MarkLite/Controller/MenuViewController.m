//
//  MenuViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MenuViewController.h"
#import "SelectViewController.h"
#import "Configure.h"
#import "AboutViewController.h"

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
        items = @[@[@"键盘辅助",@"编辑器字体"],@[@"渲染样式"],@[@"好评鼓励",@"问题反馈"],@[@"关于"]];
        imgNames = @[@[@"Keyboard",@"Font"],@[@"Help"],@[@"Star",@"FeedBack"],@[@"Info"]];
    }else{
        items = @[@[@"键盘辅助"],@[@"渲染样式"],@[@"好评鼓励",@"问题反馈"],@[@"关于"]];
        imgNames = @[@[@"Keyboard"],@[@"Help"],@[@"Star",@"FeedBack"],@[@"Info"]];
    }

}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kDevicePhone ? 20 :25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectViewController *vc = [[SelectViewController alloc]init];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            vc.selectOptions = @[@"开启",@"关闭"];
            vc.title = @"键盘辅助";
            vc.defaultSelect = [Configure sharedConfigure].keyboardAssist ? 0 : 1;
            vc.didSelected = ^(int index){
                [Configure sharedConfigure].keyboardAssist = index == 0;
            };
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [self performSegueWithIdentifier:@"font" sender:self];
        }
    }else if (indexPath.section == 1) {
        NSArray *styles =  @[@"Clearness",@"Clearness Dark",@"GitHub",@"GitHub2",@"Solarized Dark",@"Solarized Light"];
        vc.selectOptions = styles;
        vc.title = @"选择样式";
        
        for (int i = 0; i < styles.count; i++) {
            if ([[Configure sharedConfigure].style isEqualToString:styles[i]]) {
                vc.defaultSelect = i;
            }
        }
        vc.didSelected = ^(int index){
            [Configure sharedConfigure].style = styles[index];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
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
