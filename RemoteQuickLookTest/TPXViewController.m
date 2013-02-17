//
//  TPXViewController.m
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13.
//  Copyright (c) 2013 Alexander Zats. All rights reserved.
//

#import "TPXViewController.h"
#import "TPXPreviewController.h"
#import "TPXPreviewItem.h"

@interface TPXViewController () <QLPreviewControllerDelegate, QLPreviewControllerDataSource, AZAPreviewControllerDelegate>
@property (nonatomic, strong) TPXPreviewController *previewController;
@property (nonatomic, strong) NSArray *previewItems;

// UI
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *showQuickLookButton;
@end

@implementation TPXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Remote files
	NSURL *docPreviewItemURL = [NSURL URLWithString:@"http://www.ada.gov/briefs/housebr.doc"];
	TPXPreviewItem *docPreviewItem = [TPXPreviewItem previewItemWithURL:docPreviewItemURL
																  title:@"Microsoft Word"];

	NSURL *pdfPreviewItemURL = [NSURL URLWithString:@"http://www.tug.org/texshowcase/ShowcaseCircular.pdf"];
	TPXPreviewItem *pdfPreviewItem = [TPXPreviewItem previewItemWithURL:pdfPreviewItemURL
																  title:@"PDF"];
	
	// Local files
	NSURL *localImageURL = [[NSBundle mainBundle] URLForResource:@"dribbble_debut" withExtension:@"png"];
	TPXPreviewItem *localImagePreviewItem = [TPXPreviewItem previewItemWithURL:localImageURL
																		 title:@"Local image"];

	NSMutableArray *previewItems = [NSMutableArray arrayWithObjects:docPreviewItem, pdfPreviewItem, localImagePreviewItem, nil];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Fetching list of popular photos from 500px
		NSURL *URL = [NSURL URLWithString:@"https://api.500px.com/v1/photos?feature=popular&image_size=4&consumer_key=LY4KTEfkrtFCI5bH8huv9WIU3HMV0sbMCZxYPOJk"];
		NSData *photos = [NSData dataWithContentsOfURL:URL];
		NSDictionary *response = [NSJSONSerialization JSONObjectWithData:photos options:0 error:nil];
		dispatch_async(dispatch_get_main_queue(), ^{
			// Parsing photos
			for (NSDictionary *photoDictionary in response[@"photos"]) {
				NSString *title = photoDictionary[@"name"];
				NSString *photoURLString = photoDictionary[@"image_url"];
				NSURL *photoURL = [NSURL URLWithString:photoURLString];
				TPXPreviewItem *previewItem = [TPXPreviewItem previewItemWithURL:photoURL
																		   title:title];
				// Adding to the data provider
				[previewItems addObject:previewItem];
			}

			self.previewItems = previewItems;
			
			// Enabling UI
			[self.activityIndicatorView stopAnimating];
			self.showQuickLookButton.enabled = YES;
		});
	});
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)_showPreviewControllerButtonHandler:(id)sender
{
	// preview controller
	TPXPreviewController *previewController = [[TPXPreviewController alloc] init];
	previewController.dataSource = self;
	previewController.delegate = self;
	self.previewController = previewController;
	// navigation controller
	UINavigationController *navigationCOntroller = [[UINavigationController alloc] initWithRootViewController:previewController];
	// presenting
	[self presentViewController:navigationCOntroller
					   animated:YES
					 completion:nil];
}

#pragma mark - QLPreviewControllerDelegate

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return [self.previewItems count];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	return self.previewItems[ index ];
}

#pragma mark - AZAPreviewControllerDelegate

- (void)AZA_previewController:(TPXPreviewController *)controller failedToLoadRemotePreviewItem:(id<QLPreviewItem>)previewItem withError:(NSError *)error
{
	NSString *alertTitle = [NSString stringWithFormat:@"Failed to load file %@", previewItem.previewItemURL];
	[[[UIAlertView alloc] initWithTitle:alertTitle
								message:[error localizedDescription]
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

@end
