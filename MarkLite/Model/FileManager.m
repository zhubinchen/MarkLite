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

#define UBIQUITY_CONTAINER_URL @"iCloud.com.zhubch.MarkLite"

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
        NSString *plistPath = [documentPath() stringByAppendingPathComponent:@"root.plist"];
        _workSpace = [NSString pathWithComponents:@[documentPath(),@"MarkLite"]];

        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            _root = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
        }else{
//            [self createCloudspace];
            [self createWorkspace];
            [_root archive];
        }
        _root.open = YES;
 
        [[Configure sharedConfigure] addObserver:self forKeyPath:@"cloud" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"cloud"]) {
        [self createCloudspace];
    }
}

- (void)createCloudspace
{
    if (![Configure sharedConfigure].cloud) {
        _iCloudSpace = nil;
        return;
    }
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
        [self download];
    }
    NSLog(@"iCloudPath: %@", _iCloudSpace);
}

- (void)upload
{
    for (Item *i in _root.itemsCanReach) {
        NSError *err = nil;
        if ([fm fileExistsAtPath:[self remotePath:i.path]]) {
            continue;
        }
        NSURL *localUrl = [NSURL fileURLWithPath:[self localPath:i.path]];
        NSURL *remoteUrl = [NSURL fileURLWithPath:[self remotePath:i.path]];
        [fm copyItemAtURL:localUrl toURL:remoteUrl error:&err];
        NSLog(@"%@",err);
    }
}

- (void)download
{

    
    NSError *err = nil;
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_iCloudSpace error:&err];
    if (err) {
        NSLog(@"%@",err);
        return;
    }

    for (NSString *path in arr) {
        if (![fm fileExistsAtPath:_workSpace]) {
            [fm createDirectoryAtPath:_workSpace withIntermediateDirectories:YES attributes:nil error:nil];
            NSLog(@"creating workSpace:%@",_workSpace);
        }
        NSURL *localUrl = [NSURL fileURLWithPath:[self localPath:path]];
        NSURL *remoteUrl = [NSURL fileURLWithPath:[self remotePath:path]];
        [fm copyItemAtURL:remoteUrl toURL:localUrl error:&err];

        if (err) {
            NSLog(@"%@",err);
            return;
        }
    }

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
            NSMutableDictionary *attr = [fm attributesOfItemAtPath:[self localPath:fileName] error:nil].mutableCopy;
            attr[NSFileCreationDate] = [NSDate date];
            attr[NSFileModificationDate] = [NSDate date];
            [fm setAttributes:attr ofItemAtPath:[self localPath:fileName] error:nil];
        }
    }
//    [self upload];
}

- (void)createFolder:(NSString *)path
{
    NSError *error = nil;
    NSString* localPath = [self localPath:path];
    NSString* remotePath = [self remotePath:path];
    if (![fm fileExistsAtPath:localPath]) {
        [fm createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"creating dir:%@",localPath);
        if (error) {
            NSLog(@"%@",error);
        }else{
            [self notify];
        }
    }
    
    if (_iCloudSpace) {
        if (![fm fileExistsAtPath:remotePath]) {
            [fm createDirectoryAtPath:remotePath withIntermediateDirectories:YES attributes:nil error:&error];
            NSLog(@"creating dir:%@",remotePath);
            if (error) {
                NSLog(@"%@",error);
            }
        }
    }

}

- (BOOL)createFile:(NSString *)path Content:(NSData *)content
{
    NSString* localPath = [self localPath:path];
    NSString* remotePath = [self remotePath:path];
    
    if ([fm fileExistsAtPath:localPath]) {
        return NO;
    }
    BOOL ret = [fm createFileAtPath:localPath contents:content attributes:nil];
    NSLog(@"creating file:%@",localPath);
    if (ret) {
        [self notify];
    }else{
        return NO;
    }
    
    if (_iCloudSpace) {
        if (![fm fileExistsAtPath:remotePath]) {
            [fm createFileAtPath:remotePath contents:content attributes:nil];
            NSLog(@"creating file:%@",remotePath);
        }
    }

    return YES;
}

- (BOOL)saveFile:(NSString *)path Content:(NSData *)content
{
    NSString* localPath = [self localPath:path];
    NSString* remotePath = [self remotePath:path];
    
    if (![fm fileExistsAtPath:localPath]) {
        return NO;
    }
    BOOL ret = [content writeToFile:localPath atomically:YES];
    if (!ret) {
        return NO;
    }
    if (_iCloudSpace) {
        if (![fm fileExistsAtPath:remotePath]) {
            [fm createFileAtPath:remotePath contents:content attributes:nil];
        }
        ret = [content writeToFile:remotePath atomically:YES];
    }

    return YES;
}

- (BOOL)deleteFile:(NSString *)path
{
    NSError *error = nil;

    NSString* localPath = [self localPath:path];
    NSString* remotePath = [self remotePath:path];
    
    if (![fm fileExistsAtPath:localPath]) {
        return NO;
    }

    [fm removeItemAtPath:localPath error:&error];
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }else{
        [self notify];
    }
    if (_iCloudSpace) {
        [fm removeItemAtPath:remotePath error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }

    return YES;
}

- (BOOL)moveFile:(NSString *)path toNewPath:(NSString *)newPath
{
    NSError *error = nil;
    NSString* localPath = [self localPath:path];
    NSString* remotePath = [self remotePath:path];
    NSString* newLocalPath = [self localPath:newPath];
    NSString* newremotePath = [self remotePath:newPath];

    if (![fm fileExistsAtPath:localPath]) {
        return NO;
    }
    if ([fm fileExistsAtPath:newLocalPath]) {
        return NO;
    }
    BOOL ret = [fm moveItemAtPath:localPath toPath:newLocalPath error:&error];
    if (ret) {
        [self notify];
    }else{
        NSLog(@"%@",error);
        return NO;
    }
    if (_iCloudSpace) {
        [fm moveItemAtPath:remotePath toPath:newremotePath error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }
    
    return YES;
}

- (NSString *)localPath:(NSString *)path
{
    return [NSString pathWithComponents:@[_workSpace,path]];
}

- (NSString*)remotePath:(NSString*)path
{
    if (_iCloudSpace == nil) {
        return @"";
    }
    return [NSString pathWithComponents:@[_iCloudSpace,path]];
}

- (NSDictionary *)attributeOfPath:(NSString *)path
{
    return [fm attributesOfItemAtPath:[self localPath:path] error:nil];
}

- (void)notify
{
    [_root archive];
}

@end
