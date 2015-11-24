//
//  NoteListViewController.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "NoteListViewController.h"
#import "CodeViewController.h"
#import "FileManager.h"
#import "NoteItemCell.h"
#import "Item.h"

@interface NoteListViewController () <UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UITableView *noteListView;

@end

@implementation NoteListViewController
{
    NSMutableArray *dataArray;
    FileManager *fm;
    Item *root;
    UIView *optionsView;
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
    dataArray = [[root.items filteredArrayUsingPredicate:pre] sortedArrayUsingSelector:@selector(compare:)].mutableCopy;
    [self.noteListView reloadData];
}

- (NSArray*)rightItems
{
    UIBarButtonItem *new = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newNote)];
    return @[new];
}

- (NSArray*)leftItems
{
    UIBarButtonItem *sort = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"sort_options"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    return @[sort];
}

- (void)newNote
{
    
}

- (void)showOptions
{
    if (optionsView == nil) {
        optionsView = [UIView alloc]initWithFrame:<#(CGRect)#>
    }
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
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
    {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    Item *item = dataArray[indexPath.row];
    cell.item = item;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *i = dataArray[indexPath.row];
    fm.currentItem = i;
    [self performSegueWithIdentifier:@"code" sender:self];
}

#pragma mark 3dTouch

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if ([self.presentedViewController isKindOfClass:[CodeViewController class]]) {
        return nil;
    }
    NoteItemCell *cell = (NoteItemCell*)[previewingContext sourceView];
    fm.currentItem = cell.item;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    CodeViewController *vc = [sb instantiateViewControllerWithIdentifier:@"code"];
    vc.projectVc = self;
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}


@end
