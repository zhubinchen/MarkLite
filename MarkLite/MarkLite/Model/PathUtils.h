//
//  PathUtils.h
//  MarkLite
//
//  Created by Bingcheng on 7/4/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#ifndef PathUtils_h
#define PathUtils_h

static inline NSString* localWorkspace(){
    return [NSString pathWithComponents:@[documentPath(),@"MarkLite"]];
}

static inline NSString* dropboxWorkspace(){
    return [NSString pathWithComponents:@[documentPath(),@"Dropbox"]];
}

static inline NSString* cloudWorkspace(){
    NSURL *ubiquityURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
    return ubiquityURL.path.length ? ubiquityURL.path : @"";
}

static inline NSString* newNameFromOldName(NSString *oldName){
    if (oldName.length < 3) {
        return [oldName stringByAppendingString:@"(1)"];
    }
    NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:@"\\([0-9]+\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRange range = [rex rangeOfFirstMatchInString:oldName options:NSMatchingReportCompletion range:NSMakeRange(0, oldName.length)];
    if (range.location == NSNotFound) {
        return [oldName stringByAppendingString:@"(1)"];
    }
    int num = [oldName substringWithRange:NSMakeRange(range.location + 1, range.length - 2)].intValue;
    NSString *numStr = [NSString stringWithFormat:@"(%d)",++num];
    return [oldName stringByReplacingCharactersInRange:range withString:numStr];
}

static inline NSString* validPath(NSString *name) {
    NSArray *arr = [name componentsSeparatedByString:@"."];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:name];
    if (exist) {
        NSLog(@"已经存在");
        NSString *newName;
        if (arr.count > 1) {
            newName = [newNameFromOldName(arr[0]) stringByAppendingPathExtension:arr[1]];
        }else{
            newName = newNameFromOldName(name);
        }
        return validPath(newName);
    }
    return name;
}

#endif /* PathUtils_h */
