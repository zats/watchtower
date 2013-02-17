//
//  AZAPreviewItem.m
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13.
//  Copyright (c) 2013 Alexander Zats. All rights reserved.
//

#import "AZAPreviewItem.h"

@interface AZAPreviewItem () {
	BOOL _loadingItem;
}
@end

@implementation AZAPreviewItem
@synthesize previewItemURL = _previewItemURL;

+ (AZAPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title
{
	AZAPreviewItem *instance = [[AZAPreviewItem alloc] init];
	instance.previewItemURL = URL;
	instance.previewItemTitle = title;
	return instance;
}

@end
