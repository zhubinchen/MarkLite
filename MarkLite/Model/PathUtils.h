//
//  PathUtils.h
//  MarkLite
//
//  Created by zhubch on 7/4/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#ifndef PathUtils_h
#define PathUtils_h

static inline NSString *localWorkspace(){
    return [NSString pathWithComponents:@[documentPath(),@"MarkLite"]];
}

static inline NSString *cloudWorkspace(){
    NSURL *ubiquityURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
    return ubiquityURL.path;
}

#endif /* PathUtils_h */
