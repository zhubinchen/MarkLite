//
//  EditViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-31.
//  Copyright (c) 2016年 zhubch. All rights reserved.
//

#import "EditViewController.h"
#import "PreviewViewController.h"
#import "FileListViewController.h"
#import "FontViewController.h"
#import "EditView.h"
#import "KeyboardBar.h"
#import "FileManager.h"
#import "Configure.h"
#import "Item.h"
#import "AppDelegate.h"

@interface EditViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;

@end

@implementation EditViewController
{
    UIBarButtonItem *preview;
    Item *item;
    FileManager *fm;
    UIControl *control;
    NSString *oldText;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    fm = [FileManager sharedManager];

    [[Configure sharedConfigure] addObserver:self forKeyPath:@"fontName" options:NSKeyValueObservingOptionNew context:NULL];
    [[Configure sharedConfigure] addObserver:self forKeyPath:@"fontSize" options:NSKeyValueObservingOptionNew context:NULL];

    if (kDevicePad) {
        [fm addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"keyboardAssist" options:NSKeyValueObservingOptionNew context:NULL];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
    
    if (kDevicePhone) {
        [self loadFile];
        self.navigationItem.rightBarButtonItems[1].title = ZHLS(@"Font");
    }else{
        self.navigationItem.rightBarButtonItems[1].title = ZHLS(@"FullScreen");
    }
    self.navigationItem.rightBarButtonItems[0].title = ZHLS(@"Preview");
}

- (void)viewDidLayoutSubviews
{
    if ([Configure sharedConfigure].keyboardAssist && [Configure sharedConfigure].landscapeEdit == NO) {
        KeyboardBar *bar = [[KeyboardBar alloc]init];
        bar.editView = _editView;
        bar.vc = self;
        _editView.inputAccessoryView = bar;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadFile];
    });
}

- (void)keyboardHide:(NSNotification*)noti
{
    self.bottom.constant = 0;
    [self.view updateConstraints];
}

- (void)keyboardShow:(NSNotification*)noti
{
    NSDictionary *info = noti.userInfo;
    CGFloat keyboardHeight = kScreenHeight - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.bottom.constant = keyboardHeight;
    [self.view updateConstraints];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem"]) {
        [self loadFile];
    }else if ([keyPath isEqualToString:@"fontName"] || [keyPath isEqualToString:@"fontSize"]) {
        self.editView.text = self.editView.text;
    }else if ([keyPath isEqualToString:@"keyboardAssist"]){
        if ([Configure sharedConfigure].keyboardAssist && [Configure sharedConfigure].landscapeEdit == NO) {
            KeyboardBar *bar = [[KeyboardBar alloc]init];
            bar.editView = _editView;
            bar.vc = self;
            _editView.inputAccessoryView = bar;
        }else{
            _editView.inputAccessoryView = nil;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (kDevicePad) {
        return;
    }
    if ([Configure sharedConfigure].landscapeEdit) {
        [AppDelegate setAllowRotation:YES];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveFile];
    [self.editView resignFirstResponder];
    if (kDevicePad) {
        return;
    }
    [AppDelegate setAllowRotation:NO];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)loadFile
{
    [self saveFile];

    if (fm.currentItem == nil) {
        self.editView.text = @" ";
        self.title = @" ";
        self.editView.editable = NO;
        return;
    }
    item = fm.currentItem;
    
    NSString *path = item.fullPath;
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.view);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        oldText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        oldText = oldText ? oldText : @"";
        dispatch_async(dispatch_get_main_queue(), ^{
            stopLoadingAnimationOnParent(self.view);
            
            self.editView.text = oldText;
            self.editView.editable = YES;
            self.title = item.name;
        });
    });
}

- (IBAction)fullScreen:(UIBarButtonItem*)sender{
    if (self.splitViewController.preferredDisplayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        sender.title = ZHLS(@"FullScreen");
    }else{
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
        sender.title = ZHLS(@"Return");
    }
}


- (void)saveFile
{
    if (item == nil) {
        return;
    }
    if ([self.editView.text isEqualToString:oldText]) {
        return;
    }
    
    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [fm saveFile:item.fullPath Content:content];
}

- (void)dealloc
{
    [[Configure sharedConfigure] removeObserver:self forKeyPath:@"fontName"];
    [[Configure sharedConfigure] removeObserver:self forKeyPath:@"fontSize"];

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
