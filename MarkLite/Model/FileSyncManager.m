//
//  FileSyncManager.m
//  MarkLite
//
//  Created by zhubch on 11/26/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "FileSyncManager.h"
#import "FileManager.h"
#import "HttpRequest.h"
#import "QiniuSDK.h"
#import "User.h"

@implementation FileSyncManager
{
    QNUploadManager *upManager;
    BOOL stop;
}

+ (instancetype)sharedManager
{
    static FileSyncManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSError *error = nil;
        QNFileRecorder *fileRecorder = [QNFileRecorder fileRecorderWithFolder:[[NSString documentPath] stringByAppendingPathComponent:@"qiniu"] error:&error];
        if (error) {
            NSLog(@"%@",error);
        }

        upManager = [[QNUploadManager alloc] initWithRecorder:fileRecorder];
    }
    
    return self;
}

- (void)uploadFile:(Item *)item progressHandler:(void (^)(float))handler result:(void (^)(BOOL))result
{
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        handler(percent);
    } params:nil checkCrc:NO cancellationSignal: ^BOOL () {
        return stop;
    }];
    NSString *path = [[FileManager sharedManager] fullPathForPath:item.path];
    NSString *key = item.path;
    NSString *token = [User currentUser].token;
    [upManager putFile:path key:key token:token complete:^(QNResponseInfo *i, NSString *k, NSDictionary *resp) {
        if (i.statusCode != 200) {
            result(NO);
        }else{
            result(YES);
        }
        NSLog(@"%@",i);
    } option:opt];
}

- (void)downloadFile:(NSString *)key progressHandler:(void (^)(float))handler result:(void (^)(BOOL, NSData *))result
{
    NSString *url = [NSString stringWithFormat:@"%@",key];

    [HttpRequest downloadWithUrl:url progress:handler succese:^(NSData *response) {
        result(YES,response);
    } failed:^(ErrorCode code) {
        result(NO,nil);
    }];
}

- (void)stop
{
    stop = YES;
}

@end
