//
//  SelectViewController.m
//  MarkLite
//
//  Created by zhubch on 3/30/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "SelectViewController.h"

@interface SelectViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SelectViewController
{
    UITableView *table;
    int selectedRow;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillLayoutSubviews
{
    table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:table];
    table.delegate = self;
    table.dataSource = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectOptions.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.textLabel.text = _selectOptions[indexPath.row];
    if (indexPath.row == selectedRow) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 40, 5, 30, 30)];
        imageView.image = [UIImage imageNamed:@"check"];
        [cell addSubview:imageView];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [table reloadData];
    if (self.didSelected) {
        self.didSelected(indexPath.row);
    }
    
//    [self.navigationController popViewControllerAnimated:YES];
}

@end
