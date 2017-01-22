//
//  StyleViewController.m
//  MarkLite
//
//  Created by Bingcheng on 6/30/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "StyleViewController.h"
#import "Configure.h"
#import "SeparatorLine.h"

@interface StyleViewController ()<UIScrollViewDelegate>
@property (nonatomic,weak) IBOutlet UITableView *pageStyleTableview;
@property (nonatomic,weak) IBOutlet UITableView *codeStyleTableview;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@end

@implementation StyleViewController
{
    NSMutableArray *pageStyles;
    NSMutableArray *codeStyles;
    UISegmentedControl *segment;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = ZHLS(@"Style");
    
    NSString *highlightStyleDir = [documentPath() stringByAppendingPathComponent:@"StyleResource/highlight-style"];
    NSString *styleDir = [documentPath() stringByAppendingPathComponent:@"StyleResource/markdown-style"];
    
    
    codeStyles = [[NSFileManager defaultManager] subpathsAtPath:highlightStyleDir].mutableCopy;
    [codeStyles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        codeStyles[idx] = [obj stringByDeletingPathExtension];
    }];
    
    pageStyles = [[NSFileManager defaultManager] subpathsAtPath:styleDir].mutableCopy;
    [pageStyles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        pageStyles[idx] = [obj stringByDeletingPathExtension];
    }];
    
    segment = [[UISegmentedControl alloc]initWithItems:@[ZHLS(@"Page"),ZHLS(@"Code Block")]];
    segment.selectedSegmentIndex = 0;
    [segment addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segment;
}

- (void)segmentSelected:(UISegmentedControl*)sender
{
    _scrollView.contentOffset = CGPointMake(self.view.bounds.size.width * sender.selectedSegmentIndex, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    segment.selectedSegmentIndex = (int)scrollView.contentOffset.x / self.view.bounds.size.width;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _pageStyleTableview) {
        return pageStyles.count;
    }
    return codeStyles.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *styles = tableView == _pageStyleTableview ? pageStyles : codeStyles;
    NSString *selected = tableView == _pageStyleTableview ? [Configure sharedConfigure].style : [Configure sharedConfigure].highlightStyle;
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.textLabel.text = styles[indexPath.row];
    if ([styles[indexPath.row] isEqualToString:selected]) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 40, 5, 30, 30)];
        imageView.image = [UIImage imageNamed:@"check_icon_s"];
        [cell addSubview:imageView];
    }
    SeparatorLine *line = [[SeparatorLine alloc]initWithStart:CGPointMake(16, 49) width:self.view.bounds.size.width - 21 color:kPrimaryColor];
    [cell addSubview:line];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _pageStyleTableview) {
        [Configure sharedConfigure].style = pageStyles[indexPath.row];
        [_pageStyleTableview reloadData];
    }else{
        [Configure sharedConfigure].highlightStyle = codeStyles[indexPath.row];
        [_codeStyleTableview reloadData];
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
