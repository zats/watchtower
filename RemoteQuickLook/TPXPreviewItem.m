//
//  TPXPreviewItem.m
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13.
//  Copyright (c) 2013 Alexander Zats. All rights reserved.
//

#import "TPXPreviewItem.h"

@interface TPXPreviewItem () {
	BOOL _loadingItem;
}
@end

@implementation TPXPreviewItem
@synthesize previewItemURL = _previewItemURL;

+ (TPXPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title
{
	TPXPreviewItem *instance = [[TPXPreviewItem alloc] init];
	instance.previewItemURL = URL;
	instance.previewItemTitle = title;
	return instance;
}

@end
