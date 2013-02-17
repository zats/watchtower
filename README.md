#What, why
This is a simple extension over QLPreviewController allowing to display remote files.

I created it primarily because `QLPreviewItem` states that `previewItemURL` must be a file-type URL (local files only).

#Installation

	$ cd your_project
	$ git submodule add git@github.com:zats/watchtower.git Vendor/Watchtower
	$ cd Vendor/Watchtower
	$ git submodule update --init --recursive
	
* Add all the `Watchtower` folder to your project
* Add `QuickLook.framework` to your targets
* Optionally: if you don't use AFNetworking in your project, make sure you've added files from the `Vendor/AFNetworking` folder 

#Usage

	#import "AZAPreviewController.h"

That's it, the rest is exactly like `QLPreviewController`, just specify remote URL instead of local in `QLPreviewItem` instance.

For more details see included project.

#Notes

Class `AZAPreviewItem` simply provides default implementation of `QLPreviewItem` protocol making `previewItemURL` and `previewItemTitle` parameters writable.

If you want to be notified when remote item failed to load you have to implement `AZAPreviewControllerDelegate` corresponding protocol method:

```objective-c
- (void)AZA_previewController:(AZAPreviewController *)controller failedToLoadRemotePreviewItem:(id<QLPreviewItem>)previewItem withError:(NSError *)error
{
	NSString *alertTitle = [NSString stringWithFormat:@"Failed to load file %@", previewItem.previewItemURL];
	NSString *alertMessage = [error localizedDescription];
	[[[UIAlertView alloc] initWithTitle:alertTitle
								message:alertMessage
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}
```


# TODOs

Currently if pan gesture wasn't finished and next item didn't finish loading it might stay in loading state forever, help much appreciated
