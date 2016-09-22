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
    if (_item) {
        [_item removeObserver:self forKeyPath:@"selected"];
    }
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
    
    MGSwipeButton *delete = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"cell_delete"] backgroundColor:[UIColor colorWithRGBString:@"FB2025"] padding:10];
    delete.buttonWidth = 70;
    
    MGSwipeButton *export = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"cell_export"] backgroundColor:[UIColor colorWithRGBString:@"1AA7F2"] padding:10];
    export.buttonWidth = 70;
    
    MGSwipeButton *rename = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"cell_rename"] backgroundColor:[UIColor colorWithRGBString:@"FD8909"] padding:10];
    rename.buttonWidth = 70;
    
    if (item.type == FileTypeFolder) {
        self.rightButtons = @[delete,rename];
    } else {
        self.rightButtons = @[delete,rename,export];
    }
    
    [self.checkBtn setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    self.checkBtn.selected = item.selected;
    
    [item addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    self.checkBtn.selected = self.item.selected;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    line = [[UIView alloc]init];
    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self addSubview:line];
}

- (IBAction)selectBtn:(UIButton*)sender
{
    sender.selected = !sender.selected;
    self.item.selected = sender.selected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    if (selected) {
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }else {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    }
}

- (void)dealloc
{
    [self.item removeObserver:self forKeyPath:@"selected"];
}

@end
