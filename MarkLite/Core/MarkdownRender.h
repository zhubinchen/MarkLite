//
//  MarkdownRender.h
//  Markdown
//
//  Created by 朱炳程 on 2019/9/6.
//  Copyright © 2019 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarkdownRender : NSObject

@property (nonatomic,strong) NSString *styleName;
@property (nonatomic,strong) NSString *highlightName;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) NSInteger fontSize;

+ (instancetype)shared;

- (NSString*)renderMarkdown:(NSString*)markdown;

- (NSString*)tocHeader:(NSString*)markdown;

@end
