//
//  MainViewController.m
//  MarkLite
//
//  Created by Bingcheng on 11/23/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "MainViewController.h"
#import "ItemTableViewCell.h"
#import "Configure.h"
#import "Item.h"
#import "SeparatorLine.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *toolBarBottom;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *createViewTop;
@property (nonatomic,weak) IBOutlet UITableView *itemTableView;
@property (nonatomic,weak) IBOutlet UITextField *titleTextField;
@property (nonatomic,weak) IBOutlet UIView *toolBar;
@property (nonatomic,weak) IBOutlet UIView *createView;
@property (nonatomic,weak) IBOutlet UIButton *creatNoteButton;
@property (nonatomic,weak) IBOutlet UIButton *createFolderButton;
@property (nonatomic,weak) IBOutlet UILabel *emptyTipLabel;;

@end

@implementation MainViewController
{
    UIPopoverPresentationController *popVc;
    
    NSMutableArray *dataArray;
    Item *next;
    BOOL editing;
    UIControl *control;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.root) {
        self.title = self.root.displayName;
    }else{
        self.title = @"Documents";
        self.titleTextField.enabled = NO;
    }
    self.titleTextField.textColor = kTitleColor;
    
    if (kDevicePad) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRename) name:@"ItemNameChaned" object:nil];
    }
    self.emptyTipLabel.text = ZHLS(@"EmptyTip");
}

- (void)didRename
{
    [self.itemTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reload];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    SeparatorLine *line = [self.createFolderButton viewWithTag:1001];
    [line removeFromSuperview];
    line = [[SeparatorLine alloc]initWithStart:CGPointMake(10, 0) width:self.view.bounds.size.width - 20 color:kPrimaryColor];
    line.tag = 1001;
    [self.createFolderButton addSubview:line];
    
    [self.creatNoteButton setTitle:ZHLS(@"CreateNote") forState:UIControlStateNormal];
    [self.createFolderButton setTitle:ZHLS(@"CreateFolder") forState:UIControlStateNormal];
    
    [self.creatNoteButton setTitleColor:kPrimaryColor forState:UIControlStateNormal];
    [self.createFolderButton setTitleColor:kPrimaryColor forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleTextField.text = title;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.root.shouldTitle = NO;
    if ([textField.text isEqualToString:self.root.displayName]) {
        return;
    }
    if (textField.text.length > 15) {
        showToast(ZHLS(@"NameTooLength"));
        return;
    }
    if ([textField.text containsString:@"/"]) {
        showToast(ZHLS(@"InvalidName"));
        return;
    }
    BOOL ret = [self.root rename:textField.text];
    if (!ret) {
        showToast(@"Error");
    }
    if (kDevicePad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ItemNameChaned" object:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)reload
{
    if (self.chooseFolder) {
        [self loadFolders];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChoose)];
    } else {
        [self loadItems];
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"select"] style:UIBarButtonItemStylePlain target:self action:@selector(toogleEditing)];
        self.navigationItem.rightBarButtonItem = edit;
        if (dataArray.count == 0) {
            editing = NO;
            self.toolBarBottom.constant = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
    }
    self.emptyTipLabel.hidden = dataArray.count > 0;
    if (_root.shouldTitle) {
        [self.titleTextField becomeFirstResponder];
    }
}

- (void)setupNavBarItemWithButton:(NSArray*)buttons
{
//    UIToolbar *toolBar = [[UIToolbar alloc]init];
//    toolBar.items = buttons;
//    toolBar.frame = CGRectMake(0, 0, 90, 44);
//    toolBar.backgroundColor = [UIColor clearColor];
//    toolBar.tintColor = self.navigationController.navigationBar.barTintColor;
//    for (UIView *view in toolBar.subviews) {
//        if ([view isKindOfClass:[UIImageView class]]) {
//            [view removeFromSuperview];
//        }
//    }
//    UIBarButtonItem *customUIBarButtonitem = [[UIBarButtonItem alloc] initWithCustomView:toolBar];
//    self.navigationItem.rightBarButtonItem = customUIBarButtonitem;
}

- (void)cancelChoose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toogleEditing
{
    editing = !editing;
    self.toolBarBottom.constant = editing ? 44 : 0;
    self.toolBar.layer.shadowColor = [UIColor grayColor].CGColor;
    self.toolBar.layer.shadowOffset = CGSizeMake(0, -1);
    self.toolBar.layer.shadowOpacity = 1;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];

    [self reload];
}

- (void)newItem
{
    if (control == nil) {
        self.createViewTop.constant = 0;
        control = [[UIControl alloc]initWithFrame:self.view.bounds];
        control.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
        [control addTarget:self action:@selector(newItem) forControlEvents:UIControlEventTouchDown];
        [self.view insertSubview:control belowSubview:self.createView];
    }else{
        self.createViewTop.constant = -88;
        [control removeFromSuperview];
        control = nil;
    }

    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)loadItems
{
    dataArray = [NSMutableArray array];

    NSArray<Item*> *children = self.root ? self.root.children : @[[Item localRoot],[Item cloudRoot]];
    
    NSDictionary *last = nil;
    for (Item *i in children) {
        NSDate *date = i.modifyDate;
        if (last == nil || ![last[@"date"] isEqualToString:date.date]) {
            last = @{@"date":date.date,@"items":[@[] mutableCopy]};
            [dataArray addObject:last];
        }
        [last[@"items"] addObject:i];
    }
    
    [self.itemTableView reloadData];
}

- (void)loadFolders
{
    dataArray = [NSMutableArray array];
    NSArray *children = self.root ? self.root.children : @[[Item localRoot],[Item cloudRoot]];
    NSDictionary *last = nil;
    for (Item *i in children) {
        if (i.type != FileTypeFolder) {
            continue;
        }
        NSString *date = i.modifyDate.date ? i.modifyDate.date : @"";
        if (last == nil || ![last[@"date"] isEqualToString:date]) {
            last = @{@"date":date,@"items":[@[] mutableCopy]};
            [dataArray addObject:last];
        }
        [last[@"items"] addObject:i];
    }
    [self.itemTableView reloadData];
}

- (NSArray*)selectedArray
{
    NSArray *children = self.root ? self.root.children : @[[Item localRoot],[Item cloudRoot],[Item dropboxRoot]];
    return [children filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [(Item*)evaluatedObject selected];
    }]];
}

- (IBAction)export:(id)sender
{
    if ([self selectedArray].count == 0) {
        showToast(ZHLS(@"You did not select any file!"));
        return;
    }
    [self export:[self selectedArray] sourceView:sender];
}

- (IBAction)delete:(id)sender
{
    if ([self selectedArray].count == 0) {
        showToast(ZHLS(@"You did not select any file!"));
        return;
    }
    [self deleteItems:[self selectedArray]];
}

- (IBAction)move:(id)sender
{
    if ([self selectedArray].count == 0) {
        showToast(ZHLS(@"You did not select any file!"));
        return;
    }
    NSString *name = kDevicePhone ? @"Main_iPhone" : @"Main_iPad";
    MainViewController *vc = [[UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"item_list"];
    vc.root = nil;
    vc.chooseFolder = YES;
    vc.didChooseFolder = ^(Item *parent){
        [self moveItems:[self selectedArray] toParent:parent];
    };
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)createNote:(id)sender
{
    NSString *name = [ZHLS(@"Untitled") stringByAppendingString:@".md"];
    
    next = [self.root createItem:name type:FileTypeText];
    next.shouldTitle = YES;
    if (next) {
        [Configure sharedConfigure].currentItem = next;
        [self newItem];
        if (kDevicePad) {
            [self reload];
        }
        [self performSegueWithIdentifier:@"edit" sender:self];
    }
}

- (IBAction)createFolder:(id)sender
{
    NSString *name = ZHLS(@"UntitledFolder");
    
    next = [self.root createItem:name type:FileTypeFolder];
    next.shouldTitle = YES;

    if (next) {
        NSString *name = kDevicePhone ? @"Main_iPhone" : @"Main_iPad";
        MainViewController *vc = [[UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"item_list"];
        vc.root = next;
        [self newItem];
        [self.navigationController pushViewController:vc animated:YES];
        if (kDevicePad) {
            [self reload];
        }
    }
}

#pragma mark 文件操作

- (void)export:(NSArray<Item *>*) items sourceView:(UIView*)view{
    NSMutableArray *urls = [NSMutableArray array];
    
    for (Item *i in items) {
        if (i.type == FileTypeFolder) {
            continue;
        }
        NSURL *url = [NSURL fileURLWithPath:i.path];
        [urls addObject:url];
    }
    NSArray *objectsToShare = urls;
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr
                                    ];
    controller.excludedActivityTypes = excludedActivities;
    
    if (kDevicePhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        popVc = controller.popoverPresentationController;
        popVc.sourceView = view;
        popVc.sourceRect = view.bounds;
        popVc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:controller animated:YES completion:nil];
        });
    }
}

- (void)deleteItems:(NSArray<Item*>*)items
{
    EXUAlertView *alert = [[EXUAlertView alloc] initWithTitle:ZHLS(@"DeleteMessage")
                                                     delegate:nil
                                            cancelButtonTitle:ZHLS(@"Cancel")
                                            otherButtonTitles:ZHLS(@"Delete"), nil];
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
            for (Item *i in items) {
                [i trash];
            }
            [self reload];
        }
    };
    [alert show];
    
}

- (void)moveItems:(NSArray<Item*>*)items toParent:(Item*)parent
{
    for (Item *i in items) {
        [i moveToParent:parent];
        i.selected = NO;
    }
    
    [self reload];
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
    ItemTableViewCell *cell = (ItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    
    Item *item = dataArray[indexPath.section][@"items"][indexPath.row];
    cell.item = item;
    
    SeparatorLine *line = [cell viewWithTag:4654];
    [line removeFromSuperview];
    if (indexPath.row != 0) {
        SeparatorLine *line = [[SeparatorLine alloc]initWithStart:CGPointMake(20, 0) width:self.view.bounds.size.width - 30 color:kPrimaryColor];
        line.tag = 4654;
        [cell addSubview:line];
    }

    __weak typeof(self) weakself = self;
    cell.didCheckItem = ^(Item *i){
        if (weakself.chooseFolder) {
            EXUAlertView *alert = [[EXUAlertView alloc]initWithTitle:[NSString stringWithFormat: ZHLS(@"MoveTips"),i.displayName]
                                                            delegate:nil
                                                   cancelButtonTitle:ZHLS(@"Cancel")
                                                   otherButtonTitles:ZHLS(@"OK"), nil];
            alert.clickedButton = ^(NSInteger index){
                if (index) {
                    weakself.didChooseFolder(i);
                    [weakself dismissViewControllerAnimated:YES completion:nil];
                }
            };
            [alert show];
            return ;
        }
        i.selected = !i.selected;
        [tableView reloadData];
    };
    
    cell.showCheckButton = editing || _chooseFolder;

    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return dataArray[section][@"date"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editing) {
        return;
    }

    next = dataArray[indexPath.section][@"items"][indexPath.row];

    
    if (_chooseFolder) {
        if ( [next.children filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [(Item*)evaluatedObject type] == FileTypeFolder;
        }]].count == 0) {
            return;
        }
    }
    if (next.type == FileTypeText) {
        [Configure sharedConfigure].currentItem = next;
        [self performSegueWithIdentifier:@"edit" sender:self];
    }else{
        NSString *name = kDevicePhone ? @"Main_iPhone" : @"Main_iPad";
        MainViewController *vc = [[UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"item_list"];
        vc.root = next;
        vc.chooseFolder = self.chooseFolder;
        vc.didChooseFolder = self.didChooseFolder;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (kDevicePhone) {
        [super performSegueWithIdentifier:identifier sender:sender];
    }else{
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (_recievedItem) {
        next = _recievedItem;
        _recievedItem = nil;
        return;
    }
    if (next.type == FileTypeFolder) {
        MainViewController *vc = segue.destinationViewController;
        vc.root = next;
    }
}

@end
