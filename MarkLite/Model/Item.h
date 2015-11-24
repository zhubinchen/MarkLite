//
//  Item.h
//  HtmlPlus
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

@interface Item : NSObject

@property (nonatomic,strong)            NSString  *path;

@property (nonatomic,strong)            NSDate  *createTime;

@property (nonatomic,assign)            BOOL      open;

@property (nonatomic,assign)            NSInteger tag;

@property (nonatomic,strong)            NSMutableArray     *children;

@property (nonatomic,weak)              Item      *parent;

@property (nonatomic,assign,readonly)   NSInteger deep;

@property (nonatomic,assign,readonly)   FileType  type;

@property (nonatomic,strong,readonly)   NSArray   *itemsCanReach;

@property (nonatomic,strong,readonly)   NSArray   *items;

@property (nonatomic,strong,readonly)   NSString  *extention;

@property (nonatomic,strong,readonly)   NSString  *name;

- (NSArray*)searchResult:(NSString*)searchText;

- (void)addChild:(Item*)item;

- (BOOL)isEqual:(Item*)object;

- (void)removeFromParent;

- (BOOL)archive;

@end
