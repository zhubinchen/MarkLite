//
//  EditView.h
//  MarkLite
//
//  Created by Bingcheng on 15-3-27.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditView : UITextView

@property (nonatomic,copy) void(^textChanged)(NSString*);

@end
