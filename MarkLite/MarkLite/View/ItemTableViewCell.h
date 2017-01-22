//
//  ItemTableViewCell.h
//  MarkLite
//
//  Created by Bingcheng on 11/23/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@interface ItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *checkButtonWidth;
@property (nonatomic,weak) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *iconImageButton;

@property (nonatomic,strong) Item *item;
@property (nonatomic,assign) BOOL showCheckButton;

@property (nonatomic,copy) void(^didCheckItem)(Item*);

@end
