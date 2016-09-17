//
//  CreateNoteView.h
//  MarkLite
//
//  Created by zhubch on 7/21/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface CreateNoteView : UIView <UITextFieldDelegate>

@property (nonatomic,copy) Item *parent;

@property (nonatomic,copy) void(^didCreateNote)(Item*);

@property (nonatomic,copy) void(^chooseFolder)();

@property (nonatomic,weak) IBOutlet UIButton *pathBtn;

@property (nonatomic,weak) IBOutlet UIButton *sureBtn;

@property (nonatomic,weak) IBOutlet UILabel *pathLabel;

@property (nonatomic,weak) IBOutlet UILabel *nameLable;

@property (nonatomic,weak) IBOutlet UITextField *nameTextFiled;


+ (instancetype)instance;

@end
