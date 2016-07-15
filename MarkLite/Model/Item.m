//
//  Item.m
//  MarkLite
//
//  Created by zhubch on 15-4-1.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "Item.h"
#import "PathUtils.h"

@interface Item()

@property (nonatomic,strong)  NSMutableArray     *children;

@end

@implementation Item
{
    Item *last;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.children = [NSMutableArray array];
        _type = FileTypeOther;
        _open = NO;
    }
    return self;
}

- (NSArray *)items
{
    NSMutableArray *ret = [NSMutableArray array];
    
    for (Item *i in self.children) {
        [ret addObject:i];
        [ret addObjectsFromArray:i.items];
    }
    
    return ret;
}

- (NSArray*)itemsCanReach
{
    NSMutableArray *ret = [NSMutableArray array];
    
    if (self.open) {
        for (Item *i in self.children) {
            [ret addObject:i];
            [ret addObjectsFromArray:i.itemsCanReach];
        }
    }
    
    return ret;
}

- (NSArray *)searchResult:(NSString *)searchText
{
    self.open = YES;
    NSMutableArray *ret = [NSMutableArray array];

    for (Item *i in self.children) {
        NSArray *array = [i searchResult:searchText];
        NSString *path = [i.path componentsSeparatedByString:@"/"].lastObject;
        if (array.count || [path containsString:searchText]) {
            [ret addObject:i];
        }
        if (array.count) {
            [ret addObjectsFromArray:[i searchResult:searchText]];
        }
    }

    return ret;
}

- (void)setParent:(Item *)parent
{
    if (parent == nil) {
        return;
    }
    _parent = parent;
    _deep = self.parent.deep + 1;
}

- (void)setPath:(NSString *)path
{
    _path = path;

    NSArray *arr = [path componentsSeparatedByString:@"."];
    if (arr.count > 1) {
        NSString *ex = arr.lastObject;
        _type = FileTypeText;
        _extention = ex;
    }else{
        _type = FileTypeFolder;
        _extention = @"";
    }
    _name = [[path componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
}

- (void)addChild:(Item *)item
{
    if (last != nil && [item.path hasPrefix:last.path]) {
        [last addChild:item];
        return;
    }
    
    item.parent = self;
    [self.children addObject:item];
    last = item;
}

- (void)removeFromParent
{
    [_parent.children removeObject:self];
}

- (BOOL)isEqual:(Item *)object
{
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    return [self.fullPath isEqualToString:object.fullPath];
}

- (NSString *)fullPath
{
    
    return _root ? localWorkspace() :[localWorkspace() stringByAppendingPathComponent:_path];
}

- (NSString *)localPath:(NSString *)path
{
    return [NSString pathWithComponents:@[documentPath(),@"MarkLite",path]];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%@",self.path,self.children];
}

@end
