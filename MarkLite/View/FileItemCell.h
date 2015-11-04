//
//  FileItemCell.h
//  MarkLite
//
//  Created by zhubch on 15-4-3.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface FileItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconSpace;
@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic,strong) Item *item;

@property (nonatomic,copy) void(^onAdd)();

@property (nonatomic,copy) void(^onTrash)();

@end
