//
//  KeyboardBar.m
//  MarkLite
//
//  Created by zhubch on 11/10/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "KeyboardBar.h"
#import "ZHRequest.h"
#import "Configure.h"

static KeyboardBar *bar = nil;
@implementation KeyboardBar

- (instancetype)init
{
    CGFloat w = kScreenWidth / 9;
    
    if (w > 64) {
        w = 64;
    }
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, w)];
    self.backgroundColor = [UIColor colorWithRed:200/255.0 green:203/255.0 blue:211/255.0 alpha:1];
    [self createItem];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createItem) name:UIDeviceOrientationDidChangeNotification object:nil];
    return self;
}

- (void)createItem
{
//    for (UIView *v in self.subviews) {
//        [v removeFromSuperview];
//    }
    
    UIColor *titleColor = [UIColor colorWithRGBString:@"404040"];
    NSArray *titles = @[@"Tab",@"#",@"*",@"-",@">",@"`",@"add_image",@"add_link",@"keyboard_down"];
    CGFloat w = kScreenWidth / 9;
    
    if (w > 64) {
        w = 64;
    }
    CGFloat x = kScreenWidth - w * 9;
    CGFloat s = kDevicePhone ? 3 : 9;
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tintColor = [UIColor blueColor];
        btn.tag = i;
        btn.frame = CGRectMake(i * w + s + x, s, w - 2 * s, w - 2 * s);
        if (i == 0) {
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if (i < 6){
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
        }else if (i == titles.count - 1){
            [btn setImage:[UIImage imageNamed:titles[i]] forState:UIControlStateNormal];
        }else{
            [btn setImage:[UIImage imageNamed:titles[i]] forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        }
        [btn makeRound:6];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

- (void)itemClicked:(UIButton*)btn
{
    if (btn.tag == 0) {
        [_editView insertText:@"\t"];
    }else if (btn.tag  < 6) {
        [_editView insertText:btn.currentTitle];
    }else if (btn.tag == 6){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加图片" message:@"请输入图片相对路径或URL" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
            if (buttonIndex == 1) {
                NSString *name = [alert textFieldAtIndex:0].text;
                NSString *text = [NSString stringWithFormat:@"![图片描述](%@)",name];
                [_editView insertText:text];
                NSRange range = NSMakeRange(_editView.selectedRange.location - text.length + 2, 4);
                _editView.selectedRange = range;
            }
        };
        [alert show];
//        [self.editView resignFirstResponder];
//        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"添加图片" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从照片选取并上传",@"手动输入图片路径或链接", nil];
//        sheet.clickedButton = ^(NSInteger buttonIndex,UIActionSheet *alert){
//            if (buttonIndex == 0) {
//                bar = self;
//                UIImagePickerController *vc = [[UIImagePickerController alloc]init];
//                vc.delegate = self;
//                vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                [self.vc presentViewController:vc animated:YES completion:nil];
//                return ;
//            }else if(buttonIndex == 1){
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加图片" message:@"请输入图片相对路径或URL" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//                alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
//                    if (buttonIndex == 1) {
//                        NSString *name = [alert textFieldAtIndex:0].text;
//                        NSString *text = [NSString stringWithFormat:@"![图片描述](%@)",name];
//                        [_editView insertText:text];
//                        NSRange range = NSMakeRange(_editView.selectedRange.location - text.length + 2, 4);
//                        _editView.selectedRange = range;
//                    }
//                };
//                [alert show];
//            }
//        };
//        [sheet showInView:self.vc.view];
    }else if (btn.tag == 7){

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加链接" message:@"请输入链接" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
            if (buttonIndex == 1) {
                NSString *name = [alert textFieldAtIndex:0].text;
                NSString *text = [NSString stringWithFormat:@"[链接描述](%@)",name];
                [_editView insertText:text];
                [_editView becomeFirstResponder];
                NSRange range = NSMakeRange(_editView.selectedRange.location - text.length + 1, 4);
                _editView.selectedRange = range;
            }
        };
        [alert show];
    }else if (btn.tag == 8){
        [_editView performSelector:@selector(resignFirstResponder)];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(img, [Configure sharedConfigure].compressionQuality);
    
    beginLoadingAnimation(@"正在上传...");
    [ZHRequest initializeWithServerUrl:kServerUrl];
    [ZHRequest postWithUrl:@"upload.php" Body:data Succese:^(NSData *response) {
        NSLog(@"%@",response.toDictionay);
        NSDictionary *ret = response.toDictionay;
        if ([ret[@"payload"] length]) {
            NSString *name = [kServerUrl stringByAppendingPathComponent:ret[@"payload"]];
            NSString *text = [NSString stringWithFormat:@"![图片描述](%@)",name];
            [_editView insertText:text];
            [_editView becomeFirstResponder];
            NSRange range = NSMakeRange(_editView.selectedRange.location - text.length + 2, 4);
            _editView.selectedRange = range;
        }else{
            showToast(@"上传失败了😂");
        }

        stopLoadingAnimation();
    } Failed:^(ErrorCode code) {
        stopLoadingAnimation();
        showToast(@"上传失败😂，请检查网络");
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
