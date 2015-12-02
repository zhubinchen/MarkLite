//
//  CreateNoteView.h
//  MarkLite
//
//  Created by zhubch on 11/30/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface CreateNoteView : UIView <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,weak) Item *root;
@property (nonatomic,copy) void(^didCreateNote)(Item*);
@property (nonatomic,weak) UIViewController *vc;
@property (nonatomic,assign,readonly) BOOL isShow;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITableView *folderListView;

+ (instancetype)instance;

- (void)showOnView:(UIView*)view;

- (void)remove;

@end
