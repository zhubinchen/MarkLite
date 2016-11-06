//
//  EditView.h
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2016年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZBCKeyBoard;

@interface EditView : UITextView

@property (nonatomic,strong) ZBCKeyBoard *keyboard;

- (void)updateSyntax;

@end
