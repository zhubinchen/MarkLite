//
//  Item.m
//  MarkLite
//
//  Created by Bingcheng on 15-4-1.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import "Item.h"
#import "PathUtils.h"
#import "Configure.h"
#import <SSZipArchive/SSZipArchive.h>

@interface Item()

@property (nonatomic,strong)  NSMutableArray     *childrenBackup;

@property (nonatomic,weak)    Item               *parent;    //父目录

@end

@implementation Item
{
    Item *last;
    NSFileManager *fm;
}

@synthesize path  = _path;
@synthesize displayPath  = _displayPath;

+ (void)load
{
    //[self recover];
}

+ (void)recover
{
    [self recoverFile];
    [self recoverStyleResource];
}

+ (void)recoverFile{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MarkLite" ofType:@"zip"];
    NSLog(@"%@",path);
    
    [SSZipArchive unzipFileAtPath:path toDestination:documentPath()];
    NSArray *arr = @[@"Instructions",@"使用指南",@"使用說明"];
    
    for (NSString *name in arr) {
        if (![name isEqualToString:ZHLS(@"GuidesName")]) {
            [[NSFileManager defaultManager] removeItemAtPath:[localWorkspace() stringByAppendingPathComponent:name] error:nil];
        }
    }
}

+ (void)recoverStyleResource{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"StyleResource" ofType:@"zip"];
    NSLog(@"%@",path);
    
    [SSZipArchive unzipFileAtPath:path toDestination:documentPath()];
}

+ (instancetype)localRoot
{
    static Item *root = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        root = [[self alloc]initWithStorageType:StorageTypeLocal];
    });
    return root;
}

+ (instancetype)cloudRoot
{
    static Item *root = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        root = [[self alloc]initWithStorageType:StorageTypeCloud];
    });
    return root;
}

+ (instancetype)dropboxRoot
{
    static Item *root = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        root = [[self alloc]initWithStorageType:StorageTypeDropbox];
    });
    return root;
}

- (instancetype)init
{
    if (self = [super init]) {
        _childrenBackup = [NSMutableArray array];
        fm = [NSFileManager defaultManager];
    }
    return self;
}

- (instancetype)initWithStorageType:(StorageType)storageType
{
    NSArray *allWorkspaces = @[localWorkspace(),cloudWorkspace(),dropboxWorkspace()];
    NSArray *displayName = @[@"NavTitleLocalFile",@"NavTitleCloudFile",@"NavTitleDropbox"];

    if (self = [self init]) {
        _path = allWorkspaces[storageType];
        _displayPath = ZHLS(displayName[storageType]);
        _name = _displayPath;
        [self setupWorkspace:_path];
    }
    return self;
}

- (void)setupWorkspace:(NSString*)workspace
{
    if (![fm fileExistsAtPath:workspace]){
        NSLog(@"creating workspace: %@",workspace);
        [fm createDirectoryAtPath:workspace withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"%@ exist",workspace);
    }
    
    NSEnumerator *childFilesEnumerator = [[fm subpathsAtPath:workspace] objectEnumerator];
    
    NSString *fileName;

    while ((fileName = [childFilesEnumerator nextObject])){
        
        if ([fileName componentsSeparatedByString:@"."].count > 1 && ![fileName hasSuffix:@".md"]) {
            continue;
        }

        Item *item = [[Item alloc]init];
        item.name = fileName;
        [self addChild:item];
        
        NSDictionary *attr = [fm attributesOfItemAtPath:item.path error:nil];
        NSDate *date = attr[NSFileModificationDate] ? attr[NSFileModificationDate] : [NSDate date];
        NSUInteger size = attr[NSFileSize] ? [attr[NSFileSize] integerValue] : 0;
        [item setAttrWithDate:date size:size];
        
        NSError *err = nil;
        BOOL ret = [fm startDownloadingUbiquitousItemAtURL:[NSURL fileURLWithPath:item.path] error:&err];
        if (ret == NO) {
            NSLog(@"%@",err);
        }
    }
}

#pragma mark 私有方法
- (void)addChild:(Item*)item
{
    if (last != nil && [item.name hasPrefix:[last.name stringByAppendingString:@"/"]]) {
        item.name = [item.name stringByReplacingOccurrencesOfString:[last.name stringByAppendingString:@"/"] withString:@""];
        [last addChild:item];
        return;
    }
    last = item;
    item.parent = self;
    [self.childrenBackup addObject:item];
}

- (void)setAttrWithDate:(NSDate*)date size:(NSUInteger)size
{
    _modifyDate = date;
    _size = size;
}

#pragma mark 只读属性
- (NSArray *)items
{
    NSMutableArray *ret = [NSMutableArray array];
    
    for (Item *i in self.childrenBackup) {
        [ret addObject:i];
        [ret addObjectsFromArray:i.items];
    }
    
    return ret;
}

- (NSArray*)children
{
    return [self.childrenBackup sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)searchResult:(NSString *)searchText
{
    NSMutableArray *ret = [NSMutableArray array];

    for (Item *i in self.childrenBackup) {
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

- (NSString *)path
{
    if (self.parent) {
        return [_parent.path stringByAppendingPathComponent:self.name];
    }
    return _path;
}

- (NSString *)displayPath
{
    if (self.parent) {
        return [_parent.displayPath stringByAppendingPathComponent:self.name];
    }
    return _displayPath;
}

- (NSString *)displayName
{
    if ([self.name containsString:@".md"]) {
        
    }
    return [self.name stringByDeletingPathExtension];
}

- (NSInteger)deep
{
    if (self.parent) {
        return _parent.deep + 1;
    }
    return 0;
}

- (FileType)type
{
    if ([[self.name componentsSeparatedByString:@"."] count] > 1) {
        return FileTypeText;
    }
    return FileTypeFolder;
}

- (NSString *)extention
{
    if ([[self.name componentsSeparatedByString:@"."] count] > 1) {
        return [[self.name componentsSeparatedByString:@"."] lastObject];
    }
    return @"";
}

#pragma mark 文件操作
- (Item *)createItem:(NSString *)name type:(FileType)type
{
    if (type == FileTypeText && ![name hasSuffix:@".md"]) {
        name = [name stringByAppendingString:@".md"];
    }
    Item *i = [[Item alloc]init];
    i.name = name;
    i.parent = self;
    [i setAttrWithDate:[NSDate date] size:0];
    [self.childrenBackup addObject:i];
    
    NSString *path = validPath(i.path);
    i.name = [path componentsSeparatedByString:@"/"].lastObject;
    NSLog(@"create file %@",path);
    if (type == FileTypeText) {
        BOOL ret = [fm createFileAtPath:path contents:nil attributes:nil];
        if (ret == NO) {
            [self.childrenBackup removeObject:i];
            return nil;
        }
    }else{
        NSError *error = nil;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [self.childrenBackup removeObject:i];
            return nil;
        }
    }

    return i;
}

- (BOOL)trash
{
    NSError *error = nil;
    
    NSLog(@"trash %@",self.path);
    if (![fm fileExistsAtPath:self.path]) {
        [self.parent.childrenBackup removeObject:self];
        return NO;
    }
    
    [fm removeItemAtPath:self.path error:&error];
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }
    [self.parent.childrenBackup removeObject:self];

    return YES;
}

- (BOOL)rename:(NSString *)newName
{
    if (self.type == FileTypeText && ![newName hasSuffix:@".md"]) {
        newName = [newName stringByAppendingString:@".md"];
    }
    NSError *error = nil;
    
    if (![fm fileExistsAtPath:self.path]) {
        [self.parent.childrenBackup removeObject:self];
        return NO;
    }
    NSString *oldPath = self.path;
    NSString *oldName = self.name;
    self.name = newName;
    
    if ([fm fileExistsAtPath:self.path]) {
        self.name = oldName;
        return NO;
    }
    BOOL ret = [fm moveItemAtPath:oldPath toPath:self.path error:&error];
    
    if (!ret) {
        NSLog(@"%@",error);
        self.name = oldName;
        return NO;
    }
    return YES;
}

- (BOOL)moveToParent:(Item *)newParent
{
    NSError *error = nil;
    
    if (![fm fileExistsAtPath:self.path]) {
        [self.parent.childrenBackup removeObject:self];
        return NO;
    }
    NSString *oldPath = self.path;
    Item *oldParent = self.parent;
    self.parent = newParent;
    if ([fm fileExistsAtPath:self.path]) {
        self.parent = oldParent;
        return NO;
    }
    BOOL ret = [fm moveItemAtPath:oldPath toPath:self.path error:&error];
    
    if (!ret) {
        NSLog(@"%@",error);
        self.parent = oldParent;
        return NO;
    }
   
    [oldParent.childrenBackup removeObject:self];
    [newParent.childrenBackup addObject:self];
    return YES;
}

- (BOOL)save:(NSData *)content
{
    if (![fm fileExistsAtPath:self.path]) {
        [self.parent.childrenBackup removeObject:self];
        return NO;
    }
    
    BOOL ret = [content writeToFile:self.path atomically:YES];
    if (ret) {
        _modifyDate = [NSDate date];
        _size = content.length;
    }
    return ret;
}

#pragma mark 重写NSObject的方法

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        _path = [aDecoder decodeObjectForKey:@"path"];
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%@",self.name,self.childrenBackup];
}

- (BOOL)isEqual:(Item *)object
{
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    return [self.path isEqualToString:object.path];
}

- (NSComparisonResult)compare:(Item *)item
{
    if (item.type == FileTypeText) {
        return NSOrderedAscending;
    }
    return [self.modifyDate compare:item.modifyDate];
}

@end
