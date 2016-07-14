//
//  NoteItemCell.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "NoteItemCell.h"
#import "FileManager.h"

@implementation NoteItemCell

- (void)setItem:(Item *)item
{
    NSString *path = [item.cloud ? ZHLS(@"NavTitleCloudFile") : ZHLS(@"NavTitleLocalFile") stringByAppendingPathComponent:item.path];
    _item = item;
    _nameLabel.text = item.name;
    _pathLabel.text = [NSString stringWithFormat:ZHLS(@"Path"),path];
    NSDictionary *attr = [[FileManager sharedManager] attributeOfPath:item.fullPath];
    long size = [attr[NSFileSize] integerValue];
    NSString *date = [attr[NSFileModificationDate] formatDate];
    _sizeLabel.text = [NSString stringWithFormat:@"%.2f KB",size / 1000.0];
    _timeLabel.text = [NSString stringWithFormat:ZHLS(@"LastUpdate"),date];
//
//    NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
//    self.tagView.backgroundColor = [UIColor colorWithRGBString:rgbArray[item.tag] alpha:0.9];
}

- (void)awakeFromNib {
    // Initialization code
//    [self.tagView showBorderWithColor:[UIColor colorWithWhite:0.1 alpha:0.1] radius:8 width:1.5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
    
    self.backgroundColor = selected ? [UIColor groupTableViewBackgroundColor] : [UIColor whiteColor];
}

@end
