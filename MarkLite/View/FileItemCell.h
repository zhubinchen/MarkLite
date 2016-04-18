//
//  FileItemCell.h
//  MarkLite
//
//  Created by zhubch on 15-4-3.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface FileItemCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconSpace;
@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *checkIcon;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (nonatomic,assign) int  shift;
@property (nonatomic,strong) Item *item;

@property (nonatomic,copy) void(^newFileBlock)(Item *i);
@property (nonatomic,copy) void(^deleteFileBlock)(Item *i);
@property (nonatomic,copy) void(^moreBlock)(Item *i);

@property (nonatomic,assign) BOOL edit;

@end
