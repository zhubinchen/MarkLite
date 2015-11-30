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
    NSString *key = [NSString pathWithComponents:@[[User currentUser].userId,item.path.urlEncodeString]];
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
    key = [NSString pathWithComponents:@[[User currentUser].userId,key.urlEncodeString]];
    NSString *url = [NSString stringWithFormat:@"http://7xomu7.com1.z0.glb.clouddn.com/%@",key];

    [HttpRequest downloadWithUrl:url progress:handler succese:^(NSData *response) {
        result(YES,response);
    } failed:^(ErrorCode code) {
        result(NO,nil);
    }];
}

- (void)update:(void (^)(BOOL))callBack
{
    NSString *plistPath = [[NSString documentPath] stringByAppendingPathComponent:@"root.plist"];
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    NSString *str = [QNUrlSafeBase64 encodeData:data];
    
    NSDictionary *body = @{@"userId":[User currentUser].userId,@"items":str};
    
    [HttpRequest postWithUrl:@"http://192.168.1.83/marklite/api/upload_file_list.php" Body:body Succese:^(NSData *response) {
        NSDictionary *dic = response.toDictionay;
        if (dic && [dic[@"code"] intValue] == 0) {
            callBack(YES);
        }else{
            callBack(NO);
        }
    } Failed:^(ErrorCode code) {
        callBack(NO);
    }];
}

- (void)rootFromServer:(void (^)(Item *,int))callBack
{
    [HttpRequest getWithUrl:[NSString stringWithFormat:@"http://192.168.1.83/marklite/api/upload_file_list.php?userId=%@",[User currentUser].userId] UseCache:NO Succese:^(NSData *response) {
        NSDictionary *dic = response.toDictionay;
        if (dic && [dic[@"code"] intValue] == 0) {
            NSData *data = [QNUrlSafeBase64 decodeString:dic[@"payload"]];
            Item *root = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            for (Item * i in root.items) {
                i.syncStatus = SyncStatusUnDownload;
            }
            if (root) {
                callBack(root,0);
            }
        }else if([dic[@"code"] intValue] == 1){
            callBack(nil,1);
        }else{
            callBack(nil,-1);
        }

    } Failed:^(ErrorCode code) {
        callBack(nil,-1);
    }];
}

- (void)stop
{
    stop = YES;
}

@end
