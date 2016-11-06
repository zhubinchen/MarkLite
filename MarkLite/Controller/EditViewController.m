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

@interface EditViewController () <UITextViewDelegate,KeyboardBarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;

@end

@implementation EditViewController
{
    UIBarButtonItem *preview;
    Item *item;
    FileManager *fm;
    UIControl *control;
    BOOL needSave;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    fm = [FileManager sharedManager];

    _editView.delegate = self;

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
        bar.inputDelegate = self;
        _editView.inputAccessoryView = bar;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadFile];
    });
}

- (void)didInputText
{
    needSave = YES;
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
        [self.editView updateSyntax];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    needSave = YES;
//    if ([text isEqualToString:@"\n"]) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [textView insertText:@"\t"];
//        });
//    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.bottom.constant = 0;
    [self.view updateConstraints];
    return YES;
}

- (void)loadFile
{
    if (fm.currentItem == nil) {
        self.editView.text = @" ";
        self.title = @" ";
        self.editView.editable = NO;
        return;
    }
    [self saveFile];
    item = fm.currentItem;
    
    NSString *path = item.fullPath;
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.view);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            stopLoadingAnimationOnParent(self.view);
            
            self.editView.text = text;
            self.editView.editable = YES;
            [self.editView updateSyntax];
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
    if (!needSave) {
        return;
    }
    
    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [fm saveFile:item.fullPath Content:content];
    needSave = NO;
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
