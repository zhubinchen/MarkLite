//
//  ProjectViewController.h
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@interface ProjectViewController : UIViewController

- (Item*)openWorkSpace:(NSString*)name;

- (void)newProject;

@end
