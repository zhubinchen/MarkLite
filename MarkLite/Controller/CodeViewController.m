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
#import "FileManager.h"
#import "UserConfigure.h"
#import "ProjectViewController.h"

@interface CodeViewController () <UITextViewDelegate>

@end

@implementation CodeViewController
{
    UIBarButtonItem *preview;
    PreviewViewController *preViewVc;
    UIPopoverController *popVc;
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
    
    _editView.delegate = self;
    
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

- (void)loadFile
{
    NSString *path = [FileManager sharedManager].currentFilePath;
    NSString *htmlStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSArray *temp = [[FileManager sharedManager].currentFilePath componentsSeparatedByString:@"/"];
    self.title = temp[temp.count - 1];
    
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
    [[UserConfigure sharedConfigure].fileHisory addObject:@{@"name":self.title,@"path":[path stringByReplacingOccurrencesOfString:[FileManager sharedManager].workSpace withString:@""]}];
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
        UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc] initWithType:@"open" localizedTitle:dic[@"name"] localizedSubtitle:dic[@"path"] icon:editIcon userInfo:nil];
        [items addObject:item];
    }
    [UIApplication sharedApplication].shortcutItems = items;
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
    [content writeToFile:[FileManager sharedManager].currentFilePath atomically:YES];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

 }

@end
