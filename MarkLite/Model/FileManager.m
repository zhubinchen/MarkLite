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
    }
    return self;
}

- (void)setRoot:(Item *)root
{
    _root = root;
    _workSpace = [NSString pathWithComponents:@[[NSString documentPath],_root.path]];
}

- (void)setWorkSpace:(NSString *)workSpace
{
    _workSpace = [NSString pathWithComponents:@[[NSString documentPath],workSpace]];
    
    if (![fm fileExistsAtPath:_workSpace]) {
        
        [fm createDirectoryAtPath:_workSpace withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"creating workSpace:%@",_workSpace);
        
        ZipArchive *zipArchive = [[ZipArchive alloc]init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Example" ofType:@"zip"];
        NSLog(@"%@",path);
        
        [zipArchive UnzipOpenFile:path];
        
        [zipArchive UnzipFileTo:_workSpace overWrite:YES];
    }
    
    
    NSEnumerator *childFilesEnumerator = [[fm subpathsAtPath:_workSpace] objectEnumerator];
    
    NSString *fileName;
    _root = [[Item alloc]init];
    _root.path = workSpace;
    _root.open = YES;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        if ([fileName hasSuffix:@".DS_Store"] || [fileName hasPrefix:@"_MACOSX"]) {
            continue;
        }
        Item *temp = [[Item alloc]init];
        temp.open = YES;
        temp.path = fileName;
        [_root addChild:temp];
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
}

- (BOOL)moveFile:(NSString *)path toNewPath:(NSString *)newPath
{
    NSError *error = nil;
    [fm moveItemAtPath:[self fullPathForPath:path] toPath:[self fullPathForPath:newPath] error:&error];

    if (error) {
        NSLog(@"%@",error);
        return NO;
    }
    return YES;
}

- (NSString *)fullPathForPath:(NSString *)path
{
    return [NSString pathWithComponents:@[_workSpace,path]];
}

@end
