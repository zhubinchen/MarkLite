//
//  Item.m
//  HtmlPlus
//
//  Created by zhubch on 15-4-1.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "Item.h"

@implementation Item
{
    Item *last;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.children = [NSMutableArray array];
        _type = FileTypeOther;
    }
    return self;
}

- (NSArray *)items
{
    NSMutableArray *ret = [NSMutableArray array];
    
    for (Item *i in self.children) {
        [ret addObject:i];
        [ret addObjectsFromArray:i.itemsCanReach];
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
        if ([ex isEqualToString:@"png"] || [ex isEqualToString:@"jpeg"] || [ex isEqualToString:@"jpg"] || [ex isEqualToString:@"gif"]) {
            _type = FileTypeImage;
        }else{
            _type = FileTypeText;
        }
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
    _parent = nil;
}

- (BOOL)isEqual:(Item *)object
{
    return [self.path isEqualToString:object.path];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%@",self.path,self.children];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.children forKey:@"children"];
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeInteger:self.tag forKey:@"tag"];
    [aCoder encodeObject:self.parent forKey:@"parent"];
    [aCoder encodeObject:self.createTime forKey:@"createTime"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.path = [aDecoder decodeObjectForKey:@"path"];
        self.createTime = [aDecoder decodeObjectForKey:@"createTime"];
        self.parent = [aDecoder decodeObjectForKey:@"parent"];
        self.tag = [aDecoder decodeIntegerForKey:@"tag"];
        self.children=[[aDecoder decodeObjectForKey:@"children"] mutableCopy];
        if (self.children == nil) {
            self.children = [NSMutableArray array];
        }
        _open = YES;
    }
    return self;
}

- (BOOL)archive
{
    NSString *path = [[NSString documentPath] stringByAppendingPathComponent:@"root.plist"];
    
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (NSComparisonResult)compare:(Item*)other
{
    return [_createTime compare:other.createTime];
}

@end
