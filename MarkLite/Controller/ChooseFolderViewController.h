//
//  ChooseFolderViewController.h
//  MarkLite
//
//  Created by zhubch on 7/5/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface ChooseFolderViewController : UIViewController

@property (nonatomic,copy) void (^didChoosedFolder)(Item *item);

@end
