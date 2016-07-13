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
    ImageUploadingView *uploadView;
}
- (instancetype)init
{
    CGFloat w = kScreenWidth / 9;
    
    if (w > 64) {
        w = 64;
    }
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, w)];
    self.backgroundColor = [UIColor colorWithRed:200/255.0 green:203/255.0 blue:211/255.0 alpha:1];
    [self createItem];
    return self;
}

- (void)createItem
{
    
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
        [self.editView resignFirstResponder];
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:ZHLS(@"InsertImage") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:ZHLS(@"PickImageAndUpload"),ZHLS(@"InputImageSrc"), nil];
        sheet.clickedButton = ^(NSInteger buttonIndex){
            if (buttonIndex == 0) {
                bar = self;
                UIImagePickerController *vc = [[UIImagePickerController alloc]init];
                vc.delegate = self;
                vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.vc presentViewController:vc animated:YES completion:nil];
                }];
            }else if(buttonIndex == 1){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"Insert Image") message:ZHLS(@"InputImageSrcTips") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                __weak UIAlertView * __alert = alert;
                alert.clickedButton = ^(NSInteger buttonIndex){
                    if (buttonIndex == 1) {
                        NSString *name = [__alert textFieldAtIndex:0].text;
                        NSString *text = [NSString stringWithFormat:@"![MarkLite](%@)",name];
                        [_editView insertText:text];
                        [_editView becomeFirstResponder];
                    }
                };
                [alert show];
            }
        };
        [sheet showInView:self.vc.view];
    }else if (btn.tag == 7){

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
    NSData *data = UIImageJPEGRepresentation(img, [Configure sharedConfigure].imageResolution);
    [self upload:data];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)upload:(NSData*)data
{

    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    // 2. Create an `NSMutableURLRequest`.
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:kImageUploadUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[kToken dataUsingEncoding:NSUTF8StringEncoding] name:@"Token"];
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:@"imageFile.jpg"
                                mimeType:@"image/jpg"];
        
    } error:nil];
    
    // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSDictionary *dic = responseObject;
                                         [uploadView dismiss];
                                         NSString *text = [NSString stringWithFormat:@"![MarkLite](%@)",dic[@"t_url"]];
                                         [_editView insertText:text];
                                         [_editView becomeFirstResponder];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"%@",error);
                                         [uploadView dismiss];
                                     }];
    
    uploadView = [[ImageUploadingView alloc]initWithTitle:ZHLS(@"Uploading") cancelBlock:^{
        [operation cancel];
    }];
    [uploadView show];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        uploadView.percent = totalBytesWritten/(double)totalBytesExpectedToWrite;
    }];
    
    // 5. Begin!
    [operation start];
}

//- (void)dealloc
//{
//    NSLog(@"dealloc");
//}

@end
