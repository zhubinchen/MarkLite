//
//  EditView.h
//  MarkLite
//
//  Created by Bingcheng on 15-3-27.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZBCKeyBoard;

@interface EditView : UITextView

@property (nonatomic,strong) ZBCKeyBoard *keyboard;

@property (nonatomic,copy) void(^textChanged)(NSString*);

@end
