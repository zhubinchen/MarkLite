//
//  MainViewController.h
//  MarkLite
//
//  Created by Bingcheng on 11/23/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "BaseViewController.h"

@class Item;
@interface MainViewController : BaseViewController

@property (nonatomic,strong) Item *root;

@property (nonatomic,assign) BOOL chooseFolder;

@property (nonatomic,copy) void(^didChooseFolder)(Item*);

@property (nonatomic,strong) Item *recievedItem;

- (void)reload;

@end
