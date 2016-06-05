//
//  FileOperationCell.h
//  MarkLite
//
//  Created by zhubch on 4/18/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
@interface FileOperationCell : UITableViewCell

@property (nonatomic) CGFloat width;
@property (nonatomic,strong) Item *item;
@property (nonatomic,copy) void(^deleteFileBlock)(Item *i);
@property (nonatomic,copy) void(^renameFileBlock)(Item *i);
@property (nonatomic,copy) void(^moveFileBlock)(Item *i);
@property (nonatomic,copy) void(^exportBlock)(Item *i);
@end
