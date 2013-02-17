//
//  TPXPreviewController.m
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13.
//  Copyright (c) 2013 Alexander Zats. All rights reserved.
//

#import "TPXPreviewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import "TPXPreviewItem.h"

// As seen in SSToolkit
static NSString *AZAMD5StringFromNSString(NSString *string)
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
	CC_MD5([data bytes], [data length], digest);
	NSMutableString *result = [NSMutableString string];
	for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[result appendFormat: @"%02x", (int)(digest[i])];
	}
	return [result copy];
}

static NSString *AZALocalFilePathForURL(NSURL *URL)
{
	NSString *fileExtension = [URL pathExtension];
	NSString *hashedURLString = AZAMD5StringFromNSString([URL absoluteString]);
	NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"com.zats.RemoteQuickLook"];
	BOOL isDirectory;
	if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
															withIntermediateDirectories:YES
																			 attributes:nil
																				  error:&error];
		if (!isDirectoryCreated) {
			NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
															 reason:@"Failed to crate cache directory"
														   userInfo:@{ NSUnderlyingErrorKey : error }];
			@throw exception;
		}
	}
	NSString *temporaryFilePath = [[cacheDirectory stringByAppendingPathComponent:hashedURLString] stringByAppendingPathExtension:fileExtension];
	return temporaryFilePath;
}


@interface TPXPreviewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, weak) id<QLPreviewControllerDataSource> actualDataSource;
@end

@implementation TPXPreviewController

- (id)init
{
	self = [super init];
	if (!self) {
		return nil;
	}
	
	// Base URL doesn't matter since we're 
	NSURL *baseURL = [NSURL URLWithString:@"http://example.com"];
	self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
	
	return self;
}

#pragma mark - Properties

- (void)setDataSource:(id<QLPreviewControllerDataSource>)dataSource
{
	self.actualDataSource = dataSource;
	[super setDataSource:self];
}

- (id<QLPreviewControllerDataSource>)dataSource
{
	return self.actualDataSource;
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return [self.actualDataSource numberOfPreviewItemsInPreviewController:controller];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	id<QLPreviewItem> originalPreviewItem = [self.actualDataSource previewController:controller previewItemAtIndex:index];
	
	TPXPreviewItem *previewItemCopy = [TPXPreviewItem previewItemWithURL:originalPreviewItem.previewItemURL
																   title:originalPreviewItem.previewItemTitle];
	
	NSURL *originalURL = previewItemCopy.previewItemURL;
	if (!originalURL || [originalURL isFileURL]) {
		return previewItemCopy;
	}

	// If it's a remote file, check cache
	NSString *localFilePath = AZALocalFilePathForURL(originalURL);
	previewItemCopy.previewItemURL = [NSURL fileURLWithPath:localFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
		return previewItemCopy;
	}

	// If it's not a local file, put a placeholder instead
	__block NSInteger capturedIndex = index;
	NSURLRequest *request = [NSURLRequest requestWithURL:originalURL];
	AFHTTPRequestOperation *operation = [self.httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSAssert([responseObject isKindOfClass:[NSData class]], @"Unexpected response: %@", responseObject);
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError *error = nil;
			BOOL didWriteFile = [(NSData *)responseObject writeToFile:localFilePath
															  options:0
																error:&error];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (!didWriteFile) {
					if ([self.delegate respondsToSelector:@selector(AZA_previewController:failedToLoadRemotePreviewItem:withError:)]) {
						[self.delegate AZA_previewController:self
						   failedToLoadRemotePreviewItem:originalPreviewItem
											   withError:error];
					}
					return;
				}
				// FIXME: Sometime remote preview item isn't getting updated
				// When pan gesture isn't finished so that two preview items can be seen at the same time upcomming item isn't getting updated, fixes are very welcome!
				if (controller.currentPreviewItemIndex == capturedIndex) {
					[controller refreshCurrentPreviewItem];
				}
			});
			
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if ([self.delegate respondsToSelector:@selector(AZA_previewController:failedToLoadRemotePreviewItem:withError:)]) {
			[self.delegate AZA_previewController:self
			   failedToLoadRemotePreviewItem:originalPreviewItem
								   withError:error];
		}
	}];
	[self.httpClient enqueueHTTPRequestOperation:operation];
	
	return previewItemCopy;
}

@end
