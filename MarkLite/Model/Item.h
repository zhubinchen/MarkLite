//
//  Item.h
//  MarkLite
//
//  Created by zhubch on 15-4-1.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FileTypeImage,
    FileTypeText,
    FileTypeFolder,
    FileTypeOther,
} FileType;


/**
 *  代表一个文件对象，真正的文件操作由FileManager完成
 */
@interface Item : NSObject

@property (nonatomic,strong)            NSString   *path;      //相对MarkLite目录的路径

@property (nonatomic,assign)            BOOL       open;       //目录是否展开

@property (nonatomic,weak)              Item       *parent;    //父目录

@property (nonatomic,assign)            BOOL       cloud;       //云端？

#pragma 只读属性
@property (nonatomic,assign,readonly)   NSInteger  deep;          //目录深度

@property (nonatomic,assign,readonly)   FileType   type;          //文件类型

@property (nonatomic,strong,readonly)   NSArray    *itemsCanReach; // 当前目录所有能看到的文件

@property (nonatomic,strong,readonly)   NSArray    *items;     // 当前目录所有文件

@property (nonatomic,strong,readonly)   NSString   *extention; // 扩展名

@property (nonatomic,strong,readonly)   NSString   *name;      //文件名，不含扩展名

@property (nonatomic,strong,readonly)   NSString   *fullPath;  //绝对路径


- (NSArray*)searchResult:(NSString*)searchText;

- (void)addChild:(Item*)item;

- (BOOL)isEqual:(Item*)object;

- (void)removeFromParent;

@end
