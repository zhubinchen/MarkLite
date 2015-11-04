//
//  QrCodeView.m
//  MarkLite
//
//  Created by zhubch on 15/4/8.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "QrCodeView.h"
#import "QRCodeGenerator.h"
#import "UserDefault.h"

@implementation QrCodeView

- (void)awakeFromNib
{
    NSString *url = @"http://www.baidu.com";

    NSDictionary *config = [UserDefault sharedDefault].httpConfig;
    
    if (config != nil) {
        url = [NSString stringWithFormat:@"http://%@:%@",config[@"ip"],config[@"port"]];
    }
    
    self.codeImage.image = [QRCodeGenerator qrImageForString:url imageSize:300];
    self.urlLabel.text = [NSString stringWithFormat:@"扫描二维码或直接输入以下地址：\n%@",url];
    [[UserDefault sharedDefault] addObserver:self forKeyPath:@"httpConfig" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"httpConfig"]) {
        NSLog(@"%@",change);
        NSString *url = @"http://www.baidu.com";

        NSDictionary *config = [UserDefault sharedDefault].httpConfig;
        
        if (config != nil) {
            url = [NSString stringWithFormat:@"http://%@:%@",config[@"ip"],config[@"port"]];
        }
        self.codeImage.image = [QRCodeGenerator qrImageForString:url imageSize:300];
        self.urlLabel.text = [NSString stringWithFormat:@"扫描二维码或直接输入以下地址：\n%@",url];
    }
}

@end
