//
//  NoteItemCell.m
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "NoteItemCell.h"

@implementation NoteItemCell

- (void)setItem:(Item *)item
{
    _nameLabel.text = item.name;
    
    NSArray *rgbArray = @[@"F14143",@"EA8C2F",@"E6BB32",@"56BA38",@"379FE6",@"BA66D0"];
    self.tagView.backgroundColor = [UIColor colorWithRGBString:rgbArray[item.tag]];
}

- (void)awakeFromNib {
    // Initialization code
    [self.tagView showBorderWithColor:[UIColor colorWithWhite:0.1 alpha:0.1] radius:8 width:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
