//
//  CreateNoteViewController.m
//  MarkLite
//
//  Created by zhubch on 5/20/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "CreateNoteViewController.h"
#import "FileItemCell.h"
#import "FileManager.h"

@interface CreateNoteViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITableView *folderListView;
@end

@implementation CreateNoteViewController
{
    NSMutableArray *dataArray;
    Item *selecteItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.checkIcon.hidden = selecteItem != item;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selecteItem = dataArray[indexPath.row];
    [tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



@end
