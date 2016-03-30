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
    
    items = @[@[@"键盘辅助"],@[@"渲染样式"],@[@"好评鼓励",@"向我吐槽"],@[@"关于"]];
    imgNames = @[@[@"Keyboard"],@[@"Help"],@[@"Star",@"FeedBack"],@[@"Info"]];
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
//        if (indexPath.row == 0) {
//            NSArray *options = @[@"清新蓝",@"极客黑",@"卖萌粉"];
//            vc.selectOptions = options;
//            vc.title = @"选择主题";
//            vc.didSelected = ^(int index){
//                [Configure sharedConfigure].theme = options[index];
//            };
//        }else {
            vc.selectOptions = @[@"开启",@"关闭"];
            vc.title = @"键盘辅助";
            vc.didSelected = ^(int index){
                [Configure sharedConfigure].keyboardAssist = index == 0;
            };
//        }
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 1) {
        vc.selectOptions = @[@"Clearness",@"Clearness Dark",@"Github",@"Github2",@"Solarized Dark",@"Solarized Light"];
        vc.title = @"选择样式";
        vc.didSelected = ^(int index){
            
        };
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
