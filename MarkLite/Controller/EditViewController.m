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
#import "ZBCKeyBoard.h"
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
    PreviewViewController *preViewVc;
    UIPopoverController *popVc;
    Item *item;
    FileManager *fm;
    UIControl *control;
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
    
    if ([Configure sharedConfigure].keyboardAssist) {
        KeyboardBar *bar = [[KeyboardBar alloc]init];
        bar.editView = _editView;
        bar.vc = self;
        _editView.inputAccessoryView = bar;
    }
   
//    NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
//    _tagView.backgroundColor = [UIColor colorWithRGBString:rgbArray[item.tag] alpha:0.9];
//    [_tagView showBorderWithColor:[UIColor colorWithWhite:0.1 alpha:0.1] radius:8 width:1.5];

    [self loadFile];

    if (kDevicePad) {
        [fm addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"keyboardAssist" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
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
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
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
//    [self createShortCutItem:[Configure sharedConfigure].fileHisory];
}

-(void)createShortCutItem:(NSArray*)fileHistory
{
    UIApplicationShortcutIcon *editIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCompose];
    UIApplicationShortcutItem *new = [[UIApplicationShortcutItem alloc] initWithType:@"new" localizedTitle:@"新建" localizedSubtitle:@"" icon:editIcon userInfo:nil];
    NSMutableArray *items = [NSMutableArray arrayWithObject:new];

    for (int i = (int)fileHistory.count - 1; i >= 0; i--) {
        NSDictionary *dic = fileHistory[i];
        UIApplicationShortcutItem *shortCut = [[UIApplicationShortcutItem alloc] initWithType:@"open" localizedTitle:dic[@"name"] localizedSubtitle:dic[@"path"] icon:editIcon userInfo:nil];
        [items addObject:shortCut];
    }
    [UIApplication sharedApplication].shortcutItems = items;
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

//- (IBAction)preview:(id)sender
//{
//    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
//    if (kDevicePhone) {
//        [self performSegueWithIdentifier:@"preview" sender:self];
//    } else {
//        if (popVc == nil) {
//            PreviewViewController *vc = [[PreviewViewController alloc]init];
//            vc.view.backgroundColor =[UIColor whiteColor];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            popVc.popoverContentSize = CGSizeMake(320,360);
//            vc.size = popVc.popoverContentSize;
//            popVc = [[UIPopoverController alloc] initWithContentViewController:nav];
//        }
//
//        [popVc presentPopoverFromBarButtonItem:self.tabBarController.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    }
//}

//- (IBAction)changeTag:(id)sender
//{
//    if (selectTagView == nil) {
//        
//        control = [[UIControl alloc]initWithFrame:self.view.bounds];
//        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//        [control addTarget:self action:@selector(selectedTag:) forControlEvents:UIControlEventTouchDown];
//        
//        selectTagView = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth - 36, 0, 36, 0)];
//        selectTagView.backgroundColor = [UIColor whiteColor];
//        selectTagView.clipsToBounds = YES;
//        NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
//        for (int i = 0; i < rgbArray.count; i++) {
//            UIView *v = [[UIView alloc]initWithFrame:CGRectMake(10, i*36 + 10, 16, 16)];
//            v.backgroundColor = [UIColor colorWithRGBString:rgbArray[i] alpha:0.9];
//            [v showBorderWithColor:[UIColor colorWithWhite:0.1 alpha:0.1] radius:8 width:1.5];
//            [selectTagView addSubview:v];
//            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*36, 36, 36)];
//            btn.tag = i;
//            [btn addTarget:self action:@selector(selectedTag:) forControlEvents:UIControlEventTouchUpInside];
//            [selectTagView addSubview:btn];
//        }
//    }
//    
//    if (control.superview) {
//        [self selectedTag:nil];
//        return;
//    }
//    
//    [self.view addSubview:control];
//    [self.view addSubview:selectTagView];
//
//    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        selectTagView.frame = CGRectMake(kScreenWidth - 36, 0, 36, 36*6);
//        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [selectTagView showShadowWithColor:[UIColor grayColor] offset:CGSizeMake(-2, 2)];
//        }
//    }];
//}
//
//- (void)selectedTag:(UIButton*)sender
//{
//    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        selectTagView.frame = CGRectMake(kScreenWidth - 36, 0, 36, 0);
//        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
//    } completion:^(BOOL finished) {
//        [control removeFromSuperview];
//        selectTagView.clipsToBounds = YES;
//    }];
//    
//    if (![sender isKindOfClass:[UIButton class]] || sender == nil) {
//        return;
//    }
//    NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
//    item.tag = sender.tag;
//    _tagView.backgroundColor = [UIColor colorWithRGBString:rgbArray[sender.tag] alpha:0.9];
//}

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
