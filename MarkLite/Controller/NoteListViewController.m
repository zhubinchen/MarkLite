//
//  NoteListViewController.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "NoteListViewController.h"
#import "EditViewController.h"
#import "ChooseFolderViewController.h"
#import "FileManager.h"
#import "NoteItemCell.h"
#import "Item.h"
#import "Configure.h"
#import "SortOptionsView.h"
#import "CreateFileView.h"

@interface NoteListViewController () <UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate,UISearchBarDelegate,CreateFileViewDelegate>

@property (weak, nonatomic)  IBOutlet UITableView *noteListView;
@property (nonatomic,assign)  FileManager         *fm;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation NoteListViewController
{
    NSMutableArray *dataArray;
    NSString *searchWord;
    
    SortOptionsView *sortView;
    CreateFileView *createView;
    BOOL needReload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fm = [FileManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"ItemsChangedNotification" object:nil];
    self.searchBar.placeholder = ZHLS(@"Search");
    
    [[Configure sharedConfigure] addObserver:self forKeyPath:@"sortOption" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedReloadNotify) name:kFileChangedNotificationName object:nil];
    needReload = YES;
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reload];
    self.tabBarController.title = ZHLS(@"NavTitleMarkLite");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self listNoteWithSortOption:[Configure sharedConfigure].sortOption];
}

- (void)recievedReloadNotify
{
    needReload = YES;
}

- (void)reload
{
    if (needReload == NO) {
        return;
    }
    needReload = NO;
    [_fm createCloudWorkspace];
    [_fm createLocalWorkspace];
    [self listNoteWithSortOption:[Configure sharedConfigure].sortOption];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_fm.currentItem.fullPath]) {
        _fm.currentItem = nil;
    }
}

- (NSArray*)rightItems
{
    UIBarButtonItem *new = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];

    return @[new];
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
    createView = [CreateFileView instance];
    
    if ([Configure sharedConfigure].defaultParent == nil) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[Configure sharedConfigure].defaultParent.fullPath]) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    createView.parent = [Configure sharedConfigure].defaultParent;
    createView.delegate = self;
    createView.frame = CGRectMake(0, -140, w, 140);
    [self showView:createView];
}

- (void)dismissView:(UIView*)v
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIView *control = v.superview;

    if ([v isKindOfClass:[UIControl class]]) {
        control = v;
        v = control.subviews.firstObject;
    }
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = v.frame.size.height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.frame = CGRectMake(0, 44 + statusBarHeight - h, w, h);
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
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIControl *control = [[UIControl alloc]initWithFrame:self.view.bounds];
    control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [control addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    
    control.frame = self.view.bounds;
    [self.view addSubview:control];
    [control addSubview:v];
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = v.frame.size.height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.frame = CGRectMake(0, 44 + statusBarHeight, w, h);
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    } completion:^(BOOL finished) {
    }];
}

- (void)listNoteWithSortOption:(NSInteger)sortOption
{
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
    
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.view);
    dispatch_async(dispatch_queue_create("loading", DISPATCH_QUEUE_CONCURRENT), ^{

        NSArray *sortedArr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Item *item1 = obj1;
            Item *item2 = obj2;
            NSDate *date1 = [_fm attributeOfPath:item1.fullPath][NSFileModificationDate];
            NSDate *date2 = [_fm attributeOfPath:item2.fullPath][NSFileModificationDate];
            return [date2 compare:date1];
        }];

        NSDictionary *last = nil;
        dataArray = [NSMutableArray array];
        for (Item *i in sortedArr) {
            NSDate *date = [_fm attributeOfPath:i.fullPath][NSFileModificationDate];
            if (last == nil || ![last[@"date"] isEqualToString:date.date]) {
                last = @{@"date":date.date,@"items":[@[] mutableCopy]};
                [dataArray addObject:last];
            }
            [last[@"items"] addObject:i];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            stopLoadingAnimationOnParent(self.view);
            if (_fm.currentItem == nil) {
                _fm.currentItem = [dataArray.firstObject[@"items"] firstObject];
            }
            
            [self.noteListView reloadData];
        });
    });
}

#pragma mark CreatFileViewDelegate

- (void)didCancel:(CreateFileView *)view
{
    [self dismissView:view];
}

- (void)createFileView:(CreateFileView *)view didCreateItem:(Item *)item
{
    [self dismissView:view];
    [self reload];
    
    if (item.type == FileTypeFolder) {
        return;
    }
    _fm.currentItem = item;
    if (kDevicePhone) {
        [self performSegueWithIdentifier:@"edit" sender:self];
    }

}

- (void)shouldChooseParent:(CreateFileView *)view
{
    [self performSegueWithIdentifier:@"chooseFolder" sender:self];
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArray[section][@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteItemCell *cell = (NoteItemCell*)[tableView dequeueReusableCellWithIdentifier:@"noteItemCell" forIndexPath:indexPath];

    Item *item = dataArray[indexPath.section][@"items"][indexPath.row];
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
    Item *i = dataArray[indexPath.section][@"items"][indexPath.row];
    _fm.currentItem = i;
    if (kDevicePhone) {
        NSLog(@"segue");
        [self performSegueWithIdentifier:@"edit" sender:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return dataArray[section][@"date"];
}

#pragma mark SearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchWord = searchText;
    [self listNoteWithSortOption:[Configure sharedConfigure].sortOption];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchWord = @"";
    [searchBar resignFirstResponder];
    [self listNoteWithSortOption:[Configure sharedConfigure].sortOption];
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

#pragma mark other
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"chooseFolder"]) {
        ChooseFolderViewController *vc = nil;
        if (kDevicePad) {
            vc = segue.destinationViewController;
        }else{
            vc = [(UINavigationController*)segue.destinationViewController viewControllers].firstObject;
        }
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
