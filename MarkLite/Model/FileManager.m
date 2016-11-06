//
//  FileManager.m
//  FileManager
//
//  Created by zhubch on 15-3-14.
//  Copyright (c) 2016年 zhubch. All rights reserved.
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
    
    NSMutableDictionary *attributeCache;
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
        
        [self createCloudWorkspace];
        [self createLocalWorkspace];
        attributeCache = [NSMutableDictionary dictionary];
        _local.open = YES;
        _cloud.open = YES;
    }
    return self;
}

- (void)createCloudWorkspace
{
    NSString *workspace = cloudWorkspace();
    if (![fm fileExistsAtPath:workspace]){
        NSLog(@"creating CloudWorkspace: %@",workspace);
        [fm createDirectoryAtPath:workspace withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"iCloudPath exist");
    }
    NSLog(@"cloud: %@", workspace);
    
    NSEnumerator *childFilesEnumerator = [[fm subpathsAtPath:workspace] objectEnumerator];
    
    NSString *fileName;
    _cloud = [[Item alloc]init];
    _cloud.cloud = YES;
    _cloud.path = ZHLS(@"NavTitleCloudFile");
    _cloud.open = YES;
    _cloud.root = YES;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){

        Item *temp = [[Item alloc]init];
        temp.open = NO;
        temp.cloud = YES;
        temp.path = fileName;
        
        NSError *err = nil;
        BOOL ret = [fm startDownloadingUbiquitousItemAtURL:[NSURL fileURLWithPath:temp.fullPath] error:&err];
        if (ret == NO) {
            NSLog(@"%@",err);
        }
        
        if ([fileName componentsSeparatedByString:@"."].count > 1 && ![fileName hasSuffix:@".md"]) {
            continue;
        }
        
        [_cloud addChild:temp];
    }
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

- (void)recover
{
    NSString *wokspace = localWorkspace();

    ZipArchive *zipArchive = [[ZipArchive alloc]init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MarkLite" ofType:@"zip"];
    NSLog(@"%@",path);
    
    [zipArchive UnzipOpenFile:path];
    
    [zipArchive UnzipFileTo:documentPath() overWrite:YES];
    [self deleteOtherLanguage];
    
    NSString *fileName;
    NSEnumerator *childFilesEnumerator = [[fm subpathsAtPath:wokspace] objectEnumerator];
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString *path = [wokspace stringByAppendingPathComponent:fileName];
        NSMutableDictionary *attr = [fm attributesOfItemAtPath:path error:nil].mutableCopy;
        if ([attr[NSFileModificationDate] compare:[NSDate date]] == NSOrderedDescending) {
            attr[NSFileModificationDate] = [NSDate date];
            [fm setAttributes:attr ofItemAtPath:path error:nil];
        }
        attributeCache[path] = attr;
    }
}

- (void)createLocalWorkspace
{
    NSString *wokspace = localWorkspace();
    if (![fm fileExistsAtPath:wokspace]) {
        
        [fm createDirectoryAtPath:wokspace withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"creating localWorkSpace:%@",wokspace);
        [self recover];
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
        temp.cloud = NO;
        temp.path = fileName;
        [_local addChild:temp];
    }
}

- (NSString*)createFolder:(NSString *)path
{
    NSString *truePath = [self rename:path];
    NSError *error = nil;

    [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    NSLog(@"creating dir:%@",path);
    if (error) {
        NSLog(@"%@",error);
        return nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFileChangedNotificationName object:nil];
    return truePath;
}

- (NSString*)createFile:(NSString *)path Content:(NSData *)content
{
    NSString *truePath = [self rename:path];
    BOOL ret = [fm createFileAtPath:truePath contents:content attributes:nil];
    NSLog(@"creating file:%@",path);
    if (!ret) {
        NSLog(@"failed");
        return nil;
    }
    attributeCache[path] = [fm attributesOfItemAtPath:path error:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:kFileChangedNotificationName object:nil];
    return truePath;
}

- (NSString*)newNameFromOldName:(NSString*)oldName
{
    if (oldName.length < 3) {
        return [oldName stringByAppendingString:@"(1)"];
    }
    NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:@"\\([0-9]+\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRange range = [rex rangeOfFirstMatchInString:oldName options:NSMatchingReportCompletion range:NSMakeRange(0, oldName.length)];
    if (range.location == NSNotFound) {
        return [oldName stringByAppendingString:@"(1)"];
    }
    int num = [oldName substringWithRange:NSMakeRange(range.location + 1, range.length - 2)].intValue;
    NSString *numStr = [NSString stringWithFormat:@"(%d)",++num];
    return [oldName stringByReplacingCharactersInRange:range withString:numStr];;
}

- (NSString*)rename:(NSString*)name
{
    NSArray *arr = [name componentsSeparatedByString:@"."];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:name];
    if (exist) {
        NSLog(@"已经存在");
        NSString *newName;
        if (arr.count > 1) {
            newName = [[self newNameFromOldName:arr[0]] stringByAppendingPathExtension:arr[1]];
        }else{
            newName = [self newNameFromOldName:name];
        }
        return [self rename:newName];
    }
    return name;
}

- (BOOL)saveFile:(NSString *)path Content:(NSData *)content
{
    if (![fm fileExistsAtPath:path]) {
        return NO;
    }
    
    BOOL ret = [content writeToFile:path atomically:YES];
    attributeCache[path] = [fm attributesOfItemAtPath:path error:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:kFileChangedNotificationName object:nil];
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
    [attributeCache removeObjectForKey:path];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFileChangedNotificationName object:nil];

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
    [attributeCache removeObjectForKey:path];
    attributeCache[path] = [fm attributesOfItemAtPath:path error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFileChangedNotificationName object:nil];
    return YES;
}

- (NSDictionary *)attributeOfPath:(NSString *)path
{
    if (attributeCache[path] == nil) {
        attributeCache[path] = [fm attributesOfItemAtPath:path error:nil];
    }
    return attributeCache[path];
}

@end
