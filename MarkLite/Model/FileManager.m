//
//  FileManager.m
//  FileManager
//
//  Created by zhubch on 15-3-14.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "FileManager.h"
#import "ZipArchive.h"

@implementation FileManager
{
    NSFileManager *fm;
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
        _fileList = [NSMutableArray array];
    }
    return self;
}

- (void)setWorkSpace:(NSString *)workSpace
{
    _workSpace = workSpace;
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _currentWorkSpacePath = [NSString pathWithComponents:@[docPath,workSpace]];
    NSLog(@"%@",_currentWorkSpacePath);

    if (![fm fileExistsAtPath:_currentWorkSpacePath]) {
        
        [fm createDirectoryAtPath:_currentWorkSpacePath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"creating workSpace:%@",_currentWorkSpacePath);
        
        ZipArchive *zipArchive = [[ZipArchive alloc]init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"zip"];
        NSLog(@"%@",path);
        
        [zipArchive UnzipOpenFile:path];
        
        [zipArchive UnzipFileTo:_currentWorkSpacePath overWrite:YES];
    }
    
    
    NSEnumerator *childFilesEnumerator = [[fm subpathsAtPath:_currentWorkSpacePath] objectEnumerator];
    
    NSString *fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        if ([fileName hasSuffix:@".DS_Store"] || [fileName hasPrefix:@"_MACOSX"]) {
            continue;
        }
        [_fileList addObject:fileName];
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
    NSAssert(!error, error.description);
}

- (void)createFile:(NSString *)path Content:(NSData *)content
{
    NSString* fullPath = [self fullPathForPath:path];

    if (![fm fileExistsAtPath:fullPath]) {
        [fm createFileAtPath:fullPath contents:content attributes:nil];
        NSLog(@"creating file:%@",fullPath);
    }
}

- (void)deleteFile:(NSString *)path
{
    NSError *error = nil;

    [fm removeItemAtPath:[self fullPathForPath:path] error:&error];
    NSAssert(!error, error.description);
}

- (void)moveFile:(NSString *)path toNewPath:(NSString *)newPath
{
    NSError *error = nil;
    [fm moveItemAtPath:path toPath:newPath error:&error];
    NSAssert(!error, error.description);
}

- (NSData*)openFile:(NSString *)path
{
    path = [self fullPathForPath:path];
    _currentFilePath = path;
    return [fm contentsAtPath:path];
}

- (NSString *)fullPathForPath:(NSString *)path
{
    return [NSString pathWithComponents:@[_currentWorkSpacePath,path]];
}

@end
