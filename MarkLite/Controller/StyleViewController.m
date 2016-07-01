//
//  StyleViewController.m
//  MarkLite
//
//  Created by zhubch on 6/30/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "StyleViewController.h"
#import "Configure.h"

@interface StyleViewController ()
@property (nonatomic,weak) IBOutlet UITableView *table;
@end

@implementation StyleViewController
{
    NSArray *styles;
    NSInteger selectedRow;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"渲染样式";
    styles =  @[@"Clearness",@"Clearness Dark",@"GitHub",@"GitHub2",@"Solarized Dark",@"Solarized Light"];
    for (int i = 0; i < styles.count; i++) {
        if ([[Configure sharedConfigure].style isEqualToString:styles[i]]) {
            selectedRow = i;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return styles.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.textLabel.text = styles[indexPath.row];
    if (indexPath.row == selectedRow) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 40, 5, 30, 30)];
        imageView.image = [UIImage imageNamed:@"check"];
        [cell addSubview:imageView];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [Configure sharedConfigure].style = styles[selectedRow];
    [self.table reloadData];
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
