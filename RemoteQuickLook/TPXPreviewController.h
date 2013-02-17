//
//  TPXPreviewController.h
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13.
//  Copyright (c) 2013 Alexander Zats. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@protocol AZAPreviewControllerDelegate;
@interface TPXPreviewController : QLPreviewController
@property (weak) id<AZAPreviewControllerDelegate, QLPreviewControllerDelegate> delegate;
@end

@protocol AZAPreviewControllerDelegate <NSObject>
@optional
/*
 Notifies delegate that remote item can't be loaded
 */
- (void)AZA_previewController:(TPXPreviewController *)controller failedToLoadRemotePreviewItem:(id<QLPreviewItem>)previewItem withError:(NSError *)error;
@end
