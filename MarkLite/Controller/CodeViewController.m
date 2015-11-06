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
#import "FileManager.h"
#import "ZBCKeyBoard.h"

@interface CodeViewController () <UITextViewDelegate>

@end

@implementation CodeViewController
{
    UIBarButtonItem *preview;
    PreviewViewController *preViewVc;
    UIPopoverController *popVc;
    FileManager *fm;
    
    float lastOffsetY;
}


- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    // 生成UIPreviewAction
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Action 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 1 selected");
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Action 2" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 2 selected");
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Action 3" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Action 3 selected");
    }];
    
    UIPreviewAction *tap1 = [UIPreviewAction actionWithTitle:@"tap 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"tap 1 selected");
    }];
    
    UIPreviewAction *tap2 = [UIPreviewAction actionWithTitle:@"tap 2" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"tap 2 selected");
    }];
    
    UIPreviewAction *tap3 = [UIPreviewAction actionWithTitle:@"tap 3" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"tap 3 selected");
    }];
    
    //添加到到UIPreviewActionGroup中
    NSArray *actions = @[action1, action2, action3];
    NSArray *taps = @[tap1, tap2, tap3];
    UIPreviewActionGroup *group1 = [UIPreviewActionGroup actionGroupWithTitle:@"Action Group" style:UIPreviewActionStyleDefault actions:actions];
    UIPreviewActionGroup *group2 = [UIPreviewActionGroup actionGroupWithTitle:@"Tap Group" style:UIPreviewActionStyleDefault actions:taps];
    NSArray *group = @[group1,group2];
    
    return group;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    preview = [[UIBarButtonItem alloc]initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(preview)];

    _editView.delegate = self;
    

//    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 40, -40, 40, 40)];
//    v.backgroundColor = [UIColor colorWithRGBString:@"eeff00"];
//    [_editView.keyboard addSubview:v];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    if (kIsPhone) {
        self.navigationItem.rightBarButtonItem = preview;
    } else {
        self.tabBarController.navigationItem.rightBarButtonItem = preview;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem = nil;
    [self saveFile];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (kIsPhone) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (kIsPhone) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!kIsPhone) {
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
    NSString *path = [FileManager sharedManager].currentFilePath;

    NSString *htmlStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSArray *temp = [path componentsSeparatedByString:@"/"];
    self.title = temp[temp.count - 1];
    
    self.editView.text = htmlStr;
    [self.editView updateSyntax];
}

- (void)preview
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
    NSString *path = [FileManager sharedManager].currentFilePath;

    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [content writeToFile:path atomically:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
