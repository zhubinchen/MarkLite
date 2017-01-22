//
//  KeyboardBar.h
//  MarkLite
//
//  Created by Bingcheng on 11/10/15.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardBar : UIScrollView <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic,weak) UITextView *editView;
@property (nonatomic,weak) UIViewController *vc;

@end
