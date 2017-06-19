//
//  EditViewController.m
//  MarkLite
//
//  Created by Bingcheng on 15-3-31.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import "EditViewController.h"
#import "FontViewController.h"
#import "EditView.h"
#import "KeyboardBar.h"
#import "Configure.h"
#import "Item.h"
#import "AppDelegate.h"
#import "PDFPageRender.h"
#import "SplitViewController.h"
#import "StyleViewController.h"

@interface EditViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *renderViewWidth;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (assign, nonatomic) BOOL split;

@end

@implementation EditViewController
{
    UIBarButtonItem *preview;
    UIControl *control;
    NSString *oldText;
    Item *item;
    UIBarButtonItem *exportBtn;
    UIBarButtonItem *styleBtn;
    UIBarButtonItem *splitBtn;
    UIPopoverPresentationController *popVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (kDevicePad) {
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"keyboardAssist" options:NSKeyValueObservingOptionNew context:NULL];
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveFile) name:@"ApplicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveFile) name:@"ApplicationWillTerminate" object:nil];
    
    if ([Configure sharedConfigure].keyboardAssist && [Configure sharedConfigure].landscapeEdit == NO) {
        KeyboardBar *bar = [[KeyboardBar alloc]init];
        bar.editView = _editView;
        bar.vc = self;
        _editView.inputAccessoryView = bar;
    }

    __weak typeof(self) weakSelf = self;
    _editView.textChanged = ^(NSString *text){
        weakSelf.renderView.text = text;
    };
    [self loadFile];
    
    exportBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"export"] style:UIBarButtonItemStylePlain target:self action:@selector(export)];
    styleBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"options"] style:UIBarButtonItemStylePlain target:self action:@selector(style)];
    splitBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"split"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleSplit)];
    self.navigationItem.rightBarButtonItems = kDevicePad ? @[exportBtn,splitBtn,styleBtn] : @[exportBtn,styleBtn];
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    if (kDevicePad) {
        v.backgroundColor = [UIColor redColor];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(displayModeAction:)];
    }

    self.split = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.editView resignFirstResponder];
    [self showRateAlert];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)displayModeAction:(id)sender
{
    [self.editView resignFirstResponder];
    id targert = self.splitViewController.displayModeButtonItem.target;
    SEL action = self.splitViewController.displayModeButtonItem.action;
    IMP imp = [targert methodForSelector:action];
    void (*func)(id, SEL, id) = (void *)imp;
    func(targert, action, sender);
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    item.shouldTitle = NO;
    if ([textField.text isEqualToString:item.displayName]) {
        return;
    }
    if (textField.text.length > 15) {
        showToast(ZHLS(@"NameTooLength"));
        return;
    }
    if ([textField.text containsString:@"/"]) {
        showToast(ZHLS(@"InvalidName"));
        return;
    }
    BOOL ret = [item rename:textField.text];
    if (kDevicePad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ItemNameChaned" object:nil];
    }
    if (!ret) {
        showToast(@"Error");
    }
}

- (void)toggleSplit
{
    self.split = !self.split;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat w = kWindowWidth;
    if (_split) {
        w = w * 0.5;
    }
    _editViewWidth.constant = w - 30;
    _renderViewWidth.constant = w - 30;
    [self.view layoutIfNeeded];
}

- (void)style{
    StyleViewController *vc = [[StyleViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setSplit:(BOOL)split
{
    _split = split;
    splitBtn.image = [UIImage imageNamed:_split ? @"split_s" : @"split"];
    CGFloat w = kWindowWidth;
    if (_split) {
        w = w * 0.5;
    }
    _editViewWidth.constant = w - 30;
    _renderViewWidth.constant = w - 30;
    [self.view layoutIfNeeded];
}

- (void)keyboardHide:(NSNotification*)noti
{
    self.bottom.constant = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardShow:(NSNotification*)noti
{
    NSDictionary *info = noti.userInfo;
    CGFloat keyboardHeight = kWindowHeight - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.bottom.constant = keyboardHeight;
    [UIView animateWithDuration:[info[UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0 options:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]  animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem"]) {
        [self loadFile];
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

- (void)loadFile
{
    [self saveFile];

    if ([Configure sharedConfigure].currentItem == nil) {
        self.editView.text = @" ";
        self.title = @" ";
        self.editView.editable = NO;
        return;
    }

    item = [Configure sharedConfigure].currentItem;
    
    NSString *path = item.path;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        oldText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.editView.text = oldText;
            self.editView.editable = YES;
            self.title = item.displayName;
        });
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasShowSwapTips"]) {
            EXUAlertView *alert = [[EXUAlertView alloc]initWithTitle:ZHLS(@"PreviewTips") delegate:self cancelButtonTitle:ZHLS(@"Gotit") otherButtonTitles:nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasShowSwapTips"];
        }
    });
    
}

- (void)saveFile
{
    NSLog(@"save begin");
    if (item == nil) {
        return;
    }
    
    if ([self.editView.text isEqualToString:oldText]) {
        return;
    }
    
    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    [item save:content];
    NSLog(@"save end");
}

- (void)dealloc
{
    if (kDevicePad){
        [[Configure sharedConfigure] removeObserver:self forKeyPath:@"currentItem"];
        [[Configure sharedConfigure] removeObserver:self forKeyPath:@"keyboardAssist"];
    }
    [self saveFile];
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (void)didReceiveMemoryWarning
{
    [self saveFile];
}

- (void)export
{
    void(^clickedBlock)(NSInteger) = ^(NSInteger index) {
        NSURL *url = nil;
        if (index == (kDevicePad ? 1 : 0)){
            url = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"/temp/%@.html",item.displayName]]];
            if (_renderView.html) {
                [_renderView.html writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }else if(index == (kDevicePad ? 2 : 1)){
            url = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"/temp/%@.pdf",item.displayName]]];
            
            NSData *data = [self createPDF];
            [data writeToURL:url atomically:YES];
        }else if(index == (kDevicePad ? 3 : 2)){
            url = [NSURL fileURLWithPath:item.path];
        }
        if (url) {
            [self exportFile:url];
        }
    };
    if (kDevicePad) {
        EXUAlertView *alert = [[EXUAlertView alloc]initWithTitle:ZHLS(@"ExportAs")
                                                        delegate:nil
                                               cancelButtonTitle:@""
                                               otherButtonTitles:ZHLS(@"WebPage"),
                               ZHLS(@"PDF"),
                               ZHLS(@"Markdown"), nil];
        alert.clickedButton = clickedBlock;
        [alert show];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:ZHLS(@"ExportAs") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:ZHLS(@"WebPage"),ZHLS(@"PDF"),ZHLS(@"Markdown"), nil];
        sheet.clickedButton = clickedBlock;
        [sheet showInView:self.view];
    }
}

- (void)exportFile:(NSURL*)url
{
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr
                                    ];
    controller.excludedActivityTypes = excludedActivities;
    
    if (kDevicePad) {
        popVc = controller.popoverPresentationController;
        popVc.barButtonItem = self.navigationItem.rightBarButtonItem;
        popVc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (NSData*)createPDF{
    
    PDFPageRender *render = [[PDFPageRender alloc]init];
    return [render renderPDFFromHtmlString:_renderView.html];
}

- (void)showRateAlert
{
    if (![ZHLS(@"About") isEqualToString:@"关于"]) {
        return;
    }
    
    [Configure sharedConfigure].useTimes += 1;
    if ([Configure sharedConfigure].useTimes < 30 || [Configure sharedConfigure].hasRated) {
        return ;
    }
    
    NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:[Configure sharedConfigure].showRateTime];
    if (t < 60*60*24*2) {
        return ;
    }
    
    EXUAlertView *alert = [[EXUAlertView alloc]initWithTitle:@"Hi，你对MarkLite的这个新版本有什么要说的吗？"
                                                    delegate:nil
                                           cancelButtonTitle:@"以后再说"
                                           otherButtonTitles:@"很好用，好评鼓励", @"不好用，提个意见", nil];
    alert.clickedButton = ^(NSInteger index){
        if (index == 1) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            [Configure sharedConfigure].hasRated = YES;
        }else if (index == 2){
            NSString *url = @"mailto:cheng4741@gmail.com?subject=MarkLite%20Report&body=";
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            [Configure sharedConfigure].hasRated = YES;
        }
    };
    [alert show];
    [Configure sharedConfigure].useTimes = 0;
    [Configure sharedConfigure].showRateTime = [NSDate date];
}

 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

 }

@end
