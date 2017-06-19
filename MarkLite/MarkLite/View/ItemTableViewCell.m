//
//  ItemTableViewCell.m
//  MarkLite
//
//  Created by Bingcheng on 11/23/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "Item.h"

@implementation ItemTableViewCell

- (void)setItem:(Item *)item
{
    _item = item;
    _nameLabel.text = item.displayName;
    _nameLabel.font = fontOfSize(16);
    if (item.type == FileTypeFolder) {
        _sizeLabel.text = [NSString stringWithFormat:@"%ld",item.items.count];
        if (item.deep) {
            [_iconImageButton setImage:[UIImage imageNamed:@"folder"] forState:UIControlStateNormal];
        }else if (item == [Item dropboxRoot]) {
            [_iconImageButton setImage:[UIImage imageNamed:@"dropbox"] forState:UIControlStateNormal];
        }else if (item == [Item cloudRoot]) {
            [_iconImageButton setImage:[UIImage imageNamed:@"cloud"] forState:UIControlStateNormal];
        }else if (item == [Item localRoot]) {
            [_iconImageButton setImage:[UIImage imageNamed:@"local"] forState:UIControlStateNormal];
        }
    }else{
        _sizeLabel.text = @"";
        [_iconImageButton setImage:[UIImage imageNamed:@"note"] forState:UIControlStateNormal];
    }

    _checkButton.selected = item.selected;
}

- (void)setShowCheckButton:(BOOL)showCheckButton
{
    _showCheckButton = showCheckButton;
    self.checkButton.hidden = !showCheckButton;
    self.checkButtonWidth.constant = showCheckButton ? 50.0 : 0.0;

    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.checkButton setImage:[UIImage imageNamed:@"check_icon_s"] forState:UIControlStateSelected];
    [self.iconImageButton setTintColor:[UIColor colorWithRGBString:@"25282a"]];
    [self.nameLabel setTextColor:[UIColor colorWithRGBString:@"25282a"]];
}

- (IBAction)checkBtnClicked:(id)sender
{
    self.didCheckItem(_item);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

@end
