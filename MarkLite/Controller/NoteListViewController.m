//
//  NoteListViewController.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "NoteListViewController.h"
#import "EditViewController.h"
#import "FileManager.h"
#import "NoteItemCell.h"
#import "Item.h"
#import "CreateNoteView.h"

@interface NoteListViewController () <UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UITableView *noteListView;
@property (assign, nonatomic) NSInteger sortOption;
@property (nonatomic,assign)    FileManager *fm;

@end

@implementation NoteListViewController
{
    NSMutableArray *dataArray;
    Item *root;
    UIControl *control;
    UIImageView *imgView;
    CreateNoteView *view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fm = [FileManager sharedManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reload];
    _fm.currentItem = dataArray.firstObject;
}

- (void)reload
{
    root = _fm.root;
    self.sortOption = self.sortOption;
}

- (NSArray*)rightItems
{
    UIBarButtonItem *new = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newNote)];

    return @[new];
}

- (NSArray*)leftItems
{
    UIBarButtonItem *sort = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"sort_options"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
//    UIBarButtonItem *sort = [[UIBarButtonItem alloc]initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    return @[sort];
}

- (void)newNote
{
    __weak typeof(self) __self = self;
    if (view == nil) {
        view = [CreateNoteView instance];
        view.didCreateNote = ^(Item *i){
            __self.fm.currentItem = i;
            [__self performSegueWithIdentifier:@"edit" sender:__self];
        };
        view.vc = __self;
    }
    
    if (view.isShow) {
        [view remove];
    }else{
        view.root = root;
        [view showOnView:self.view];
    }
}

- (void)showOptions
{
    if (control == nil) {
        UIView *optionsView = [[UIView alloc]initWithFrame:CGRectMake(0, -120, kScreenWidth, 120)];
        optionsView.backgroundColor = [UIColor whiteColor];
        optionsView.tag = 1;
        optionsView.alpha = 0.99;
        [optionsView showShadowWithColor:[UIColor grayColor] offset:CGSizeMake(0, 5)];
        
        NSArray *options = @[@"  按名称排序",@"  按标记排序",@"  按创建时间排序",@"  按修改时间排序"];
        for (int i = 0; i < options.count; i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*30, kScreenWidth, 30)];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.tag = i;
            [btn addTarget:self action:@selector(choosedOption:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:options[i] forState:UIControlStateNormal];
            [btn setTitleColor:kThemeColor forState:UIControlStateNormal];
            [optionsView addSubview:btn];
        }
        
        control = [[UIControl alloc]initWithFrame:self.view.bounds];
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [control addSubview:optionsView];
    
        [control addTarget:self action:@selector(choosedOption:) forControlEvents:UIControlEventTouchUpInside];

        imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"check"]];
        [optionsView addSubview:imgView];
    }
    imgView.frame = CGRectMake(kScreenWidth - 35, _sortOption*30 + 3, 24, 24);
    
    UIView *optionsView = [control viewWithTag:1];
    if (control.superview) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            optionsView.frame = CGRectMake(0, -120, kScreenWidth, 120);
            control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            if (finished) {
                [control removeFromSuperview];
            }
        }];
    }else {
        [self.view addSubview:control];

        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            optionsView.frame = CGRectMake(0, 0, kScreenWidth, 120);
            control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:^(BOOL finished) {
            //
        }];
    }
}

- (void)choosedOption:(UIButton*)optionBtn
{
    UIView *optionsView = [control viewWithTag:1];
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        optionsView.frame = CGRectMake(0, -120, kScreenWidth, 120);
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
    NSArray *arr = [root.items filteredArrayUsingPredicate:pre];
    dataArray = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Item *item1 = obj1;
        Item *item2 = obj2;
        if (_sortOption == 0) {
            return [item1.name compare:item2.name];
        }else if(_sortOption == 1){
            NSNumber *tag1 = [NSNumber numberWithInteger:item1.tag];
            NSNumber *tag2 = [NSNumber numberWithInteger:item2.tag];
            return [tag1 compare:tag2];
        }else if(_sortOption == 2){
            NSDate *date1 = [_fm attributeOfItem:obj1][NSFileCreationDate];
            NSDate *date2 = [_fm attributeOfItem:obj2][NSFileCreationDate];
            return [date1 compare:date2];
        }else{
            NSDate *date1 = [_fm attributeOfItem:obj1][NSFileModificationDate];
            NSDate *date2 = [_fm attributeOfItem:obj2][NSFileModificationDate];
            return [date1 compare:date2];
        }
    }].mutableCopy;
    
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
    
    ActionSheet *sheet = [[ActionSheet alloc]initWithTitle:@"删除后不和恢复，确定要删除吗？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
    sheet.clickedButton = ^(NSInteger buttonIndex,ActionSheet *alert){
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
            [_fm deleteFile:i.path];
        }
    };
    [sheet showInView:self.view];
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
    _fm.currentItem = i;
    if (kDevicePhone) {
        [self performSegueWithIdentifier:@"edit" sender:self];
    }
}

#pragma mark 3dTouch

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if ([self.presentedViewController isKindOfClass:[EditViewController class]]) {
        return nil;
    }
    NoteItemCell *cell = (NoteItemCell*)[previewingContext sourceView];
    _fm.currentItem = cell.item;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    EditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"edit"];
    vc.projectVc = self;
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

@end
