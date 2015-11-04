//
//  FileItemCell.m
//  MarkLite
//
//  Created by zhubch on 15-4-3.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "FileItemCell.h"

@implementation FileItemCell

- (void)setItem:(Item *)item
{
    _iconSpace.constant = item.deep * 30 - 22;
    _addBtn.hidden = !item.folder;
    _typeIcon.hidden = !item.folder;
    NSArray *path = [item.name componentsSeparatedByString:@"/"];
    
    long level = path.count - 1;
    
    self.nameText.text = path[level];
}

- (IBAction)addBtnClicked:(id)sender {
    self.onAdd(_item);
}

- (IBAction)trashBtnClicked:(id)sender {
    self.onTrash(_item);
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
