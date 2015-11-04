//
//  CloudView.m
//  HtmlLite
//
//  Created by zhubch on 15/4/24.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "CloudView.h"
#import "UserDefault.h"
#import "FileManager.h"
#import "LxFTPRequest.h"

@implementation CloudView

- (void)awakeFromNib
{
    NSDictionary *config = [UserDefault sharedDefault].httpConfig;
    
    if (config != nil) {
        _ftpTextField.text = config[@"ftp"];
        _nameTextField.text = config[@"name"];
        _passwdTextField.text = config[@"passwd"];
    }
    
    [_postBtn addTarget:self action:@selector(startSend) forControlEvents:UIControlEventTouchUpInside];
}

- (void)saveConfig
{
    if (_ftpTextField.text.length == 0) {
        return;
    }
    if (_nameTextField.text.length == 0) {
        return;
    }
    if (_passwdTextField.text.length == 0) {
        return;
    }
    
    [[UserDefault sharedDefault] setFtpConfig:@{@"ftp":_ftpTextField.text,@"name":_nameTextField.text,@"passwd":_passwdTextField.text}];
}

- (void)startSend
{
    [self saveConfig];
    
    NSDictionary *config = [UserDefault sharedDefault].ftpConfig;
    
    LxFTPRequest *requset = [LxFTPRequest uploadRequest];
    
    requset.serverURL = [NSURL URLWithString:config[@"ftp"]];
    requset.username = config[@"name"];
    requset.password = config[@"passwd"];
    
    NSString *path = [FileManager sharedManager].currentWorkSpacePath;
    requset.localFileURL = [NSURL fileURLWithPath:path];
    NSLog(@"%@",requset.serverURL);

    requset.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
        totalSize = MAX(totalSize, finishedSize);
    };
    requset.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString * errorMessage) {
        NSLog(@"zzz");    //
    };

    requset.successAction = ^(Class resultClass, id result){
        NSLog(@"%@",result);
    };
    [requset start];
}

@end