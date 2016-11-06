//
//  NoteItemCell.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "NoteItemCell.h"
#import "FileManager.h"

@implementation NoteItemCell

- (void)setItem:(Item *)item
{
    NSString *path = [item.cloud ? ZHLS(@"NavTitleCloudFile") : ZHLS(@"NavTitleLocalFile") stringByAppendingPathComponent:item.path];
    _item = item;
    _nameLabel.text = item.name;

    NSString *pathText = [ZHLS(@"Path") stringByAppendingString:path];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:pathText];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRGBString:@"1AA7F2"] range:[pathText rangeOfString:path]];
    _pathLabel.attributedText = attributeString;
    
    NSDictionary *attr = [[FileManager sharedManager] attributeOfPath:item.fullPath];
    long size = [attr[NSFileSize] integerValue];
    NSString *date = [attr[NSFileModificationDate] formatDate];
    _sizeLabel.text = [NSString stringWithFormat:@"%.2f KB",size / 1000.0];
    
    NSString *timeText = [ZHLS(@"LastUpdate") stringByAppendingString:date];
    attributeString = [[NSMutableAttributedString alloc]initWithString:timeText];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRGBString:@"a0a0a0"] range:[timeText rangeOfString:date]];
    _timeLabel.attributedText = attributeString;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self.tagView showBorderWithColor:[UIColor colorWithWhite:0.1 alpha:0.1] radius:8 width:1.5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
    
    self.backgroundColor = selected ? [UIColor groupTableViewBackgroundColor] : [UIColor whiteColor];
}

@end
