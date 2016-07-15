//
//  ChooseFolderViewController.m
//  MarkLite
//
//  Created by zhubch on 7/5/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "ChooseFolderViewController.h"
#import "FileItemCell.h"
#import "FileManager.h"
#import "Configure.h"

@interface ChooseFolderViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *folderListView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@end

@implementation ChooseFolderViewController
{
    NSMutableArray *dataArray;
    Item *selectedFolder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.folderListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"file"];
    [self.segment setTitle:ZHLS(@"NavTitleLocalFile") forSegmentAtIndex:0];
    [self.segment setTitle:ZHLS(@"NavTitleCloudFile") forSegmentAtIndex:1];
    self.navigationItem.leftBarButtonItem.title = ZHLS(@"Cancel");
    self.navigationItem.rightBarButtonItem.title = ZHLS(@"Next");
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self loadFolder:NO];
}

- (void)loadFolder:(BOOL)icloud
{
    if (icloud) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请前往appstore下载MarkLite的正式版" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        if (!kDeviceSimulator) {
            alert.clickedButton = ^(NSInteger index){
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://appsto.re/cn/jK8Cbb.i](https://appsto.re/cn/jK8Cbb.i"]];
            };
        }
        [alert show];
    }
    Item *root = [FileManager sharedManager].local;
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeFolder) {
            return YES;
        }
        return NO;
    }];
    dataArray = [root.items filteredArrayUsingPredicate:pre].mutableCopy;
    [dataArray insertObject:root atIndex:0];
    [self.folderListView reloadData];
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItemCell *cell = (FileItemCell*)[tableView dequeueReusableCellWithIdentifier:@"file" forIndexPath:indexPath];
    Item *item = dataArray[indexPath.row];
    cell.shift = 1;
    cell.item = item;
    cell.moreBtn.hidden = YES;
    cell.checkIcon.hidden = selectedFolder != item;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedFolder = dataArray[indexPath.row];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.didChoosedFolder(selectedFolder);
    }];
}

- (IBAction)segmentChanged:(UISegmentedControl*)sender
{
    [self loadFolder:sender.selectedSegmentIndex == 1];
}

@end
