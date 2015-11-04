//
//  LxFTPRequest.m
//

#import "LxFTPRequest.h"

#define PRINTF_MARK(x) printf("%s\n",#x)
#define PRINTF(fmt, ...)    printf("%s\n",[[NSString stringWithFormat:fmt,##__VA_ARGS__]UTF8String])

@implementation NSString (ftp)

- (BOOL)isValidateFTPURLString
{
    if (self.length > 0) {
        return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[Ff][Tt][Pp]://(\\w*(:[=_0-9a-zA-Z\\$\\(\\)\\*\\+\\-\\.\\[\\]\\?\\\\\\^\\{\\}\\|`~!#%&\'\",<>/]*)?@)?([0-9a-zA-Z]+\\.)+[0-9a-zA-Z]+(:(6553[0-5]|655[0-2]\\d|654\\d\\d|64\\d\\d\\d|[0-5]?\\d?\\d?\\d?\\d))?(/?|((/[=_0-9a-zA-Z\\-%]+)+(/|\\.[_0-9a-zA-Z]+)?))$"] evaluateWithObject:self];
    }
    else {
        return NO;
    }
}

- (BOOL)isValidateFileURLString
{
    if (self.length > 0) {
        return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[Ff][Ii][Ll][Ee]://?((/[=_0-9a-zA-Z%\\-]+(\\.[_0-9a-zA-Z]+)?)+(/|\\.[_0-9a-zA-Z]+)?)$"] evaluateWithObject:self];
    }
    else {
        return NO;
    }
}

- (NSString *)stringByDeletingScheme
{
    int pathStartLocation = 0;
    for (int i = 0; i < self.length; i++) {
        if ([self characterAtIndex:i] == (unichar)':') {
            for (int j = i; j < self.length; j++) {
                if ([self characterAtIndex:j] == (unichar)'/' && (j == self.length - 1 || [self characterAtIndex:j + 1] != (unichar)'/')) {
                    pathStartLocation = j;
                    break;
                }
            }
            break;
        }
    }
    return [self substringFromIndex:pathStartLocation];
}

- (NSString *)stringDecorateWithUsername:(NSString *)username password:(NSString *)password
{
    if (!self.isValidateFTPURLString) {
        return nil;
    }
    else {
        
        BOOL usernameIslegal = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^\\w*$"] evaluateWithObject:username];
        BOOL passwordIslegal = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[=_0-9a-zA-Z\\$\\(\\)\\*\\+\\-\\.\\[\\]\\?\\\\\\^\\{\\}\\|`~!#%&\'\",<>/]*$"] evaluateWithObject:password];
        
        if (usernameIslegal && passwordIslegal) {
            
            NSString * identityString = [NSString stringWithFormat:@"%@:%@@", username, password];
            
            int schemeEndPosition = 0;
            int hostBeginPosition = 0;
            
            for (int i = 0; i < self.length; i++) {
                if (i > 0 && [self characterAtIndex:i-1] == (unichar)'/' && [self characterAtIndex:i] == (unichar)'/') {
                    schemeEndPosition = i;
                    hostBeginPosition = MIN(i+1, (int)self.length - 1);
                }
                if ([self characterAtIndex:i] == (unichar)'@') {
                    hostBeginPosition = MIN(i+1, (int)self.length - 1);
                    break;
                }
            }
            
            return [NSString stringWithFormat:@"%@%@%@", [self substringToIndex:schemeEndPosition + 1], identityString, [self substringFromIndex:hostBeginPosition]];
        }
        else {
            return nil;
        }
    }
}

@end



@interface LxFTPRequest ()

@property (nonatomic,assign) CFReadStreamRef readStream;
@property (nonatomic,assign) CFWriteStreamRef writeStream;

@end

@implementation LxFTPRequest

- (instancetype)init
{
    PRINTF(@"LxFTPRequest: Can't init directly by this method!");
    return nil;
}

- (instancetype)initPrivate
{
    if (self = [super init]) {
        self.username = @"";
        self.password = @"";
        self.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent){};
        self.successAction = ^(Class resultClass, id result){};
        self.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString * errorMessage){};
        
        _streamClientContext.version = 0;
        _streamClientContext.retain = NULL;
        _streamClientContext.release = NULL;
        _streamClientContext.copyDescription = NULL;
        _streamClientContext.info = (void *)CFBridgingRetain(self);
    }
    return self;
}

- (void)dealloc
{
    self.serverURL = nil;
    self.localFileURL = nil;
    self.username = nil;
    self.password = nil;
    self.finishedSize = 0;
    self.fileTotalSize = 0;
    self.progressAction = nil;
    self.successAction = nil;
    self.failAction = nil;
    self.readStream = nil;
    self.writeStream = nil;
}

- (void)setServerURL:(NSURL *)serverURL
{
    if (serverURL.absoluteString.isValidateFTPURLString) {
        
        if (_serverURL != serverURL) {
            _serverURL = serverURL;
        }
    }
    else {
        PRINTF_MARK(LxFTPRequest: The serverURL is illegal!);
    }
}

- (void)setLocalFileURL:(NSURL *)localFileURL
{
    if (localFileURL.absoluteString.isValidateFileURLString) {
        
        if (_localFileURL != localFileURL) {
            _localFileURL = localFileURL;
        }
    }
    else {
        PRINTF_MARK(LxFTPRequest: The localFileURL is illegal!);
    }
}

- (BOOL)start
{
    return NO;
}

- (void)stop
{

}

- (NSString *)errorMessageOfCode:(NSInteger)code
{
    switch (code) {
        case 110:
            return @"Restart marker reply. In this case, the text is exact and not left to the particular implementation; it must read: MARK yyyy = mmmm where yyyy is User-process data stream marker, and mmmm server's equivalent marker (note the spaces between markers and \"=\").";
            break;
        case 120:
            return @"Service ready in nnn minutes.";
            break;
        case 125:
            return @"Data connection already open; transfer starting.";
            break;
        case 150:
            return @"File status okay; about to open data connection.";
            break;
        case 200:
            return @"Command okay.";
            break;
        case 202:
            return @"Command not implemented, superfluous at this site.";
            break;
        case 211:
            return @"System status, or system help reply.";
            break;
        case 212:
            return @"Directory status.";
            break;
        case 213:
            return @"File status.";
            break;
        case 214:
            return @"Help message.On how to use the server or the meaning of a particular non-standard command. This reply is useful only to the human user.";
            break;
        case 215:
            return @"NAME system type. Where NAME is an official system name from the list in the Assigned Numbers document.";
            break;
        case 220:
            return @"Service ready for new user.";
            break;
        case 221:
            return @"Service closing control connection.";
            break;
        case 225:
            return @"Data connection open; no transfer in progress.";
            break;
        case 226:
            return @"Closing data connection. Requested file action successful (for example, file transfer or file abort).";
            break;
        case 227:
            return @"Entering Passive Mode.";
            break;
        case 230:
            return @"User logged in, proceed. Logged out if appropriate.";
            break;
        case 250:
            return @"Requested file action okay, completed.";
            break;
        case 257:
            return @"\"PATHNAME\" created.";
            break;
        case 331:
            return @"User name okay, need password.";
            break;
        case 332:
            return @"Need account for login.";
            break;
        case 350:
            return @"Requested file action pending further information.";
            break;
        case 421:
            return @"Service not available, closing control connection.This may be a reply to any command if the service knows it must shut down.";
            break;
        case 425:
            return @"Can't open data connection.";
            break;
        case 426:
            return @"Connection closed; transfer aborted.";
            break;
        case 450:
            return @"Requested file action not taken.";
            break;
        case 451:
            return @"Requested action aborted. Local error in processing.";
            break;
        case 452:
            return @"Requested action not taken. Insufficient storage space in system.File unavailable (e.g., file busy).";
            break;
        case 500:
            return @"Syntax error, command unrecognized. This may include errors such as command line too long.";
            break;
        case 501:
            return @"Syntax error in parameters or arguments.";
            break;
        case 502:
            return @"Command not implemented.";
            break;
        case 503:
            return @"Bad sequence of commands.";
            break;
        case 504:
            return @"Command not implemented for that parameter.";
            break;
        case 530:
            return @"Not logged in.";
            break;
        case 532:
            return @"Need account for storing files.";
            break;
        case 550:
            return @"Requested action not taken. File unavailable (e.g., file not found, no access).";
            break;
        case 551:
            return @"Requested action aborted. Page type unknown.";
            break;
        case 552:
            return @"Requested file action aborted. Exceeded storage allocation (for current directory or dataset).";
            break;
        case 553:
            return @"Requested action not taken. File name not allowed.";
            break;
        default:
            return @"Unknown";
            break;
    }
}

@end



@interface LxResourceListFTPRequest : LxFTPRequest

@property (nonatomic,strong) NSMutableData * listData;

@end

@implementation LxResourceListFTPRequest

- (instancetype)initPrivate
{
    self = [super initPrivate];
    if (self) {
        self.listData = [[NSMutableData alloc]init];
    }
    return self;
}

- (BOOL)start
{
    if (self.serverURL == nil) {
        return NO;
    }
    
    self.readStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, (__bridge CFURLRef)self.serverURL);
    
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPUserName, (__bridge CFTypeRef)self.username);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPPassword, (__bridge CFTypeRef)self.password);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanFalse);
    
    Boolean supportsAsynchronousNotification = CFReadStreamSetClient(
                                                 self.readStream,
                                                 kCFStreamEventNone|
                                                 kCFStreamEventOpenCompleted|
                                                 kCFStreamEventHasBytesAvailable|
                                                 kCFStreamEventCanAcceptBytes|
                                                 kCFStreamEventErrorOccurred|
                                                 kCFStreamEventEndEncountered,
                                                 resourceListReadStreamClientCallBack,
                                                 &_streamClientContext);
    
    if (supportsAsynchronousNotification) {
        
    }
    else {
        return NO;
    }
    
    CFReadStreamScheduleWithRunLoop(self.readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    Boolean openStreamSuccess = CFReadStreamOpen(self.readStream);
    
    if (openStreamSuccess) {
        return YES;
    }
    else {
        return NO;
    }

    return NO;
}

void resourceListReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    LxResourceListFTPRequest * request = (__bridge LxResourceListFTPRequest *)clientCallBackInfo;
    
    switch (type) {
        case kCFStreamEventNone:
        {

        }
            break;
        case kCFStreamEventOpenCompleted:
        {

        }
            break;
        case kCFStreamEventHasBytesAvailable:
        {
            UInt8 buffer[RESOURCE_LIST_BUFFER_SIZE];
            CFIndex bytesRead = CFReadStreamRead(stream, buffer, RESOURCE_LIST_BUFFER_SIZE);
            
            if (bytesRead > 0) {
                [request.listData appendBytes:buffer length:bytesRead];
                request.progressAction(0, (NSInteger)request.listData.length, 0);
            }
            else if (bytesRead == 0) {
                
                NSMutableArray * resourceArray = [NSMutableArray array];
                
                CFIndex totalBytesParsed = 0;
                CFDictionaryRef parsedDictionary;
                
                do
                {
                    CFIndex bytesParsed = CFFTPCreateParsedResourceListing(kCFAllocatorDefault,
                                                                     &((const uint8_t *)request.listData.bytes)[totalBytesParsed],
                                                                     request.listData.length - totalBytesParsed,
                                                                     &parsedDictionary);
                    if (bytesParsed > 0) {
                        if (parsedDictionary != NULL) {
                            [resourceArray addObject:(__bridge id)parsedDictionary];
                            CFRelease(parsedDictionary);
                        }
                        totalBytesParsed += bytesParsed;
                        request.progressAction(0, (NSInteger)totalBytesParsed, 0);
                    }
                    else if (bytesParsed == 0) {
                        break;
                    }
                    else if (bytesParsed == -1) {
                        CFStreamError error = CFReadStreamGetError(stream);
                        request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
                        [request stop];
                        return;
                    }
                } while (true);
                
                request.successAction([NSArray class], [NSArray arrayWithArray:resourceArray]);
                [request stop];
            }
            else {
                CFStreamError error = CFReadStreamGetError(stream);
                request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
                [request stop];
            }
            
        }
            break;
        case kCFStreamEventCanAcceptBytes:
        {

        }
            break;
        case kCFStreamEventErrorOccurred:
        {
            CFStreamError error = CFReadStreamGetError(stream);
            request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
            [request stop];
        }
            break;
        case kCFStreamEventEndEncountered:
        {
            [request stop];
        }
            break;
        default:
            break;
    }
}

- (void)stop
{
    CFReadStreamUnscheduleFromRunLoop(self.readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFReadStreamClose(self.readStream);
    CFRelease(self.readStream);
    self.readStream = nil;
}

@end



@interface LxDownloadFTPRequest : LxFTPRequest

@end

@implementation LxDownloadFTPRequest

- (void)setLocalFileURL:(NSURL *)localFileURL
{
    [super setLocalFileURL:localFileURL];
    
    NSString * localFilePath = self.localFileURL.absoluteString.stringByDeletingScheme;
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localFilePath]) {
        [[NSFileManager defaultManager]createFileAtPath:localFilePath contents:nil attributes:nil];
    }
    
    NSDictionary * fileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:localFilePath error:nil];
    self.finishedSize = [fileAttributes[NSFileSize] integerValue];
}

- (BOOL)start
{
    if (self.localFileURL == nil) {
        return NO;
    }
    
    self.writeStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, (__bridge CFURLRef)self.localFileURL);
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyAppendToFile, kCFBooleanTrue);
    
    Boolean openWriteStreamSuccess = CFWriteStreamOpen(self.writeStream);
    
    if (openWriteStreamSuccess) {
        
    }
    else {
        return NO;
    }
    
    if (self.serverURL == nil) {
        return NO;
    }
    
    self.readStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, (__bridge CFURLRef)self.serverURL);
    
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPUserName, (__bridge CFTypeRef)self.username);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPPassword, (__bridge CFTypeRef)self.password);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanFalse);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyFileCurrentOffset, (__bridge CFTypeRef)@(self.finishedSize));

    
    Boolean supportsAsynchronousNotification = CFReadStreamSetClient(self.readStream,
                                                                     kCFStreamEventNone|
                                                                     kCFStreamEventOpenCompleted|
                                                                     kCFStreamEventHasBytesAvailable|
                                                                     kCFStreamEventCanAcceptBytes|
                                                                     kCFStreamEventErrorOccurred|
                                                                     kCFStreamEventEndEncountered,
                                                                     downloadReadStreamClientCallBack,
                                                                     &_streamClientContext);
    
    if (supportsAsynchronousNotification) {
        
        CFReadStreamScheduleWithRunLoop(self.readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    else {
        return NO;
    }
    
    Boolean openReadStreamSuccess = CFReadStreamOpen(self.readStream);
    
    if (openReadStreamSuccess) {
        
        return YES;
    }
    else {
        return NO;
    }
    
    return NO;
}

void downloadReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    LxDownloadFTPRequest * request = (__bridge LxDownloadFTPRequest *)clientCallBackInfo;
    
    switch (type) {
        case kCFStreamEventNone:
        {
            
        }
            break;
        case kCFStreamEventOpenCompleted:
        {
            CFNumberRef resourceSizeNumber = CFReadStreamCopyProperty(stream, kCFStreamPropertyFTPResourceSize);
            
            if (resourceSizeNumber) {
                
                long long resourceSize = 0;
                CFNumberGetValue(resourceSizeNumber, kCFNumberLongLongType, &resourceSize);
                request.fileTotalSize = (NSInteger)resourceSize;
                
                CFRelease(resourceSizeNumber);
                resourceSizeNumber = nil;
            }
            
            if (request.finishedSize >= request.fileTotalSize) {
                request.successAction([NSString class], request.localFileURL.absoluteString.stringByDeletingScheme);
                [request stop];
            }
        }
            break;
        case kCFStreamEventHasBytesAvailable:
        {
            UInt8 buffer[DOWNLOAD_BUFFER_SIZE];
            CFIndex bytesRead = CFReadStreamRead(stream, buffer, DOWNLOAD_BUFFER_SIZE);
            
            if (bytesRead > 0) {
                
                NSInteger bytesOffset = 0;
                do
                {
                    CFIndex bytesWritten = CFWriteStreamWrite(request.writeStream, &buffer[bytesOffset], bytesRead - bytesOffset);
                    if (bytesWritten > 0) {
                        bytesOffset += bytesWritten;
                        request.finishedSize += bytesWritten;
                        request.progressAction(request.fileTotalSize, request.finishedSize, (CGFloat)request.finishedSize/(CGFloat)request.fileTotalSize * 100);
                    }
                    else if (bytesWritten == 0) {
                        break;
                    }
                    else {
                        CFStreamError error = CFReadStreamGetError(stream);
                        request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
                        [request stop];
                        return;
                    }
                    
                } while (bytesRead - bytesOffset > 0);
            }
            else if (bytesRead == 0) {
                
                request.successAction([NSString class], request.localFileURL.absoluteString.stringByDeletingScheme);
                [request stop];
            }
            else {
                CFStreamError error = CFReadStreamGetError(stream);
                request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
                [request stop];
            }
        }
            break;
        case kCFStreamEventCanAcceptBytes:
        {
            
        }
            break;
        case kCFStreamEventErrorOccurred:
        {
            CFStreamError error = CFReadStreamGetError(stream);
            request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
            [request stop];
        }
            break;
        case kCFStreamEventEndEncountered:
        {
            request.successAction([NSString class], request.localFileURL.absoluteString.stringByDeletingScheme);
            [request stop];
        }
            break;
        default:
            break;
    }
}

- (void)stop
{
    CFReadStreamUnscheduleFromRunLoop(self.readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFReadStreamClose(self.readStream);
    CFRelease(self.readStream);
    self.readStream = nil;
    
    CFWriteStreamClose(self.writeStream);
    CFRelease(self.writeStream);
    self.writeStream = nil;
}

@end



@interface LxUploadFTPRequest : LxFTPRequest

@end

@implementation LxUploadFTPRequest

- (void)setLocalFileURL:(NSURL *)localFileURL
{
    [super setLocalFileURL:localFileURL];
    
    NSError * error = nil;
    
    NSDictionary * fileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:self.localFileURL.absoluteString.stringByRemovingPercentEncoding.stringByDeletingScheme error:&error];
    self.fileTotalSize = [fileAttributes[NSFileSize] integerValue];
}

- (BOOL)start
{
    if (self.localFileURL == nil) {
        return NO;
    }
    
    self.readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, (__bridge  CFURLRef)self.localFileURL);
    
    Boolean openReadStreamSuccess = CFReadStreamOpen(self.readStream);
    
    if (openReadStreamSuccess) {

    }
    else {
        return NO;
    }
    
    if (self.serverURL == nil) {
        return NO;
    }
    
    self.writeStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, (__bridge CFURLRef)self.serverURL);
    
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyFTPUserName, (__bridge CFTypeRef)self.username);
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyFTPPassword, (__bridge CFTypeRef)self.password);
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyFTPAttemptPersistentConnection, kCFBooleanFalse);
//    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
//    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyFileCurrentOffset, <#CFTypeRef propertyValue#>)
    
    Boolean supportsAsynchronousNotification = CFWriteStreamSetClient(self.writeStream,
                                                                      kCFStreamEventNone|
                                                                      kCFStreamEventOpenCompleted|
                                                                      kCFStreamEventHasBytesAvailable|
                                                                      kCFStreamEventCanAcceptBytes|
                                                                      kCFStreamEventErrorOccurred|
                                                                      kCFStreamEventEndEncountered,
                                                                      uploadWriteStreamClientCallBack,
                                                                      &_streamClientContext);
    
    if (supportsAsynchronousNotification) {
        
        CFWriteStreamScheduleWithRunLoop(self.writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    else {
        return NO;
    }
    
    Boolean openWriteStreamSuccess = CFWriteStreamOpen(self.writeStream);
    
    if (openWriteStreamSuccess) {
        
        return YES;
    }
    else {
        return NO;
    }
    
    return NO;
}

void uploadWriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    LxUploadFTPRequest * request = (__bridge LxUploadFTPRequest *)clientCallBackInfo;
    
    switch (type) {
        case kCFStreamEventNone:
        {
        
        }
            break;
        case kCFStreamEventOpenCompleted:
        {

        }
            break;
        case kCFStreamEventHasBytesAvailable:
        {
            
        }
            break;
        case kCFStreamEventCanAcceptBytes:
        {
            UInt8 buffer[UPLOAD_BUFFER_SIZE];
            CFIndex bytesRead = CFReadStreamRead(request.readStream, buffer, UPLOAD_BUFFER_SIZE);
            
            if (bytesRead > 0) {
                
                NSInteger bytesOffset = 0;
                do
                {
                    CFIndex bytesWritten = CFWriteStreamWrite(request.writeStream, &buffer[bytesOffset], bytesRead - bytesOffset);
                    if (bytesWritten > 0) {
                        bytesOffset += bytesWritten;
                        request.finishedSize += bytesWritten;
                        request.progressAction(request.fileTotalSize, request.finishedSize, (CGFloat)request.finishedSize/(CGFloat)request.fileTotalSize * 100);
                    }
                    else if (bytesWritten == 0) {
                        break;
                    }
                    else {
                        CFStreamError error = CFWriteStreamGetError(stream);
                        request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
                        [request stop];
                        return;
                    }
                } while (bytesRead - bytesOffset > 0);
            }
            else if (bytesRead == 0) {
                request.successAction([NSString class], request.serverURL.absoluteString);
                [request stop];
            }
            else {
                CFStreamError error = CFWriteStreamGetError(stream);
                request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
                [request stop];
            }
        }
            break;
        case kCFStreamEventErrorOccurred:
        {
            CFStreamError error = CFWriteStreamGetError(stream);
            request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
            [request stop];
        }
            break;
        case kCFStreamEventEndEncountered:
        {
            request.successAction([NSString class], request.serverURL.absoluteString);
            [request stop];
        }
            break;
            
        default:
            break;
    }
}

- (void)stop
{
    CFWriteStreamUnscheduleFromRunLoop(self.writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamClose(self.writeStream);
    CFRelease(self.writeStream);
    self.writeStream = nil;
    
    CFReadStreamClose(self.readStream);
    CFRelease(self.readStream);
    self.readStream = nil;
}

@end



@interface LxCreateResourceFTPRequest : LxFTPRequest

@end

@implementation LxCreateResourceFTPRequest

- (BOOL)start
{
    if (self.serverURL == nil) {
        return NO;
    }
    
    self.writeStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, (__bridge CFURLRef)self.serverURL);
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyFTPUserName, (__bridge CFTypeRef)self.username);
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyFTPPassword, (__bridge CFTypeRef)self.password);
    
    Boolean supportsAsynchronousNotification = CFWriteStreamSetClient(self.writeStream,
                                                                      kCFStreamEventNone|
                                                                      kCFStreamEventOpenCompleted|
                                                                      kCFStreamEventHasBytesAvailable|
                                                                      kCFStreamEventCanAcceptBytes|
                                                                      kCFStreamEventErrorOccurred|
                                                                      kCFStreamEventEndEncountered,
                                                                      createResourceWriteStreamClientCallBack,
                                                                      &_streamClientContext);
    
    if (supportsAsynchronousNotification) {
        CFWriteStreamScheduleWithRunLoop(self.writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    else {
        return NO;
    }
    
    Boolean openWriteStreamSuccess = CFWriteStreamOpen(self.writeStream);
    
    if (openWriteStreamSuccess) {
        return YES;
    }
    else {
        return NO;
    }
    
    return NO;
}

void createResourceWriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    LxCreateResourceFTPRequest * request = (__bridge LxCreateResourceFTPRequest *)clientCallBackInfo;
    
    switch (type) {
        case kCFStreamEventNone:
        {
        
        }
            break;
        case kCFStreamEventOpenCompleted:
        {
            
        }
            break;
        case kCFStreamEventHasBytesAvailable:
        {
            
        }
            break;
        case kCFStreamEventCanAcceptBytes:
        {
            request.successAction([NSString class], request.serverURL.absoluteString);
            [request stop];
        }
            break;
        case kCFStreamEventErrorOccurred:
        {
            CFStreamError error = CFWriteStreamGetError(stream);
            request.failAction((CFStreamErrorDomain)error.domain, (NSInteger)error.error, [request errorMessageOfCode:error.error]);
            [request stop];
        }
            break;
        case kCFStreamEventEndEncountered:
        {
            request.successAction([NSString class], request.serverURL.absoluteString);
            [request stop];
        }
            break;
        default:
            break;
    }
}

- (void)stop
{
    CFWriteStreamUnscheduleFromRunLoop(self.writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamClose(self.writeStream);
    CFRelease(self.writeStream);
    self.writeStream = nil;
}

@end



@interface LxDestoryResourceRequest : LxFTPRequest

@end

@implementation LxDestoryResourceRequest

- (BOOL)start
{
    if (self.serverURL == nil) {
        return NO;
    }
    
    NSString * theWhileServerURLString = [self.serverURL.absoluteString stringDecorateWithUsername:self.username password:self.password];
    
    self.serverURL = [NSURL URLWithString:theWhileServerURLString];
    
    SInt32 errorCode = 0;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    Boolean destroyResourceSuccess = CFURLDestroyResource((__bridge CFURLRef)self.serverURL, &errorCode);
    
#pragma clang diagnostic pop
    
    if (destroyResourceSuccess) {
        
        self.successAction([NSString class], self.serverURL.absoluteString);
        
        return YES;
    }
    else {
        
        self.failAction(0, (NSInteger)errorCode, @"Unknown");
        
        return NO;
    }
    
    return NO;
}

@end



@implementation LxFTPRequest (Create)

+ (LxFTPRequest *)resourceListRequest
{
    return [[LxResourceListFTPRequest alloc]initPrivate];
}

+ (LxFTPRequest *)downloadRequest
{
    return [[LxDownloadFTPRequest alloc]initPrivate];
}

+ (LxFTPRequest *)uploadRequest
{
    return [[LxUploadFTPRequest alloc]initPrivate];
}

+ (LxFTPRequest *)createResourceRequest
{
    return [[LxCreateResourceFTPRequest alloc]initPrivate];
}

+ (LxFTPRequest *)destoryResourceRequest
{
    return [[LxDestoryResourceRequest alloc]initPrivate];
}

@end
