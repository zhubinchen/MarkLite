//
//  CreateFileView.m
//  MarkLite
//
//  Created by zhubch on 7/21/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "CreateFileView.h"
#import "Item.h"
#import "FileManager.h"

@implementation CreateFileView

+ (instancetype)instance
{
    CreateFileView *v = [[NSBundle mainBundle]loadNibNamed:@"CreateFileView" owner:self options:nil].firstObject;
    return v;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pathLabel.text = ZHLS(@"Path");
    [self.cancelBtn setTitle:ZHLS(@"Cancel") forState:UIControlStateNormal];
    [self.folderBtn setTitle:ZHLS(@"CreateFolder") forState:UIControlStateNormal];
    [self.noteBtn setTitle:ZHLS(@"CreateNote") forState:UIControlStateNormal];
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
    [self.delegate shouldChooseParent:self];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate didCancel:self];
}

- (IBAction)createNote:(id)sender
{
    NSString *name = self.nameTextFiled.text;
    if (name.length == 0) {
        name = ZHLS(@"Untitled");
    }
    name = [name stringByAppendingString:@".md"];
    
    NSString *path = name;
    if (!_parent.root) {
        path = [_parent.path stringByAppendingPathComponent:name];
    }
    Item *i = [[Item alloc]init];
    i.path = path;
    i.open = YES;
    i.cloud = _parent.cloud;
    if ([self.parent.items containsObject:i]) {
        
    }
    NSString *ret = [[FileManager sharedManager] createFile:i.fullPath Content:[NSData data]];
    
    if (ret.length == 0) {
        showToast(ZHLS(@"DuplicateError"));
        return;
    }
    i.path = ret;
    [_parent addChild:i];
    
    [self.delegate createFileView:self didCreateItem:i];
}

- (IBAction)createFolder:(id)sender
{
    NSString *name = self.nameTextFiled.text;
    if (name.length == 0) {
        name = ZHLS(@"UntitledFolder");
    }
    
    NSString *path = name;
    if (!_parent.root) {
        path = [_parent.path stringByAppendingPathComponent:name];
    }
    Item *i = [[Item alloc]init];
    i.path = path;
    i.open = YES;
    i.cloud = _parent.cloud;
    if ([self.parent.items containsObject:i]) {
        
    }
    NSString *ret = [[FileManager sharedManager] createFolder:i.fullPath];
    
    if (ret.length == 0) {
        showToast(ZHLS(@"DuplicateError"));
        return;
    }
    i.path = ret;
    [_parent addChild:i];
    
    [self.delegate createFileView:self didCreateItem:i];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextFiled resignFirstResponder];

    return YES;
}

@end
