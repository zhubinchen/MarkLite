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
    CGFloat begin = item.deep * 30 - 22;
    if (item.type != FileTypeFolder) {
        begin -= 40;
    }
    _iconSpace.constant = begin;
    _addBtn.hidden = item.type != FileTypeFolder;
    _typeIcon.hidden = item.type != FileTypeFolder;
    
    if (item.open) {
        _typeIcon.image = [UIImage imageNamed:@"folder_open"];
    }else{
        _typeIcon.image = [UIImage imageNamed:@"folder"];
    }
    
    self.nameText.text = [item.path componentsSeparatedByString:@"/"].lastObject;
    
    line.frame = CGRectMake(item.deep * 30 - 22 , 39.5, kScreenWidth - item.deep * 30 + 22, 0.5);
}

- (IBAction)addBtnClicked:(id)sender {
    self.newFileBlock();
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
