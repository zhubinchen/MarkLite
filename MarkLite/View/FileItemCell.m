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
    }else if (item.type == FileTypeImage) {
        _typeIcon.image = [UIImage imageNamed:@"image"];
    }else if (item.type == FileTypeFolder){
        _typeIcon.image = [UIImage imageNamed:item.open ? @"folder_open" : @"folder"];
    }
    _iconSpace.constant = begin;
    _addBtn.hidden = !(_edit && item.type == FileTypeFolder);
    _deleteBtn.hidden = !_edit;
    _moreBtn.hidden = _edit;
    
    self.nameText.text = [item.path componentsSeparatedByString:@"/"].lastObject;
    line.frame = CGRectMake(begin , 39.7, kScreenWidth - item.deep * 30 + 22, 0.3);
}

- (IBAction)addBtnClicked:(id)sender {
    self.newFileBlock(_item);
}

- (IBAction)deleteBtnClicked:(id)sender {
    self.deleteFileBlock(_item);
}

- (IBAction)moreBtnClicked:(id)sender {
    self.moreBlock(_item);
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
