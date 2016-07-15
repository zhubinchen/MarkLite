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

@implementation FileManager
{
    NSFileManager *fm;
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
        
        [self createLocalWorkspace];
        _local.open = YES;
    }
    return self;
}

- (void)deleteOtherLanguage
{
    NSArray *arr = @[@"Guides",@"使用指南",@"使用說明"];
    
    for (NSString *name in arr) {
        if (![name isEqualToString:ZHLS(@"GuidesName")]) {
            [self deleteFile:[localWorkspace() stringByAppendingPathComponent:name]];
        }
    }
}

- (void)createLocalWorkspace
{
    NSString *wokspace = localWorkspace();
    if (![fm fileExistsAtPath:wokspace]) {
        
        [fm createDirectoryAtPath:wokspace withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"creating localWorkSpace:%@",wokspace);
        ZipArchive *zipArchive = [[ZipArchive alloc]init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MarkLite" ofType:@"zip"];
        NSLog(@"%@",path);
        
        [zipArchive UnzipOpenFile:path];
        
        [zipArchive UnzipFileTo:documentPath() overWrite:YES];
        [self deleteOtherLanguage];
    }
    NSLog(@"localWorkSpace:%@",wokspace);
    
    NSEnumerator *childFilesEnumerator = [[fm subpathsAtPath:wokspace] objectEnumerator];
    
    NSString *fileName;
    _local = [[Item alloc]init];
    _local.path = ZHLS(@"NavTitleLocalFile");
    _local.open = YES;
    _local.root = YES;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        if ([fileName componentsSeparatedByString:@"."].count > 1 && ![fileName hasSuffix:@".md"]) {
            continue;
        }
        Item *temp = [[Item alloc]init];
        temp.open = NO;
        temp.path = fileName;
        [_local addChild:temp];
        
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
