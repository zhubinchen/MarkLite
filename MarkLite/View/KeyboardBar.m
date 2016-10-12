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
#import "AFNetworking.h"
#import "ImageUploadingView.h"

static KeyboardBar *bar = nil;

@implementation KeyboardBar
{
    UIButton *tipsBtn;
    ImageUploadingView *uploadView;
}

- (instancetype)init
{
    CGFloat w = kScreenWidth / (kDevicePhone ? 8 : 16);

    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, w)];
    self.backgroundColor = [UIColor colorWithRed:200/255.0 green:203/255.0 blue:211/255.0 alpha:1];
    [self createItem];
    if (kDevicePad) {
        self.scrollEnabled = NO;
    }else{
        self.delegate = self;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.contentSize = CGSizeMake(0, w * 2);
    }
    return self;
}

- (void)createItem
{
    UIColor *titleColor = [UIColor colorWithRGBString:@"404040"];
    NSArray *titles = @[@"Tab",@"add_image",@"add_link",@" ",@"#",@"*",@"-",@">",@"`",@"!",@"[",@"]",@"(",@")",@"\\",@"keyboard_down"];
    int maxCount = kDevicePhone ? 8 : 16;
    CGFloat w = kScreenWidth / maxCount;

    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tintColor = [UIColor blueColor];
        btn.tag = i;
        btn.frame = CGRectMake(i % maxCount * w + 4, i / maxCount * w + 4, w - 2 * 4, w - 2 * 4);
        if (i == 0) {
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if (i < 3){
            [btn setImage:[UIImage imageNamed:titles[i]] forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        }else if (i < titles.count - 1){
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
        }else{
            [btn setImage:[UIImage imageNamed:titles[i]] forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        }
        [btn makeRound:6];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    
    if (kDevicePad || [Configure sharedConfigure].hasShownSwipeTips) {
        return;
    }
    tipsBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, w)];
    tipsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    tipsBtn.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [tipsBtn addTarget:self action:@selector(dismissTips) forControlEvents:UIControlEventTouchUpInside];
    [tipsBtn setTitle:ZHLS(@"SwipeTips") forState:UIControlStateNormal];
    [tipsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:tipsBtn];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self dismissTips];
}


- (void)dismissTips
{
    if (!tipsBtn) {
        return;
    }
    [Configure sharedConfigure].hasShownSwipeTips = YES;
    [tipsBtn removeFromSuperview];
}

- (void)itemClicked:(UIButton*)btn
{
    if (btn.tag == 0) {
        [_editView insertText:@"\t"];
        [self.inputDelegate didInputText];
    }else if (btn.tag == 1) {
        [self.editView resignFirstResponder];
        bar = self;
        UIImagePickerController *vc = [[UIImagePickerController alloc]init];
        vc.delegate = self;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (kDevicePad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.vc presentViewController:vc animated:YES completion:nil];
        }];
    }else if (btn.tag == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"InsertHref") message:ZHLS(@"InputHrefTips") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        __weak UIAlertView * __alert = alert;
        alert.clickedButton = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                NSString *name = [__alert textFieldAtIndex:0].text;
                NSString *text = [NSString stringWithFormat:@"[MarkLite](%@)",name];
                [_editView insertText:text];
                [_editView becomeFirstResponder];
                NSRange range = NSMakeRange(_editView.selectedRange.location - text.length + 1, 8);
                _editView.selectedRange = range;
                [self.inputDelegate didInputText];
            }
        };
        [alert show];
    }else if (btn.tag == 3) {
        [_editView insertText:@"&nbsp;"];
        [self.inputDelegate didInputText];
    }else if (btn.tag  < 15) {
        [_editView insertText:btn.currentTitle];
        [self.inputDelegate didInputText];
    }else if (btn.tag == 15){
        [_editView performSelector:@selector(resignFirstResponder)];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    img = img.fixOrientation;
    NSData *data = UIImageJPEGRepresentation(img, [Configure sharedConfigure].imageResolution);
    [self upload:data];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)upload:(NSData*)data
{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:kImageUploadUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[kToken dataUsingEncoding:NSUTF8StringEncoding] name:@"Token"];
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:@"imageFile.jpg"
                                mimeType:@"image/jpg"];
        
    } error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSDictionary *dic = responseObject;
                                         [uploadView dismiss];
                                         NSString *text = [NSString stringWithFormat:@"![MarkLite](%@)",dic[@"t_url"]];
                                         [_editView insertText:text];
                                         [self.inputDelegate didInputText];
                                         [_editView becomeFirstResponder];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"%@",error);
                                         [uploadView dismiss];
                                     }];
    
    uploadView = [[ImageUploadingView alloc]initWithTitle:ZHLS(@"Uploading") cancelBlock:^{
        [operation cancel];
    }];
    [uploadView show];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        uploadView.percent = totalBytesWritten/(double)totalBytesExpectedToWrite;
    }];
    
    [operation start];
}

//- (void)dealloc
//{
//    NSLog(@"dealloc");
//}

@end
