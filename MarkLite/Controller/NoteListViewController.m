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

@interface NoteListViewController () <UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate,UISearchBarDelegate>

@property (weak, nonatomic)  IBOutlet UITableView *noteListView;
@property (assign, nonatomic) NSInteger           sortOption;
@property (nonatomic,assign)  FileManager         *fm;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation NoteListViewController
{
    NSMutableArray *dataArray;
    UIControl *control;
    UIImageView *imgView;
    NSString *searchWord;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fm = [FileManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"ItemsChangedNotification" object:nil];
    self.searchBar.placeholder = ZHLS(@"Search");
}

- (void)viewWillAppear:(BOOL)animated
{
    [_fm createCloudWorkspace];
    [_fm createLocalWorkspace];
    self.tabBarController.title = ZHLS(@"NavTitleMarkLite");
    [self reload];
}

- (void)reload
{
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
    [self performSegueWithIdentifier:@"newNote" sender:self];
}

- (void)showOptions
{
    CGFloat w = self.view.bounds.size.width;
    if (control == nil) {
        UIView *optionsView = [[UIView alloc]initWithFrame:CGRectMake(0, -90, w, 90)];
        optionsView.backgroundColor = [UIColor whiteColor];
        optionsView.tag = 1;
        optionsView.alpha = 0.99;
        [optionsView showShadowWithColor:[UIColor grayColor] offset:CGSizeMake(0, 5)];
        
        NSArray *options = @[ZHLS(@"SortByName"),ZHLS(@"SortByCreateTime"),ZHLS(@"SortByUpdateTime")];
        for (int i = 0; i < options.count; i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, i*30, w - 20, 30)];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.tag = i;
            [btn addTarget:self action:@selector(choosedOption:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:options[i] forState:UIControlStateNormal];
            [btn setTitleColor:kTintColor forState:UIControlStateNormal];
            [optionsView addSubview:btn];
        }
        
        control = [[UIControl alloc]initWithFrame:self.view.bounds];
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [control addSubview:optionsView];
    
        [control addTarget:self action:@selector(choosedOption:) forControlEvents:UIControlEventTouchUpInside];

        imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"check"]];
        [optionsView addSubview:imgView];
    }
    imgView.frame = CGRectMake(w - 35, _sortOption*30 + 3, 24, 24);
    
    UIView *optionsView = [control viewWithTag:1];
    if (control.superview) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            optionsView.frame = CGRectMake(0, -90, w, 90);
            control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            if (finished) {
                [control removeFromSuperview];
            }
        }];
    }else {
        [self.view addSubview:control];

        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            optionsView.frame = CGRectMake(0, 0, w, 90);
            control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:^(BOOL finished) {
            //
        }];
    }
}

- (void)choosedOption:(UIButton*)optionBtn
{
    CGFloat w = self.view.bounds.size.width;

    UIView *optionsView = [control viewWithTag:1];
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        optionsView.frame = CGRectMake(0, -90, w, 90);
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        if (finished) {
            [control removeFromSuperview];
        }
    }];
    if (![optionBtn isKindOfClass:[UIButton class]]) {
        return;
    }
    self.sortOption = optionBtn.tag;
}

- (void)setSortOption:(NSInteger)sortOption
{
    imgView.frame = CGRectMake(kScreenWidth - 35, _sortOption*30 + 3, 24, 24);
    _sortOption = sortOption;
    
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeText) {
            return YES;
        }
        return NO;
    }];
    
    Item *local = _fm.local;
    Item *cloud = [Configure sharedConfigure].iCloudState > 1 ? _fm.cloud : nil;

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
    
    _fm.currentItem = dataArray.firstObject;

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
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:ZHLS(@"DeleteMessage") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:ZHLS(@"Delete") otherButtonTitles: nil];
    sheet.clickedButton = ^(NSInteger buttonIndex,UIActionSheet *alert){
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
            [_fm deleteFile:i.fullPath];
        }
    };
    [sheet showInView:self.view];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteItemCell *cell = (NoteItemCell*)[tableView dequeueReusableCellWithIdentifier:@"noteItemCell" forIndexPath:indexPath];

    Item *item = dataArray[indexPath.row];
    cell.item = item;
    if (![cell viewWithTag:4654]) {
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(16, 84, self.view.bounds.size.width - 16, 0.5)];
        line.tag = 4564;
        line.backgroundColor = [UIColor lightGrayColor];
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
            [self newNoteWithParent:i];
        };
    }
    NSLog(@"segue");

}

- (void)newNoteWithParent:(Item*)parent
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"NameAlertTitle") message:ZHLS(@"NameAlertMessage") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
        if (buttonIndex == 1) {
            [[alert textFieldAtIndex:0] resignFirstResponder];
            NSString *name = [alert textFieldAtIndex:0].text;
            name = [name stringByAppendingString:@".md"];

            NSString *path = name;
            if (!parent.root) {
                path = [parent.path stringByAppendingPathComponent:name];
            }
            Item *i = [[Item alloc]init];
            i.path = path;
            i.open = YES;
            i.cloud = parent.cloud;
            BOOL ret = [[FileManager sharedManager] createFile:i.fullPath Content:[NSData data]];
            
            if (ret == NO) {
                showToast(ZHLS(@"DuplicateError"));
                return;
            }
            
            [parent addChild:i];
            
            [self reload];
            
            _fm.currentItem = i;
            if (kDevicePhone) {
                [self performSegueWithIdentifier:@"edit" sender:self];
            }
        }
    };
    [alert show];
}

@end
