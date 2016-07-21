//
//  NoteListViewController.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "NoteListViewController.h"
#import "EditViewController.h"
#import "ChooseFolderViewController.h"
#import "FileManager.h"
#import "NoteItemCell.h"
#import "Item.h"
#import "Configure.h"
#import "SortOptionsView.h"
#import "CreateNoteView.h"
@interface NoteListViewController () <UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate,UISearchBarDelegate>

@property (weak, nonatomic)  IBOutlet UITableView *noteListView;
@property (assign, nonatomic) NSInteger           sortOption;
@property (nonatomic,assign)  FileManager         *fm;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation NoteListViewController
{
    NSMutableArray *dataArray;
    NSString *searchWord;
    
    SortOptionsView *sortView;
    CreateNoteView *createView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fm = [FileManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"ItemsChangedNotification" object:nil];
    self.searchBar.placeholder = ZHLS(@"Search");
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = ZHLS(@"NavTitleMarkLite");
    [self reload];
}

- (void)reload
{
    [_fm createCloudWorkspace];
    [_fm createLocalWorkspace];
    self.sortOption = self.sortOption;
}

- (NSArray*)rightItems
{
    UIBarButtonItem *new = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];

    return @[new];
}

- (NSArray*)leftItems
{
    UIBarButtonItem *sort = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"sort_options"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    return @[sort];
}

- (void)newNote
{
    CGFloat w = self.view.bounds.size.width;
    
    if (createView.superview) {
        [self dismissView:createView];
        return;
    }
    if (sortView.superview) {
        [self dismissView:sortView];
    }
    createView = [CreateNoteView instance];
    
    if ([Configure sharedConfigure].defaultParent == nil) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[Configure sharedConfigure].defaultParent.fullPath]) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    createView.parent = [Configure sharedConfigure].defaultParent;
    __weak NoteListViewController *__self = self;
    createView.chooseFolder = ^(){
        [__self performSegueWithIdentifier:@"newNote" sender:__self];
    };
    __weak UIView *v = createView;
    createView.didCreateNote = ^(Item *note){
        [__self dismissView:v];
        [__self reload];
        
        __self.fm.currentItem = note;
        if (kDevicePhone) {
            [__self performSegueWithIdentifier:@"edit" sender:__self];
        }
    };
    createView.frame = CGRectMake(0, -100, w, 100);
    [self showView:createView];
}

- (void)showOptions
{
    CGFloat w = self.view.bounds.size.width;

    if (sortView.superview) {
        [self dismissView:sortView];
        return;
    }
    if (createView.superview) {
        [self dismissView:createView];
    }
    sortView = [[SortOptionsView alloc]initWithFrame:CGRectMake(0, -90, w, 90)];
    
    __weak NoteListViewController *__self = self;
    __weak UIView *v = sortView;

    sortView.choosedIndex = ^(NSInteger index){
        [__self dismissView:v];
        __self.sortOption = index;
    };
    [self showView:sortView];
}

- (void)dismissView:(UIView*)v
{
    UIView *control = v.superview;

    if ([v isKindOfClass:[UIControl class]]) {
        control = v;
        v = control.subviews.firstObject;
    }
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = v.frame.size.height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.frame = CGRectMake(0, 64 - h, w, h);
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        if (finished) {
            [v removeFromSuperview];
            [control removeFromSuperview];
        }
    }];
}

- (void)showView:(UIView*)v
{
    UIControl *control = [[UIControl alloc]initWithFrame:self.view.bounds];
    control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [control addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    
    control.frame = self.view.bounds;
    [self.view addSubview:control];
    [control addSubview:v];
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = v.frame.size.height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.frame = CGRectMake(0, 64, w, h);
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    } completion:^(BOOL finished) {
    }];
}

- (void)setSortOption:(NSInteger)sortOption
{
    _sortOption = sortOption;
    
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeText) {
            return YES;
        }
        return NO;
    }];
    
    Item *local = _fm.local;
    Item *cloud = _fm.cloud;

    NSArray *localArray = nil;
    NSArray *cloudArray = nil;
    NSMutableArray *arr = [NSMutableArray array];
    if (searchWord.length == 0) {
        localArray = [local.items filteredArrayUsingPredicate:pre];
        cloudArray = [cloud.items filteredArrayUsingPredicate:pre];
    }else {
        localArray = [[local searchResult:searchWord] filteredArrayUsingPredicate:pre];
        cloudArray = [[cloud searchResult:searchWord] filteredArrayUsingPredicate:pre];
    }
    [arr addObjectsFromArray:localArray];
    [arr addObjectsFromArray:cloudArray];

    dataArray = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Item *item1 = obj1;
        Item *item2 = obj2;
        if (_sortOption == 0) {
            return [item1.name compare:item2.name];
        }else if(_sortOption == 1){
            NSDate *date1 = [_fm attributeOfPath:item1.fullPath][NSFileCreationDate];
            NSDate *date2 = [_fm attributeOfPath:item2.fullPath][NSFileCreationDate];
            return [date1 compare:date2];
        }else{
            NSDate *date1 = [_fm attributeOfPath:item1.fullPath][NSFileModificationDate];
            NSDate *date2 = [_fm attributeOfPath:item2.fullPath][NSFileModificationDate];
            return [date1 compare:date2];
        }
    }].mutableCopy;
    
    if (_fm.currentItem == nil) {
        _fm.currentItem = dataArray.firstObject;
    }

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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ZHLS(@"DeleteMessage") message:nil delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"Delete"), nil];
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
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
            [_fm deleteFile:i.fullPath];
        }
    };
    [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteItemCell *cell = (NoteItemCell*)[tableView dequeueReusableCellWithIdentifier:@"noteItemCell" forIndexPath:indexPath];

    Item *item = dataArray[indexPath.row];
    cell.item = item;
    if (![cell viewWithTag:4654]) {
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(16, 84.7, self.view.bounds.size.width - 16, 0.3)];
        line.tag = 4564;
        line.backgroundColor = [UIColor colorWithRGBString:@"e6e6e6"];
        [cell addSubview:line];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *i = dataArray[indexPath.row];
    _fm.currentItem = i;
    if (kDevicePhone) {
        NSLog(@"segue");
        [self performSegueWithIdentifier:@"edit" sender:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchWord = searchText;
    self.sortOption = _sortOption;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchWord = @"";
    [searchBar resignFirstResponder];
    self.sortOption = _sortOption;
    searchBar.text = @"";
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    [searchBar setCancelButtonTitle:ZHLS(@"Cancel")];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"newNote"]) {
        
        ChooseFolderViewController *vc = [(UINavigationController*)segue.destinationViewController viewControllers].firstObject;
        vc.didChoosedFolder = ^(Item *i){
            createView.parent = i;
            [Configure sharedConfigure].defaultParent = i;
        };
    }
    NSLog(@"segue");
}

- (void)changeOrientation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat w = self.view.bounds.size.width;
        
        sortView.superview.frame = self.view.bounds;
        createView.superview.frame = self.view.bounds;
        sortView.frame = CGRectMake(0, 64, w, 90);
        createView.frame = CGRectMake(0, 64, w, 100);
    });
}

@end
