//
//  HighLightModel.h
//  MarkLite
//
//  Created by zhubch on 11/12/15.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HighLightModel : NSObject

@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIColor *backgroudColor;
@property (nonatomic,assign) BOOL italic;
@property (nonatomic,assign) BOOL strong;
@property (nonatomic,assign) BOOL deletionLine;
@property (nonatomic,assign) CGFloat size;

- (NSDictionary*)attribute;

@end
