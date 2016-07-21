//
//  CreateNoteView.m
//  MarkLite
//
//  Created by zhubch on 7/21/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "CreateNoteView.h"
#import "Item.h"
#import "FileManager.h"

@implementation CreateNoteView

+ (instancetype)instance
{
    CreateNoteView *v = [[NSBundle mainBundle]loadNibNamed:@"CreateNoteView" owner:self options:nil].firstObject;
    return v;
}

- (void)awakeFromNib
{
    self.pathLabel.text = ZHLS(@"Path");
    self.nameLable.text = ZHLS(@"Name");
    self.nameTextFiled.placeholder = ZHLS(@"NamePlaceholder");
    
}

- (void)setParent:(Item *)parent
{
    _parent = parent;
    NSString *path = parent.cloud ? ZHLS(@"NavTitleCloudFile") : ZHLS(@"NavTitleLocalFile");
    if (!parent.root) {
        path = [path stringByAppendingPathComponent:parent.path];
    }
    [self.pathBtn setTitle:path forState:UIControlStateNormal];
}

- (IBAction)chooseFolder:(id)sender
{
    self.chooseFolder();
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSString *name = textField.text;
    name = [name stringByAppendingString:@".md"];
    
    NSString *path = name;
    if (!_parent.root) {
        path = [_parent.path stringByAppendingPathComponent:name];
    }
    Item *i = [[Item alloc]init];
    i.path = path;
    i.open = YES;
    i.cloud = _parent.cloud;
    BOOL ret = [[FileManager sharedManager] createFile:i.fullPath Content:[NSData data]];
    
    if (ret == NO) {
        showToast(ZHLS(@"DuplicateError"));
        return YES;
    }
    
    [_parent addChild:i];
    
    self.didCreateNote(i);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextFiled resignFirstResponder];

    return YES;
}

@end
