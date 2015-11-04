//
//  FileManager.h
//  FileManager
//
//  Created by zhubch on 15-3-14.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileManager : NSObject

@property (nonatomic,strong) NSString *workSpace;

@property (nonatomic,strong,readonly) NSString *currentFilePath;

@property (nonatomic,strong,readonly) NSString *currentWorkSpacePath;

@property (nonatomic,strong,readonly) NSMutableArray *fileList;

+ (instancetype)sharedManager;

- (void)createFolder:(NSString*)path;

- (void)createFile:(NSString*)path Content:(NSData*)content;

- (void)deleteFile:(NSString*)path;

- (void)moveFile:(NSString*)path toNewPath:(NSString*)newPath;

- (NSData*)openFile:(NSString*)path;

@end
