//
//  Item.h
//  MarkLite
//
//  Created by Bingcheng on 15-4-1.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileType) {
    FileTypeText,
    FileTypeFolder,
    FileTypeOther,
} ;

typedef NS_ENUM(NSUInteger, StorageType) {
    StorageTypeLocal,
    StorageTypeCloud,
    StorageTypeDropbox,
};

@interface Item : NSObject

@property (nonatomic,strong)            NSString   *name;      //文件名，不含扩展名

@property (nonatomic,assign)            BOOL        selected;    //选中

@property (nonatomic,assign)            BOOL       shouldTitle;    //选中

#pragma 只读属性

@property (nonatomic,strong,readonly)   NSString   *displayName;      //文件名，不含扩展名

@property (nonatomic,strong,readonly)   NSString   *path;      //路径

@property (nonatomic,strong,readonly)   NSString   *displayPath;  //显示路径

@property (nonatomic,assign,readonly)   NSInteger  deep;          //目录深度

@property (nonatomic,assign,readonly)   FileType   type;          //文件类型

@property (nonatomic,strong,readonly)   NSString   *extention; // 扩展名

@property (nonatomic,strong,readonly)   NSArray<Item*>    *children; // 当前目录所有能看到的文件

@property (nonatomic,strong,readonly)   NSArray<Item*>    *items;     // 当前目录所有文件

@property (nonatomic,strong,readonly)   NSDate     *modifyDate; // 修改日期

@property (nonatomic,assign,readonly)   NSUInteger  size; // 大小

+ (void)recover;

+ (instancetype)localRoot;

+ (instancetype)cloudRoot;

+ (instancetype)dropboxRoot;

- (NSArray*)searchResult:(NSString*)searchText;

- (Item*)createItem:(NSString*)name type:(FileType)type;

- (BOOL)trash;

- (BOOL)rename:(NSString*)newName;

- (BOOL)moveToParent:(Item*)newParent;

- (BOOL)save:(NSData*)content;

- (NSComparisonResult)compare:(Item*)item;

@end
