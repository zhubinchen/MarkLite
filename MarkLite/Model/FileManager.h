//
//  FileManager.h
//  FileManager
//
//  Created by zhubch on 15-3-14.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface FileManager : NSObject

@property (nonatomic,strong) NSString *workSpace;

@property (nonatomic,strong) Item *root;

@property (nonatomic,strong) Item *currentItem;

+ (instancetype)sharedManager;

- (void)createFolder:(NSString*)path;

- (void)createFile:(NSString*)path Content:(NSData*)content;

- (void)deleteFile:(NSString*)path;

- (BOOL)moveFile:(NSString*)path toNewPath:(NSString*)newPath;

- (NSString *)fullPathForPath:(NSString *)path;

@end
