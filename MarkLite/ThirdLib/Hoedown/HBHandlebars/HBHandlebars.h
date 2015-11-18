//
//  HBHandlebars.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/1/13.
//
//  The MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import <Foundation/Foundation.h>

#import "HBDataContext.h"
#import "HBExecutionContext.h"
#import "HBHelper.h"
#import "HBHelperRegistry.h"
#import "HBPartial.h"
#import "HBPartialRegistry.h"
#import "HBTemplate.h"
#import "HBHelperUtils.h"
#import "HBErrorHandling.h"
#import "HBHandlebarsKVCValidation.h"
#import "HBExecutionContextDelegate.h"

/** 
 
 This class is the main entry point for simple uses of Handlebars. Most methods declared here are just user-friendly facades
 to functionality available in other dedicated classes. 
 
 Unless you have specific needs and want more fine-grained control over the API, using the methods declared
 on HBHandlebars class is totally fine. 
 
 ## Templates ##

 Templates referred to in this API must be written using Handlebars syntax documented on [Handlebars.js](http://handlebarsjs.com/) website.
 
 @"hello {{word}}" is a valid (but useless) template, wrapped in an objective-C string literal.
 
 
 ## Contexts ##
 
 Contexts are in general property-list compatible objects. See [Apple documentation](https://developer.apple.com/library/mac/documentation/general/conceptual/devpedia-cocoacore/PropertyList.html) for a list of such objects. 
 
 ## Helpers and partials ##
 
 Helpers are functions implemented by the developer and which are then available for use in templates. Handlebars defines to type of helpers: expression helpers and block helpers. Please refer to Handlebars.js documentation](http://handlebarsjs.com/expressions.html) for more details regarding the difference between both.
 
 In Handlebars-objc expression helpers and block helpers are added the same way, by registering objective-C blocks. Block type is declared as: 
 
    typedef NSString* (^HBHelperBlock)(HBHelperCallingInfo* info);

 Please see <HBHelperCallingInfo> for more details on block input parameters. 
 
 Partials are just template chunks that can be reused in templates.

 
*/



// Logger type definition
typedef NSString* (^HBLoggerBlock)(NSInteger level, id object);

@interface HBHandlebars : NSObject

/** @name Rendering templates, convenience API */

/**
Render a string template for a data context.
 
This method is the simplest way to render a template with handlebars-objc. It instanciates an HBTemplate instance, compiles the template and renders it.
 
This method should be used only if you render templates in non mission-critical parts of your application. In particular, the provided template string is recompiled at each call. If your application calls it repeatedly, you should rather instantiate HBTemplate instances.

 @param template String containing the template to render
 @param context The object containing the data used in the template. Can be any property-list compatible object for instance.
 @param error pointer to an NSError object that is set if an error occurs during parsing or evaluation of template. Can be nil.
 @see HBTemplate
 
 @since v1.0
*/
+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context error:(NSError**)error;

/**
 Render a string template for a data context using some helpers.
 
 This method renders a template using helpers. It instanciates an HBTemplate instance compiles the template and renders it with the provided helpers.
 See <+[HBHandlebars renderTemplateString:withContext:error:]> for a discussion regarding the performance implications of using this convenience API.
 
 @param template String containing the template to render
 @param context The object containing the data used in the template. Can be any property-list compatible object.
 @param helperBlocks A dictionary where keys are helper names and values are helper blocks of type HBHelperBlock.
 @param error pointer to an NSError object that is set if an error occurs during parsing or evaluation of template. Can be nil.
 @since v1.0
 */
+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks error:(NSError**)error;

/**
 Render a string template for a data context using some helpers.
 
 This method renders a template using helpers and partials. It instanciates an HBTemplate instance compiles the template and renders it with the provided helpers and partials.
 See <+[HBHandlebars renderTemplateString:withContext:error:]> for a discussion regarding the performance implications of using this convenience API.
 
 @param template String containing the template to render
 @param context The object containing the data used in the template. Can be any property-list compatible object.
 @param helperBlocks A dictionary where keys are helper names and values are helper blocks of type HBHelperBlock.
 @param partialStrings A dictionary where keys are partial names and values are partials strings.
 @param error pointer to an NSError object that is set if an error occurs during parsing or evaluation of template. Can be nil.
 @since v1.0
 */
+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks withPartialStrings:(NSDictionary*)partialStrings error:(NSError**)error;




/** @name Registering global helpers */

/**
 Register a global helper.
 
 This method registers a global helper, visible to all templates. This method should be used if you frequently use the same helpers in your templates.
 While it's totally fine to do so, if you find yourself using some helpers only in certain kind of templates, it is much cleaner to use HBExecutionContext instead.

 Implementation-wise, this methods adds a helper to the global execution context, accessible via <[HBExecutionContext globalExecutionContext]>.
 If you want a finer control over which templates a helper will be accessible from, you can create your own <HBExecutionContext> and register your helpers using <[HBExecutionContext registerHelperBlocks:]> or <[HBExecutionContext registerHelperBlock:forName:]>.
 
 @param block A helper blocks of type HBHelperBlock.
 @param helperName The name this helper is referred as in templates.
 
 @see HBExecutionContext
 @see [HBExecutionContext registerHelperBlocks:]
 @since v1.0
 */
+ (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)helperName;

/**
 Unregister a global helper. 
 
 This methods remove a helper from the global execution context. After calling this method, the corresponding helper will not be accessible from templates. 
 
 @param helperName The name of the helper to unregister 
 @see [HBExecutionContext unregisterHelperForName:]
 @since v1.0
 */
+ (void) unregisterHelperForName:(NSString*)helperName;

/** 
 Unregister all global helpers
 
 This method remove all helpers from the global execution context. After calling this method, no global helper will be accessible from templates, until you add new ones.
 
 @see [HBExecutionContext unregisterHelperForName:]
 @since v1.0
 */
+ (void) unregisterAllHelpers;



/** @name Registering global partials */

/**
 Register a global partial.
 
 This method registers a global partial, visible to all templates. This method should be used if you frequently use the same partials in your templates.
 If you find yourself using some helpers only in certain kind of templates, it is much cleaner to use HBExecutionContext instead. Please see the discussion in <[HBHandlebars registerHelperBlock:forName:]> regarding this matter.

 @param partialString String containing the partial
 @param partialName The name this partial will be referred as in templates.
 
 @see HBExecutionContext
 @see [HBExecutionContext registerPartialString:forName:]
 @since v1.0
 */
+ (void) registerPartialString:(NSString*)partialString forName:(NSString*)partialName;

/**
 Unregister a global partial.
 
 This method removes a partial from the global execution context. After calling this method, the corresponding partial will not be accessible from templates.
 
 @param partialName The name of the partial to unregister
 @see [HBExecutionContext unregisterPartialForName:]
 @since v1.0
 */
+ (void) unregisterPartialForName:(NSString*)partialName;

/**
 Unregister all global partials
 
 This method remove all partials from the global execution context. After calling this method, no global partial will be accessible from templates, until you add new ones.
 
 @see [HBExecutionContext unregisterPartialForName:]
 @since v1.0
 */
+ (void) unregisterAllPartials;



/** @name Logging */

/**
 Set the global logger.
 
 This method sets the global logger, used when handlebars needs to display a message to the developer. If set to nil, then NSLog is used. 
 
 Log messages can be sent from templates using the "log" builtin helper.
 
 @param loggerBlock a block executed everytime something is logged.
 @since v1.0
 */
+ (void) setLoggerBlock:(HBLoggerBlock)loggerBlock;

/**
 Log a message.
 
 This method can be used in helper implementations to log messages using the default logger.
 
 @param level level of the log message.
 @param object object to log. Any object responding to -[NSObject description] can be used.
 @since v1.0
 */
+ (void) log:(NSInteger)level object:(id)object;

@end
