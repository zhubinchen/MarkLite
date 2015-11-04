//
//  EditView.h
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownTextView.h"

@class ZBCKeyBoard;

@interface EditView : MarkdownTextView

@property (nonatomic,strong) ZBCKeyBoard *keyboard;

@end
