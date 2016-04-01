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
    if (item.type != FileTypeFolder) {
        begin -= 24;
    }
    _iconSpace.constant = begin;
    _addBtn.hidden = !(_edit && item.type == FileTypeFolder);
    _deleteBtn.hidden = !_edit;
    _typeIcon.hidden = item.type != FileTypeFolder;
    
    if (item.open) {
        _typeIcon.image = [UIImage imageNamed:@"folder_open"];
    }else{
        _typeIcon.image = [UIImage imageNamed:@"folder"];
    }
    
    self.nameText.text = _edit ? item.name : [item.path componentsSeparatedByString:@"/"].lastObject;
    line.frame = CGRectMake(begin , 39.5, kScreenWidth - item.deep * 30 + 22, 0.5);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text containsString:@"."] | [textField.text containsString:@"/"] | [textField.text containsString:@"*"]) {
        showToast(@"请不要输入'./*'等特殊字符");
        return NO;
    }
    
    self.renameFileBlock(_item,textField.text);
    return YES;
}

- (IBAction)addBtnClicked:(id)sender {
    self.newFileBlock(_item);
}

- (IBAction)deleteBtnClicked:(id)sender {
    self.deleteFileBlock(_item);
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
