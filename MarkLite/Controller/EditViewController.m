//
//  EditViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-31.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "EditViewController.h"
#import "PreviewViewController.h"
#import "EditView.h"
#import "KeyboardBar.h"
#import "FileManager.h"
#import "Configure.h"
#import "FileListViewController.h"
#import "Item.h"
#import "FileSyncManager.h"
#import "User.h"

@interface EditViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;

@end

@implementation EditViewController
{
    UIBarButtonItem *preview;
    Item *item;
    FileManager *fm;
    UIControl *control;
    CGFloat lastOffsetY;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"渲染" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [_projectVc performSegueWithIdentifier:@"preview" sender:self];
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"删除" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
    }];
    
    return @[action1,action2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    fm = [FileManager sharedManager];
    
    _editView.delegate = self;

    [self loadFile];

    if (kDevicePad) {
        [fm addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"keyboardAssist" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillLayoutSubviews
{
    if ([Configure sharedConfigure].keyboardAssist) {
        KeyboardBar *bar = [[KeyboardBar alloc]init];
        bar.editView = _editView;
        bar.vc = self;
        _editView.inputAccessoryView = bar;
    }
}

- (void)keyboardChanged:(NSNotification*)noti
{
    NSDictionary *info = noti.userInfo;
    
    NSTimeInterval interval = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat height =kScreenHeight - [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;

    [self.view layoutIfNeeded];
    [UIView animateWithDuration:interval animations:^{
        self.bottom.constant = height;
    }];
    [self updateViewConstraints];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem"]) {
        [self loadFile];
    }else{
        if ([change[@"new"] boolValue]) {
            KeyboardBar *bar = [[KeyboardBar alloc]init];
            bar.editView = _editView;
            bar.vc = self;
            _editView.inputAccessoryView = bar;
        }else{
            _editView.inputAccessoryView = nil;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveFile];
    [self.editView resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (kDevicePhone) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (kDevicePhone) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        });
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (kDevicePad || (!_editView.isFirstResponder)) {
        return;
    }
    if (scrollView.contentOffset.y < -40) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if (scrollView.contentOffset.y - lastOffsetY > 100) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else if (scrollView.contentOffset.y - lastOffsetY < -100) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    lastOffsetY = 0;
}

- (void)loadFile
{
    if (fm.currentItem == nil) {
        return;
    }
    item = fm.currentItem;

    if (item.type != FileTypeText) {
        self.editView.text = @"无法编辑该类型文件,你可以点击渲染来查看该文件";
        self.editView.editable = NO;
        return;
    }else{
        self.editView.editable = YES;
    }
    

    self.title = item.name;
    
    NSString *path = [fm fullPathForPath:item.path];
    NSString *htmlStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    self.editView.text = htmlStr;
    [self.editView updateSyntax];
    for (NSDictionary *dic in [Configure sharedConfigure].fileHisory) {
        if ([dic[@"path"] isEqualToString:path]) {
            return;
        }
    }
    
    if ([Configure sharedConfigure].fileHisory.count >= 3) {
        [[Configure sharedConfigure].fileHisory removeObjectAtIndex:0];
    }

    [[Configure sharedConfigure].fileHisory addObject:@{@"name":item.name,@"path":[path stringByReplacingOccurrencesOfString:fm.workSpace withString:@""]}];
    [[Configure sharedConfigure] saveToFile];
    [self createShortCutItem:[Configure sharedConfigure].fileHisory];
}

-(void)createShortCutItem:(NSArray*)fileHistory
{
//    UIApplicationShortcutIcon *editIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCompose];
//    UIApplicationShortcutItem *new = [[UIApplicationShortcutItem alloc] initWithType:@"new" localizedTitle:@"新建" localizedSubtitle:@"" icon:editIcon userInfo:nil];
//    NSMutableArray *items = [NSMutableArray arrayWithObject:new];
//
//    for (int i = (int)fileHistory.count - 1; i >= 0; i--) {
//        NSDictionary *dic = fileHistory[i];
//        UIApplicationShortcutItem *shortCut = [[UIApplicationShortcutItem alloc] initWithType:@"open" localizedTitle:dic[@"name"] localizedSubtitle:dic[@"path"] icon:editIcon userInfo:nil];
//        [items addObject:shortCut];
//    }
//    [UIApplication sharedApplication].shortcutItems = items;
}

- (IBAction)fullScreen:(UIBarButtonItem*)sender{
    if (self.splitViewController.preferredDisplayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        sender.title = @"全屏";
    }else{
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
        sender.title = @"还原";
    }
}


- (void)saveFile
{
    if (self.editView.editable == NO) {
        return;
    }
    
    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [content writeToFile:[fm fullPathForPath:item.path] atomically:YES];
    
    if (![User currentUser].hasLogin) {
        return;
    }
    [[FileSyncManager sharedManager] uploadFile:item progressHandler:^(float percent) {
        NSLog(@"upload %@: %.2f",item.path,percent);
    } result:^(BOOL success) {
        if (success) {
            item.syncStatus = SyncStatusSuccess;
        }else{
            item.syncStatus = SyncStatusUnUpload;
        }
    }];
}

- (void)dealloc
{
    if (kDevicePad){
        [fm removeObserver:self forKeyPath:@"currentItem" context:NULL];
        [[Configure sharedConfigure] removeObserver:self forKeyPath:@"keyboardAssist"];
    }
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

 }

@end
