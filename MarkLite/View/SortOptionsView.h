//
//  SortOptionsView.h
//  MarkLite
//
//  Created by zhubch on 7/21/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortOptionsView : UIView

@property (nonatomic,assign) NSInteger currentSortOption;

@property (nonatomic,copy) void(^choosedIndex)(NSInteger);

@end
