//
//  MoveFileView.h
//  MarkLite
//
//  Created by zhubch on 6/5/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface MoveFileView : UIView

@property (nonatomic,weak) Item *root;
@property (nonatomic,copy) void(^didMoveFile)(Item*);
@property (nonatomic,weak) UIViewController *vc;
@property (nonatomic,assign,readonly) BOOL isShow;
@property (weak, nonatomic) IBOutlet UITableView *folderListView;

+ (instancetype)instance;

- (void)reset;

- (void)show;

- (void)remove;

@end
