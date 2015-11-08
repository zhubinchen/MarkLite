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
    CGFloat begin = item.deep * 30 - 22;
    if (!item.folder) {
        begin -= 30;
    }
    _iconSpace.constant = begin;
    _addBtn.hidden = !item.folder;
    _typeIcon.hidden = !item.folder;
    NSArray *path = [item.name componentsSeparatedByString:@"/"];
    
    long level = path.count - 1;
    
    self.nameText.text = path[level];
    
    line.frame = CGRectMake(item.deep * 30 - 22 , 39.5, kScreenWidth - item.deep * 30 + 22, 0.5);
}

- (IBAction)addBtnClicked:(id)sender {
    self.onAdd(_item);
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
    // Configure the view for the selected state
}

@end
