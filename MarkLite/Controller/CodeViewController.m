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
#import "ProjectViewController.h"
#import "Item.h"

@interface CodeViewController () <UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UITextField *nameField;

@end

@implementation CodeViewController
{
    UIBarButtonItem *preview;
    PreviewViewController *preViewVc;
    UIPopoverController *popVc;
    Item *item;
    FileManager *fm;
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
