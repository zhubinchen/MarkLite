//
//  FileItemCell.m
//  MarkLite
//
//  Created by zhubch on 15-4-3.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "FileItemCell.h"

@implementation FileItemCell
{
    UIView *line;
}

- (void)setItem:(Item *)item
{
    _item = item;
    CGFloat begin = (item.deep+_shift) * 30 - 22;
    if (item.type == FileTypeText) {
        _typeIcon.image = [UIImage imageNamed:@"text"];
    }else if (item.type == FileTypeFolder){
        _typeIcon.image = [UIImage imageNamed:item.open ? @"folder_open" : @"folder"];
    }
    _iconSpace.constant = begin;
    
    self.nameText.text = [item.path componentsSeparatedByString:@"/"].lastObject;
    line.frame = CGRectMake(begin , 49.7, kScreenWidth - item.deep * 30 + 22, 0.3);
    
    MGSwipeButton *delete = [MGSwipeButton buttonWithTitle:@"delete" icon:[UIImage imageNamed:@"chat_icon_delete_normal"] backgroundColor:[UIColor colorWithRGBString:@"ff0000"]];
    delete.buttonWidth = 80;
    [delete setImage:[UIImage imageNamed:@"chat_icon_delete_press"] forState:UIControlStateHighlighted];
    
    MGSwipeButton *export = [MGSwipeButton buttonWithTitle:@"export" icon:[UIImage imageNamed:@"chat_icon_videocam_normal"] backgroundColor:[UIColor colorWithRGBString:@"00ff00"]];
    [export setImage:[UIImage imageNamed:@"chat_icon_videocam_press"] forState:UIControlStateHighlighted];
    export.buttonWidth = 80;
    
    MGSwipeButton *rename = [MGSwipeButton buttonWithTitle:@"rename" icon:[UIImage imageNamed:@"chat_icon_videocam_normal"] backgroundColor:[UIColor colorWithRGBString:@"00ff00"]];
    [rename setImage:[UIImage imageNamed:@"chat_icon_videocam_press"] forState:UIControlStateHighlighted];
    rename.buttonWidth = 80;
    
    if (item.type == FileTypeFolder) {
        self.rightButtons = @[delete,rename];
    } else {
        self.rightButtons = @[delete,rename,export];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    line = [[UIView alloc]init];
    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    if (selected) {
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }else {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    }
}

@end
