//
//  KeyboardBar.h
//  MarkLite
//
//  Created by zhubch on 11/10/15.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardBar : UIScrollView <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic,weak) UITextView *editView;
@property (nonatomic,weak) UIViewController *vc;

@end
