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

@property (nonatomic,strong,readonly) NSString *workSpace;

@property (nonatomic,strong,readonly) NSString *iCloudSpace;

@property (nonatomic,strong,readonly) Item *root;

@property (nonatomic,strong) Item *currentItem; //用来共享同一对象

+ (instancetype)sharedManager;


#pragma 以下出现的所有path均为相对workspace的路径

- (void)createFolder:(NSString*)path;

- (BOOL)createFile:(NSString*)path Content:(NSData*)content;

- (BOOL)saveFile:(NSString*)path Content:(NSData*)content;

- (BOOL)deleteFile:(NSString*)path;

- (BOOL)moveFile:(NSString*)path toNewPath:(NSString*)newPath;

- (NSString *)localPath:(NSString *)path;

- (NSDictionary*)attributeOfPath:(NSString*)path;

@end
