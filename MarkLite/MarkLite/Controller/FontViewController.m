//
//  FontViewController.m
//  MarkLite
//
//  Created by Bingcheng on 6/24/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "FontViewController.h"
#import "Configure.h"

@interface FontViewController ()
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UITextView *textView;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(@"Reset") style:UIBarButtonItemStyleDone target:self action:@selector(recoverDefault)];
    
    fontNames = [@{} mutableCopy];
    familyNames = [[UIFont familyNames] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *familyName in familyNames) {
        fontNames[familyName] = [UIFont fontNamesForFamilyName:familyName];
    }
    _textView.font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:[Configure sharedConfigure].fontSize];
}

- (void)stepperValuedChanged:(UIStepper*)sender
{
    [Configure sharedConfigure].fontSize = sender.value;
    _textView.font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:[Configure sharedConfigure].fontSize];
}

- (void)recoverDefault
{
    [Configure sharedConfigure].fontName = @"Hiragino Sans";
    _textView.font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:[Configure sharedConfigure].fontSize];
    [self.navigationController popViewControllerAnimated:YES];
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
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 40, 5, 30, 30)];
        imageView.tag = 4654;
        imageView.image = [UIImage imageNamed:@"check_icon_s"];
        [cell addSubview:imageView];
    }
    cell.textLabel.text = fontNames[familyNames[indexPath.section]][indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:fontNames[familyNames[indexPath.section]][indexPath.row] size:16];
    UIView *v = [cell viewWithTag:4654];
    v.hidden = ![[Configure sharedConfigure].fontName isEqualToString:fontNames[familyNames[indexPath.section]][indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Configure sharedConfigure].fontName = fontNames[familyNames[indexPath.section]][indexPath.row];
    _textView.font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:[Configure sharedConfigure].fontSize];
    [self.tableView reloadData];
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
