//
//  NoteListViewController.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "NoteListViewController.h"
#import "FileManager.h"
#import "NoteItemCell.h"
#import "Item.h"

@interface NoteListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *noteListView;

@end

@implementation NoteListViewController
{
    NSMutableArray *dataArray;
    FileManager *fm;
    Item *root;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    fm = [FileManager sharedManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    root = fm.root;
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeText) {
            return YES;
        }
        return NO;
    }];
    dataArray = [root.items filteredArrayUsingPredicate:pre].mutableCopy;
    [self.noteListView reloadData];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *i = dataArray[indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定要删除该文件？" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
        if (buttonIndex == 0) {
            [i removeFromParent];
            NSArray *children = [i itemsCanReach];
            [dataArray removeObjectsInArray:children];
            [dataArray removeObject:i];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = 0; i < children.count +1; i++) {
                NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row+i inSection:0];
                [indexPaths addObject:index];
            }
            
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [fm deleteFile:i.path];
        }
        [alert releaseBlock];
    };
    [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteItemCell *cell = (NoteItemCell*)[tableView dequeueReusableCellWithIdentifier:@"noteItemCell" forIndexPath:indexPath];
//    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
//    {
//        [self registerForPreviewingWithDelegate:self sourceView:cell];
//    }
    Item *item = dataArray[indexPath.row];
    cell.item = item;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *i = dataArray[indexPath.row];
    fm.currentItem = i;
    [self performSegueWithIdentifier:@"code" sender:self];
}

@end
