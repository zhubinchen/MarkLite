//
//  NoteItemCell.h
//  MarkLite
//
//  Created by zhubch on 11/20/15.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "Item.h"

@interface NoteItemCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;

@property (nonatomic,strong) Item *item;

@end
