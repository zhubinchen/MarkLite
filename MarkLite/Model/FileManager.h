//
//  FileManager.h
//  FileManager
//
//  Created by zhubch on 15-3-14.
//  Copyright (c) 2016年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

static const NSNotificationName kFileChangedNotificationName = @"FileChangedNotificationName";

@interface FileManager : NSObject

@property (nonatomic,strong,readonly) Item *local;

@property (nonatomic,strong,readonly) Item *cloud;

@property (nonatomic,strong) Item *currentItem; //用来共享同一对象

+ (instancetype)sharedManager;

- (void)createLocalWorkspace;

- (void)createCloudWorkspace;

- (void)recover;

#pragma 以下出现的所有path均为绝路径

- (NSString*)createFolder:(NSString*)path;

- (NSString*)createFile:(NSString*)path Content:(NSData*)content;

- (BOOL)saveFile:(NSString*)path Content:(NSData*)content;

- (BOOL)deleteFile:(NSString*)path;

- (BOOL)moveFile:(NSString*)path toNewPath:(NSString*)newPath;

- (NSDictionary*)attributeOfPath:(NSString*)path;

@end
