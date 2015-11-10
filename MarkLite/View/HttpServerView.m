//
//  HttpServerView.m
//  MarkLite
//
//  Created by zhubch on 15/4/8.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "HttpServerView.h"
#import "HTTPServer.h"
#import "FileManager.h"
#import "UserDefault.h"

@implementation HttpServerView
{
    HTTPServer *server;
}

- (void)awakeFromNib
{
    NSDictionary *config = [UserDefault sharedDefault].httpConfig;

    if (config != nil) {
        _ipTextField.text = config[@"ip"];
        _portTextField.text = config[@"port"];
    }
    [_openSwitch addTarget:self action:@selector(startServer:) forControlEvents:UIControlEventValueChanged];
}

- (void)saveConfig
{
    if (_ipTextField.text.length == 0) {
        return;
    }
    if (_portTextField.text.length == 0) {
        return;
    }
    
    [[UserDefault sharedDefault] setHttpConfig:@{@"ip":_ipTextField.text,@"port":_portTextField.text}];
}

- (void)startServer:(UISwitch*)openSwitch
{
    [self saveConfig];
    
    NSDictionary *config = [UserDefault sharedDefault].httpConfig;
    
    if (openSwitch.on) {
        if (server == nil) {
            server = [[HTTPServer alloc]init];
            
            [server setType:@"_http._tcp."];
        }
        
        NSString *webPath = [FileManager sharedManager].currentFilePath;
        
        [server setDocumentRoot:webPath];
        [server setPort:[config[@"port"] intValue]];
        
        if ([server start:nil]) {
            NSLog(@"start server!%i",server.listeningPort);
        }
        
    } else {
        NSLog(@"stop server!");
        [server stop];
    }
}

@end
