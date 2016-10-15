//
//  FontViewController.m
//  MarkLite
//
//  Created by zhubch on 6/24/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "FontViewController.h"
#import "Configure.h"

@interface FontViewController ()

@end

@implementation FontViewController
{
    NSMutableDictionary *fontNames;
    NSArray *familyNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStepper *stepper = [[UIStepper alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    [stepper addTarget:self action:@selector(stepperValuedChanged:) forControlEvents:UIControlEventValueChanged];
    stepper.value = [Configure sharedConfigure].fontSize;
    stepper.minimumValue = 12;
    stepper.maximumValue = 28;
    
    self.navigationItem.titleView = stepper;

//    self.title = ZHLS(@"Font");
    self.navigationItem.rightBarButtonItem.title = ZHLS(@"Done");
    self.navigationItem.leftBarButtonItem.title = ZHLS(@"Reset");

    fontNames = [@{} mutableCopy];
    familyNames = [[UIFont familyNames] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *familyName in familyNames) {
        fontNames[familyName] = [UIFont fontNamesForFamilyName:familyName];
    }
}

- (void)stepperValuedChanged:(UIStepper*)sender
{
    [Configure sharedConfigure].fontSize = sender.value;
    [self.tableView reloadData];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)recoverDefault:(id)sender
{
    [Configure sharedConfigure].fontName = @"Hiragino Sans";
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return fontNames.allValues.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fontNames[familyNames[section]] count];
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fontCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fontCell"];
    }
    cell.textLabel.text = fontNames[familyNames[indexPath.section]][indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:fontNames[familyNames[indexPath.section]][indexPath.row] size:[Configure sharedConfigure].fontSize];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Configure sharedConfigure].fontName = fontNames[familyNames[indexPath.section]][indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
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
