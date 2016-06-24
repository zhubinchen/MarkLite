//
//  FileManager.m
//  FileManager
//
//  Created by zhubch on 15-3-14.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "FileManager.h"
#import "ZipArchive.h"
#import "CloudManager.h"

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
        NSString *plistPath = [documentPath() stringByAppendingPathComponent:@"root.plist"];
        _workSpace = [NSString pathWithComponents:@[documentPath(),@"MarkLite"]];

        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            _root = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[[CloudManager alloc]init] uploadFile:plistPath];
            });
        }else{
            [self createWorkspace];
            [_root archive];
        }
    }
    return self;
}

- (void)createWorkspace
{
    if (![fm fileExistsAtPath:_workSpace]) {
        
        [fm createDirectoryAtPath:_workSpace withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"creating workSpace:%@",_workSpace);
        ZipArchive *zipArchive = [[ZipArchive alloc]init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MarkLite" ofType:@"zip"];
        NSLog(@"%@",path);
        
        [zipArchive UnzipOpenFile:path];
        
        [zipArchive UnzipFileTo:documentPath() overWrite:YES];

        [self notify];
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
        temp.path = fileName;
        [_root addChild:temp];
        
        if (temp.type == FileTypeText) {
            NSMutableDictionary *attr = [fm attributesOfItemAtPath:[self fullPathForPath:fileName] error:nil].mutableCopy;
            attr[NSFileCreationDate] = [NSDate date];
            attr[NSFileModificationDate] = [NSDate date];
            [fm setAttributes:attr ofItemAtPath:[self fullPathForPath:fileName] error:nil];
        }
    }
}

- (void)createFolder:(NSString *)path
{
    NSError *error = nil;
    NSString* fullPath = [self fullPathForPath:path];
    if (![fm fileExistsAtPath:fullPath]) {
        [fm createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"creating dir:%@",fullPath);
    }
    if (error) {
        NSLog(@"%@",error);
    }else{
        [self notify];
    }
}

- (BOOL)createFile:(NSString *)path Content:(NSData *)content
{
    NSString* fullPath = [self fullPathForPath:path];

    if (![fm fileExistsAtPath:fullPath]) {
        BOOL ret = [fm createFileAtPath:fullPath contents:content attributes:nil];
        NSLog(@"creating file:%@",fullPath);
        if (ret) {
            [self notify];
        }
        return ret;
    }
    return NO;
}

- (void)deleteFile:(NSString *)path
{
    NSError *error = nil;

    [fm removeItemAtPath:[self fullPathForPath:path] error:&error];
    if (error) {
        NSLog(@"%@",error);
    }else{
        [self notify];
    }
}

- (BOOL)moveFile:(NSString *)path toNewPath:(NSString *)newPath
{
    NSError *error = nil;
    if (![fm fileExistsAtPath:[self fullPathForPath:newPath]]) {
        BOOL ret = [fm moveItemAtPath:[self fullPathForPath:path] toPath:[self fullPathForPath:newPath] error:&error];
        if (ret) {
            [self notify];
        }
        return ret;
    }
    return NO;
}

- (NSString *)fullPathForPath:(NSString *)path
{
    
    if ([path containsString:@"var/mobile/Containers"]) {
        return path;
    }
    return [NSString pathWithComponents:@[_workSpace,path]];
}

- (NSDictionary *)attributeOfItem:(Item *)item
{
    return [fm attributesOfItemAtPath:[self fullPathForPath:item.path] error:nil];
}

- (void)notify
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ItemsChangedNotification" object:_root];
    });
}

@end
