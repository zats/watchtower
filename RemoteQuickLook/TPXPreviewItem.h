//
//  TPXPreviewItem.h
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13.
//  Copyright (c) 2013 Alexander Zats. All rights reserved.
//

#import <QuickLook/QuickLook.h>

/*
 Default implementation of QLPreviewItem protocol
 */
@interface TPXPreviewItem : NSObject <QLPreviewItem>

+ (TPXPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title;

@property (readwrite) NSURL *previewItemURL;
@property (readwrite) NSString *previewItemTitle;

@end
