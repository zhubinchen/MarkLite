//
//  FileItemCell.h
//  MarkLite
//
//  Created by zhubch on 15-4-3.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "MGSwipeTableCell.h"

@interface FileItemCell : MGSwipeTableCell 

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconSpace;
@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameText;

@property (nonatomic,assign) int  shift;
@property (nonatomic,strong) Item *item;

@end
