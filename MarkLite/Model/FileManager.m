//
//  FileManager.m
//  FileManager
//
//  Created by zhubch on 15-3-14.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "FileManager.h"
#import "ZipArchive.h"
#import "Configure.h"
#import "PathUtils.h"

//#define UBIQUITY_CONTAINER_URL @"iCloud.com.zhubch.MarkLite"

@implementation FileManager
{
    NSFileManager *fm;
    NSURL *ubiquityURL;
}

+ (void)initialize
{
    [self sharedManager];
}

+ (instancetype)sharedManager
{
    static FileManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[FileManager alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        fm = [NSFileManager defaultManager];
        _workSpace = [NSString pathWithComponents:@[documentPath(),@"MarkLite"]];

        [self createCloudWorkspace];
        [self createLocalWorkspace];
        _root.open = YES;
 
    }
    return self;
}

- (void)createCloudWorkspace
{
    ubiquityURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
    if (!ubiquityURL) {
        return ;
    }
    
    _iCloudSpace = [ubiquityURL path];
    
    if (![fm fileExistsAtPath:_iCloudSpace]){
        NSLog(@"create iCloudPath");
        [fm createDirectoryAtPath:_iCloudSpace withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"iCloudPath exist");
    }
    NSLog(@"iCloudPath: %@", _iCloudSpace);
}

//- (void)upload
//{
//    for (Item *i in _root.itemsCanReach) {
//        NSError *err = nil;
//        if ([fm fileExistsAtPath:[self remotePath:i.path]]) {
//            continue;
//        }
//        NSURL *localUrl = [NSURL fileURLWithPath:[self localPath:i.path]];
//        NSURL *remoteUrl = [NSURL fileURLWithPath:[self remotePath:i.path]];
//        [fm copyItemAtURL:localUrl toURL:remoteUrl error:&err];
//        NSLog(@"%@",err);
//    }
//}
//
//- (void)download
//{
//    NSError *err = nil;
//    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_iCloudSpace error:&err];
//    if (err) {
//        NSLog(@"%@",err);
//        return;
//    }
//
//    for (NSString *path in arr) {
//        if (![fm fileExistsAtPath:_workSpace]) {
//            [fm createDirectoryAtPath:_workSpace withIntermediateDirectories:YES attributes:nil error:nil];
//            NSLog(@"creating workSpace:%@",_workSpace);
//        }
//        NSURL *localUrl = [NSURL fileURLWithPath:[self localPath:path]];
//        NSURL *remoteUrl = [NSURL fileURLWithPath:[self remotePath:path]];
//        [fm copyItemAtURL:remoteUrl toURL:localUrl error:&err];
//
//        if (err) {
//            NSLog(@"%@",err);
//            return;
//        }
//    }
//
//}

- (void)createLocalWorkspace
{
    if (![fm fileExistsAtPath:_workSpace]) {
        
        [fm createDirectoryAtPath:_workSpace withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"creating workSpace:%@",_workSpace);
        ZipArchive *zipArchive = [[ZipArchive alloc]init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MarkLite" ofType:@"zip"];
        NSLog(@"%@",path);
        
        [zipArchive UnzipOpenFile:path];
        
        [zipArchive UnzipFileTo:documentPath() overWrite:YES];

        NSLog(@"success%@",path);
    }
    
    
    NSEnumerator *childFilesEnumerator = [[fm subpathsAtPath:_workSpace] objectEnumerator];
    
    NSString *fileName;
    _root = [[Item alloc]init];
    _root.path = @"MarkLite";
    _root.open = YES;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        if ([fileName hasSuffix:@".DS_Store"] || [fileName hasPrefix:@"__MACOSX"]) {
            continue;
        }
        Item *temp = [[Item alloc]init];
        temp.open = YES;
        temp.cloud = NO;
        temp.path = fileName;
        [_root addChild:temp];
        
        if (temp.type == FileTypeText) {
            NSMutableDictionary *attr = [fm attributesOfItemAtPath:temp.fullPath error:nil].mutableCopy;
            attr[NSFileCreationDate] = [NSDate date];
            attr[NSFileModificationDate] = [NSDate date];
            [fm setAttributes:attr ofItemAtPath:temp.fullPath error:nil];
        }
    }
}

- (BOOL)createFolder:(NSString *)path
{
    NSError *error = nil;
    if ([fm fileExistsAtPath:path]) {
        return NO;
    }
    [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    NSLog(@"creating dir:%@",path);
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }
    return YES;
}

- (BOOL)createFile:(NSString *)path Content:(NSData *)content
{
    if ([fm fileExistsAtPath:path]) {
        return NO;
    }
    BOOL ret = [fm createFileAtPath:path contents:content attributes:nil];
    NSLog(@"creating file:%@",path);
    if (!ret) {
        NSLog(@"failed");
        return NO;
    }
    return YES;
}

- (BOOL)saveFile:(NSString *)path Content:(NSData *)content
{
    if (![fm fileExistsAtPath:path]) {
        return NO;
    }
    BOOL ret = [content writeToFile:path atomically:YES];

    return ret;
}

- (BOOL)deleteFile:(NSString *)path
{
    NSError *error = nil;
    
    if (![fm fileExistsAtPath:path]) {
        return NO;
    }

    [fm removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }

    return YES;
}

- (BOOL)moveFile:(NSString *)path toNewPath:(NSString *)newPath
{
    NSError *error = nil;

    if (![fm fileExistsAtPath:path]) {
        return NO;
    }
    if ([fm fileExistsAtPath:newPath]) {
        return NO;
    }
    BOOL ret = [fm moveItemAtPath:path toPath:newPath error:&error];
    
    if (!ret) {
        NSLog(@"%@",error);
        return NO;
    }
    return YES;
}

- (NSDictionary *)attributeOfPath:(NSString *)path
{
    return [fm attributesOfItemAtPath:path error:nil];
}

@end
