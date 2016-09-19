//
//  EditViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-31.
//  Copyright (c) 2015年 zhubch. All rights reserved.
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

@interface EditViewController () <UITextViewDelegate>

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

    [self loadFile];

    [[Configure sharedConfigure] addObserver:self forKeyPath:@"fontName" options:NSKeyValueObservingOptionNew context:NULL];

    if (kDevicePad) {
        [fm addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"keyboardAssist" options:NSKeyValueObservingOptionNew context:NULL];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    
    if (kDevicePhone) {
        self.navigationItem.rightBarButtonItems[1].title = ZHLS(@"Font");
    }else{
        self.navigationItem.rightBarButtonItems[1].title = ZHLS(@"FullScreen");
    }
    self.navigationItem.rightBarButtonItems[0].title = ZHLS(@"Preview");
}

- (void)viewDidLayoutSubviews
{
    if ([Configure sharedConfigure].keyboardAssist) {
        KeyboardBar *bar = [[KeyboardBar alloc]init];
        bar.editView = _editView;
        bar.vc = self;
        _editView.inputAccessoryView = bar;
    }
}

- (void)keyboardShow:(NSNotification*)noti
{
    NSDictionary *info = noti.userInfo;
    CGFloat keyboardHeight = [[info objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    self.bottom.constant = keyboardHeight;
    [self.view updateConstraints];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem"]) {
        [self loadFile];
    }else if ([keyPath isEqualToString:@"fontName"]) {
        [self.editView updateSyntax];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    needSave = YES;
    if ([text isEqualToString:@"\n"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [textView insertText:@"\t"];
        });
    }
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
}

- (void)dealloc
{
    [[Configure sharedConfigure] removeObserver:self forKeyPath:@"fontName"];

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
