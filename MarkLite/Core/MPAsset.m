//
//  MPAsset.m
//  MacDown
//
//  Created by Tzu-ping Chung  on 29/6.
//  Copyright (c) 2014 Tzu-ping Chung . All rights reserved.
//

#import "MPAsset.h"
#import <HBHandlebars/HBHandlebars.h>
#import "MPUtilities.h"


@interface MPAsset ()
@property (strong) NSURL *url;
@end


@implementation MPAsset

+ (instancetype)assetWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (!self)
        return nil;
    self.url = [url copy];
    return self;
}

- (instancetype)init
{
    return [self initWithURL:nil];
}

- (NSString *)templateForOption:(MPAssetOption)option
{
    NSString *reason =
        [NSString stringWithFormat:@"Method %@ requires overriding",
                                   NSStringFromSelector(_cmd)];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:reason userInfo:nil];
}

- (NSString *)htmlForOption:(MPAssetOption)option
{
    NSMutableDictionary *context = @{}.mutableCopy;
    switch (option)
    {
        case MPAssetNone:
            break;
        case MPAssetEmbedded:
            if (self.url.isFileURL)
            {
                NSString *content = MPReadFileOfPath(self.url.path);
                if ([content hasSuffix:@"\n"])
                    content = [content substringToIndex:content.length - 1];
                context[@"content"] = content;
                break;
            }
            // Non-file URLs fallthrough to be treated as full links.
        case MPAssetFullLink:
            context[@"url"] = self.url.absoluteString;
            break;
    }

    NSString *template = [self templateForOption:option];
    if (!template || !context.count)
        return nil;

    NSString *result = [HBHandlebars renderTemplateString:template
                                              withContext:context error:NULL];

    return result;
}

@end


@implementation MPStyleSheet


+ (instancetype)CSSWithURL:(NSURL *)url
{
    return [super assetWithURL:url];
}

- (NSString *)templateForOption:(MPAssetOption)option
{
    NSString *template = nil;
    switch (option)
    {
        case MPAssetNone:
            break;
        case MPAssetEmbedded:
            if (self.url.isFileURL)
            {
                template = (@"<style>\n"
                            @"{{{ content }}}\n</style>");
                break;
            }
            // Non-file URLs fallthrough to be treated as full links.
        case MPAssetFullLink:
            template = (@"<link rel=\"stylesheet\" "
                        @"href=\"{{ url }}\">");
            break;
    }
    return template;
}

@end


@implementation MPScript

+ (instancetype)javaScriptWithURL:(NSURL *)url
{
    return [super assetWithURL:url];
}

- (NSString *)templateForOption:(MPAssetOption)option
{
    NSString *template = nil;
    switch (option)
    {
        case MPAssetNone:
            break;
        case MPAssetEmbedded:
            if (self.url.isFileURL)
            {
                template = (@"<script>\n"
                            @"{{{ content }}}\n</script>");
                break;
            }
            // Non-file URLs fall-through to be treated as full links.
        case MPAssetFullLink:
            template = (@"<script src=\"{{ url }}\">"
                        @"</script>");
            break;
    }
    return template;
}

@end


@implementation MPEmbeddedScript

- (NSString *)htmlForOption:(MPAssetOption)option
{
    if (option == MPAssetFullLink)
        option = MPAssetEmbedded;
    return [super htmlForOption:option];
}

@end
