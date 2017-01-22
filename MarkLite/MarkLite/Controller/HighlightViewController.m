
//
//  HighlightViewController.m
//  MarkLite
//
//  Created by zhubch on 08/01/2017.
//  Copyright © 2017 zhubch. All rights reserved.
//

#import "HighlightViewController.h"
#import "Configure.h"
#import "SeparatorLine.h"
@interface HighlightViewController ()
@property (nonatomic,weak) IBOutlet UITableView *table;

@end

@implementation HighlightViewController
{
    NSArray *styles;
    NSString *selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = ZHLS(@"Style");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    NSString *highlightStyleDir = [documentPath() stringByAppendingPathComponent:@"StyleResource/highlight-style"];

    styles = [[NSFileManager defaultManager] subpathsAtPath:highlightStyleDir];
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSString *css in styles) {
        [temp addObject:[css stringByDeletingPathExtension]];
    }
    styles = temp;
    selected = [Configure sharedConfigure].highlightStyle;
}

- (void)done
{
    [Configure sharedConfigure].highlightStyle = selected;
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected = styles[indexPath.row];
    [self.table reloadData];
}

@end
