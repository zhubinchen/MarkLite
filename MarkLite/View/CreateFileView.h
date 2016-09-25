//
//  CreateFileView.h
//  MarkLite
//
//  Created by zhubch on 7/21/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@class CreateFileView;

@protocol CreateFileViewDelegate <NSObject>

- (void)didCancel:(CreateFileView*)view;

- (void)createFileView:(CreateFileView*)view didCreateItem:(Item*)item;

- (void)shouldChooseParent:(CreateFileView*)view;

@end

@interface CreateFileView : UIView <UITextFieldDelegate>

@property (nonatomic,copy) Item *parent;

@property (nonatomic,assign) id<CreateFileViewDelegate> delegate;

@property (nonatomic,weak) IBOutlet UIButton *pathBtn;

@property (nonatomic,weak) IBOutlet UIButton *cancelBtn;
@property (nonatomic,weak) IBOutlet UIButton *folderBtn;
@property (nonatomic,weak) IBOutlet UIButton *noteBtn;

@property (nonatomic,weak) IBOutlet UILabel *pathLabel;

@property (nonatomic,weak) IBOutlet UILabel *nameLable;

@property (nonatomic,weak) IBOutlet UITextField *nameTextFiled;

+ (instancetype)instance;

@end
