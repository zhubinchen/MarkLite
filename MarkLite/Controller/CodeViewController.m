//
//  CodeViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-31.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "CodeViewController.h"
#import "PreviewViewController.h"
#import "EditView.h"
#import "ZBCKeyBoard.h"
#import "KeyboardBar.h"
#import "FileManager.h"
#import "UserConfigure.h"
#import "FileListViewController.h"
#import "Item.h"

@interface CodeViewController () <UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UITextField *nameField;
@property (nonatomic,weak) IBOutlet UIView *tagView;

@end

@implementation CodeViewController
{
    UIBarButtonItem *preview;
    PreviewViewController *preViewVc;
    UIPopoverController *popVc;
    Item *item;
    FileManager *fm;
    UIView *selectTagView;
    UIVisualEffectView *blurView;
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
    item = fm.currentItem;
    
    _nameField.text = item.name;
    _editView.delegate = self;
    
    KeyboardBar *bar = [[KeyboardBar alloc]init];
    bar.editView = _editView;
    bar.vc = self;
    _editView.inputAccessoryView = bar;
   
    NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
    _tagView.backgroundColor = [UIColor colorWithRGBString:rgbArray[item.tag] alpha:0.9];
    [_tagView showBorderWithColor:[UIColor colorWithWhite:0.1 alpha:0.1] radius:8 width:1.5];

    if (kIsPhone) {
        [self loadFile];
    } else {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadFile) name:@"ChangeFile" object:nil];
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    if (kIsPhone) {
        return;
    }
    self.tabBarController.title = title;
    self.tabBarItem.title = @"代码";
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text containsString:@"."] | [textField.text containsString:@"/"] | [textField.text containsString:@"*"]) {
        [self showToast:@"请不要输入'./*'等特殊字符"];
        return NO;
    }
    NSString *oldPath = item.path;
    NSString *newPath = [[item.parent.path stringByAppendingPathComponent:textField.text] stringByAppendingPathExtension:item.extention];
    BOOL ret = [fm moveFile:oldPath toNewPath:newPath];
    if (ret) {
        item.path = newPath;
    }
    NSLog(@"%i",ret);
    return YES;
}

- (void)loadFile
{
    NSString *path = [fm fullPathForPath:item.path];
    NSString *htmlStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    self.editView.text = htmlStr;
    [self.editView updateSyntax];
    for (NSDictionary *dic in [UserConfigure sharedConfigure].fileHisory) {
        if ([dic[@"path"] isEqualToString:path]) {
            return;
        }
    }
    
    if ([UserConfigure sharedConfigure].fileHisory.count >= 3) {
        [[UserConfigure sharedConfigure].fileHisory removeObjectAtIndex:0];
    }
    [[UserConfigure sharedConfigure].fileHisory addObject:@{@"name":self.title,@"path":[path stringByReplacingOccurrencesOfString:fm.workSpace withString:@""]}];
    [[UserConfigure sharedConfigure] saveToFile];
    [self createShortCutItem:[UserConfigure sharedConfigure].fileHisory];
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

- (IBAction)undo:(id)sender
{
    [self.undoManager undo];
}

- (IBAction)redo:(id)sender
{
    [self.undoManager redo];
}

- (IBAction)preview:(id)sender
{
    if (kIsPhone) {
        [self performSegueWithIdentifier:@"preview" sender:self];
    } else {
        if (popVc == nil) {
            PreviewViewController *vc = [[PreviewViewController alloc]init];
            vc.view.backgroundColor =[UIColor whiteColor];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            popVc.popoverContentSize = CGSizeMake(320,360);
            vc.size = popVc.popoverContentSize;
            popVc = [[UIPopoverController alloc] initWithContentViewController:nav];
        }

        [popVc presentPopoverFromBarButtonItem:self.tabBarController.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (IBAction)changeTag:(id)sender
{
    if (selectTagView == nil) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurView = [[UIVisualEffectView alloc]initWithEffect:effect];
        blurView.frame = _editView.frame;
        blurView.alpha = 0.2;
        blurView.userInteractionEnabled = YES;
        
        UIControl *control = [[UIControl alloc]initWithFrame:blurView.bounds];
        [control addTarget:self action:@selector(selectedTag:) forControlEvents:UIControlEventTouchDown];
        [blurView.contentView addSubview:control];
        
        selectTagView = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth - 36, 35, 36, 0)];
        selectTagView.backgroundColor = [UIColor whiteColor];
        [selectTagView showShadowWithColor:[UIColor grayColor] offset:CGSizeMake(-2, -2)];
        selectTagView.clipsToBounds = YES;
        NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
        for (int i = 0; i < rgbArray.count; i++) {
            UIView *v = [[UIView alloc]initWithFrame:CGRectMake(10, i*36 + 10, 16, 16)];
            v.backgroundColor = [UIColor colorWithRGBString:rgbArray[i] alpha:0.9];
            [v showBorderWithColor:[UIColor colorWithWhite:0.1 alpha:0.1] radius:8 width:1.5];
            [selectTagView addSubview:v];
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*36, 36, 36)];
            btn.tag = i;
            [btn addTarget:self action:@selector(selectedTag:) forControlEvents:UIControlEventTouchUpInside];
            [selectTagView addSubview:btn];
        }
    }
    
    [self.view addSubview:blurView];
    [self.view addSubview:selectTagView];

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        selectTagView.frame = CGRectMake(kScreenWidth - 36, 35, 36, 36*6);
        blurView.alpha = 0.97;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)selectedTag:(UIButton*)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        selectTagView.frame = CGRectMake(kScreenWidth - 36, 35, 36, 0);
        blurView.alpha = 0.2;
    } completion:^(BOOL finished) {
        [blurView removeFromSuperview];
    }];
    
    if (![sender isKindOfClass:[UIButton class]]) {
        return;
    }
    NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
    item.tag = sender.tag;
    _tagView.backgroundColor = [UIColor colorWithRGBString:rgbArray[sender.tag] alpha:0.9];
}

- (void)saveFile
{
    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [content writeToFile:[fm fullPathForPath:item.path] atomically:YES];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

 }

@end
