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

@property (nonatomic,strong) NSString *workSpace;//设置了workspace就会加载root

@property (nonatomic,strong) Item *root; //跟workSpace属性互相影响，设置了root，就会用root的path给workspace赋值

@property (nonatomic,strong) Item *currentItem; //用来共享同一对象

+ (instancetype)sharedManager;

- (void)createFolder:(NSString*)path;

- (void)createFile:(NSString*)path Content:(NSData*)content;

- (void)deleteFile:(NSString*)path;

- (BOOL)moveFile:(NSString*)path toNewPath:(NSString*)newPath;

- (NSString *)fullPathForPath:(NSString *)path;

@end
