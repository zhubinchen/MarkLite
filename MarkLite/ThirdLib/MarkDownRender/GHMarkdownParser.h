//
//  GHMarkdownParser.h
//  GHMarkdownParser
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+GHMarkdownParser.h"


/** Option flags for Markdown parsing. */
typedef enum {
    kGHMarkdownNoLinks          = 0x00000001,   //< Don't allow links at all
    kGHMarkdownNoImages         = 0x00000002,   //< Don't allow images
    kGHMarkdownNoSmartQuotes    = 0x00000004,   //< Don't convert ASCII quotes
    kGHMarkdownNoHTMLTags       = 0x00000008,   //< Don't allow any HTML tags in the input
    kGHMarkdownStrict           = 0x00000010,   //< Don't allow emphasis in mid-word
    kGHMarkdownAutoLink         = 0x00004000,   //< Convert URLs in the input to links
    kGHMarkdownSafeLinks        = 0x00008000    //< Only allow http:, https:, ftp: links
    // These MUST match the values of the "MKD_..." constants defined in mkdio.h!
    // FYI, there are more of these implemented by Discount that aren't exposed here.
} GHMarkdownOptions;



/** Parses human-readable input in the Markdown format and converts it to HTML. */
@interface GHMarkdownParser : NSObject

/** Option flags for Markdown parsing. By default these are all off. */
@property (nonatomic, assign) GHMarkdownOptions options;

/** If set, Github-Flavored Markdown extensions are supported. */
@property (nonatomic, assign) BOOL githubFlavored;

/** If set, relative URLs will be prefixed with this absolute URL. */
@property (nonatomic, strong) NSURL *baseURL;


/** Converts a Markdown string to HTML using this parser instance's settings. */
- (NSString *)HTMLStringFromMarkdownString:(NSString *)markdownString;


/** Convenience method that converts Markdown with the default settings. */
+ (NSString *)HTMLStringFromMarkdownString:(NSString *)markdownString;

/** Convenience method that converts Github-flavored Markdown with otherwise-default settings. */
+ (NSString *)flavoredHTMLStringFromMarkdownString:(NSString *)markdownString;

@end
