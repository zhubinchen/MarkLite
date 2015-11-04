//
//  Item.h
//  HtmlPlus
//
//  Created by zhubch on 15-4-1.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic,strong)            NSString *name;

@property (nonatomic,assign,readonly)   BOOL      folder;

@property (nonatomic,assign)            BOOL      open;

@property (nonatomic,weak)              Item     *parent;

@property (nonatomic,assign,readonly)   NSInteger  deep;

@property (nonatomic,strong)            NSMutableArray     *children;

@property (nonatomic,strong,readonly)   NSArray   *itemsCanReach;

- (void)addChild:(Item*)item;

- (BOOL)isEqual:(Item*)object;

- (void)removeFromParent;

@end
