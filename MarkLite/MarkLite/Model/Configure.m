//
//  Configure.m
//  MarkLite
//
//  Created by Bingcheng on 11/9/15.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "Configure.h"
#import "Item.h"

#define RGB(x) [UIColor colorWithRGBString:x]
@implementation Configure
{
    NSInteger _iCloudState;
}
+ (instancetype)sharedConfigure
{
    static Configure *conf = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *path = [documentPath() stringByAppendingPathComponent:@"Configure.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            conf = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            if (conf.currentVerion.length == 0 || ![conf.currentVerion isEqualToString:kAppVersionNo]) {
                [conf upgrade];
            }
        }else{
            conf = [[self alloc]init];
            [conf reset];
        }
    });
    return conf;
}

- (BOOL)saveToFile
{
    NSString *path = [documentPath() stringByAppendingPathComponent:@"Configure.plist"];
    
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.highlightColor forKey:@"highlightColor"];
    [aCoder encodeObject:self.highlightStyle forKey:@"highlightStyle"];
    [aCoder encodeObject:self.style forKey:@"style"];
    [aCoder encodeObject:self.upgradeTime forKey:@"upgradeTime"];
    [aCoder encodeObject:self.showRateTime forKey:@"showRateTime"];
    [aCoder encodeObject:self.currentVerion forKey:@"currentVerion"];
    [aCoder encodeObject:self.fontName forKey:@"fontName"];
    [aCoder encodeBool:self.keyboardAssist forKey:@"keyboardAssist"];
    [aCoder encodeBool:self.useLocalImage forKey:@"useLocalImage"];
    [aCoder encodeBool:self.hasShownSwipeTips forKey:@"hasShownSwipeTips"];
    [aCoder encodeBool:self.landscapeEdit forKey:@"landscapeEdit"];
    [aCoder encodeBool:self.hasRated forKey:@"hasRated"];
    [aCoder encodeInteger:self.sortOption forKey:@"sortOption"];
    [aCoder encodeFloat:self.imageResolution forKey:@"imageResolution"];
    [aCoder encodeFloat:self.fontSize forKey:@"fontSize"];
    [aCoder encodeInteger:self.useTimes forKey:@"useTimes"];
    [aCoder encodeObject:self.currentItem forKey:@"currentItem"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        _highlightColor = [aDecoder decodeObjectForKey:@"highlightColor"];
        _style = [aDecoder decodeObjectForKey:@"style"];
        _highlightStyle = [aDecoder decodeObjectForKey:@"highlightStyle"];
        _upgradeTime = [aDecoder decodeObjectForKey:@"upgradeTime"];
        _showRateTime = [aDecoder decodeObjectForKey:@"showRateTime"];
        _fontName = [aDecoder decodeObjectForKey:@"fontName"];
        _keyboardAssist = [aDecoder decodeBoolForKey:@"keyboardAssist"];
        _useLocalImage = [aDecoder decodeBoolForKey:@"useLocalImage"];
        _landscapeEdit = [aDecoder decodeBoolForKey:@"landscapeEdit"];
        _hasRated = [aDecoder decodeBoolForKey:@"hasRated"];
        _hasShownSwipeTips = [aDecoder decodeBoolForKey:@"hasShownSwipeTips"];
        _sortOption = [aDecoder decodeIntegerForKey:@"sortOption"];
        _imageResolution = [aDecoder decodeFloatForKey:@"imageResolution"];
        _fontSize = [aDecoder decodeFloatForKey:@"fontSize"];
        _currentVerion = [aDecoder decodeObjectForKey:@"currentVerion"];
        _useTimes = [aDecoder decodeIntegerForKey:@"useTimes"];
        _currentItem = [aDecoder decodeObjectForKey:@"currentItem"];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)reset
{    
    _highlightColor = @{
                        @"title":RGB(@"488FE1"),
                        @"link":RGB(@"465DC6"),
                        @"image":RGB(@"5245AE"),
                        @"bold":RGB(@"000000"),
                        @"quotes":RGB(@"AE8A86"),
                        @"deletion":RGB(@"747270"),
                        @"separate":RGB(@"BD1586"),
                        @"list":RGB(@"49362E"),
                        @"code":RGB(@"33A191"),
                        };
    _style = @"GitHub2";
    _highlightStyle = @"color-brewer";
    if (_fontName.length < 1) {
        _fontName = @"Hiragino Sans";
    }
    _keyboardAssist = YES;
    _imageResolution = 0.9;
    _upgradeTime = [NSDate date];
    _currentVerion = kAppVersionNo;
    _sortOption = 0;
    _landscapeEdit = NO;
    _fontSize = 16;
    _useTimes = 0;
    [Item recover];
}

- (void)upgrade
{
    _upgradeTime = [NSDate date];
    _currentVerion = kAppVersionNo;
    if (_sortOption > 1) {
        _sortOption = 0;
    }
    _hasRated = NO;
    _fontSize = 16;
    _landscapeEdit = NO;
    _useTimes = 1;
    [Item recover];
}

@end
