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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"load1");

    fm = [FileManager sharedManager];

    _editView.delegate = self;
    NSLog(@"file");
    [self loadFile];
    NSLog(@"file");

    [[Configure sharedConfigure] addObserver:self forKeyPath:@"fontName" options:NSKeyValueObservingOptionNew context:NULL];

    if (kDevicePad) {
        [fm addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"keyboardAssist" options:NSKeyValueObservingOptionNew context:NULL];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (kDevicePhone) {
        self.navigationItem.rightBarButtonItems[1].title = ZHLS(@"Font");
    }else{
        self.navigationItem.rightBarButtonItems[1].title = ZHLS(@"FullScreen");
    }
    self.navigationItem.rightBarButtonItems[0].title = ZHLS(@"Preview");
    NSLog(@"load2");
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"appear");
    if ([Configure sharedConfigure].keyboardAssist) {
        KeyboardBar *bar = [[KeyboardBar alloc]init];
        bar.editView = _editView;
        bar.vc = self;
        _editView.inputAccessoryView = bar;
        [self keyboardHide:nil];
    }
}

- (void)keyboardShow:(NSNotification*)noti
{
    NSDictionary *info = noti.userInfo;
    CGFloat keyboardHeight = [[info objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    CGRect begin = [[info objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect end = [[info objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    // 第三方键盘回调三次问题，监听仅执行最后一次
    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
        self.bottom.constant = keyboardHeight;
        [self.view layoutIfNeeded];
    }
}

- (void)keyboardHide:(NSNotification*)noti
{
    self.bottom.constant = 0;
    [self.view layoutIfNeeded];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [textView scrollRangeToVisible:textView.selectedRange];
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
        self.editView.text = ZHLS(@"CanNotEdit");
        self.editView.editable = NO;
        return;
    }else{
        self.editView.editable = YES;
    }
    
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
    if (self.editView.editable == NO) {
        return;
    }
    
    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [fm saveFile:item.fullPath Content:content];
}

- (void)dealloc
{
    if (kDevicePad){
        [fm removeObserver:self forKeyPath:@"currentItem" context:NULL];
        [[Configure sharedConfigure] removeObserver:self forKeyPath:@"keyboardAssist"];
        [[Configure sharedConfigure] removeObserver:self forKeyPath:@"fontName"];
    }
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

 }

@end
