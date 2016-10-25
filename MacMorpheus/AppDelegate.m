//
//  AppDelegate.m
//  MacMorpheus
//
//  Created by emoRaivis on 20.10.2016.
//  Copyright © 2016 emoRaivis. All rights reserved.
//

#import "AppDelegate.h"
#import "PSVR.h"
#import "VideoPlayerView.h"

@implementation AppDelegate {
	IBOutlet NSWindow * mainWindow;
}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
	
	NSURL * targetURL = nil;
	VideoPlayerViewProjectionMethod * targetProjectionMethod = nil;
	
//	targetURL = [NSURL fileURLWithPath: [@"~/Dropbox/Projects/MacMorpheus/Test Videos/3d-vertical-180.mp4" stringByExpandingTildeInPath]];
//	targetURL = [NSURL fileURLWithPath: [@"~/Dropbox/Projects/MacMorpheus/Test Videos/3d-horizontal-360.mp4" stringByExpandingTildeInPath]];
//	targetProjectionMethod = [VideoPlayerViewProjectionMethod allProjectionMethods][1];
	
	if(!targetURL) {
		NSOpenPanel * openDialog = [NSOpenPanel openPanel];
		[openDialog setCanChooseFiles: YES];
		[openDialog setAllowedFileTypes: @[@"mp4", @"mov", @"m4v"]];
		[openDialog setAllowsOtherFileTypes: NO];
		
		NSPopUpButton * videoTypeSelector;
		{
			videoTypeSelector = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(0.0, 0.0, 100.0, 44.0) pullsDown: NO];
			videoTypeSelector.menu = [[NSMenu alloc] init];
			
			for(VideoPlayerViewProjectionMethod * projectionMethod in [VideoPlayerViewProjectionMethod allProjectionMethods]) {
				[videoTypeSelector.menu addItemWithTitle: projectionMethod.name action: nil keyEquivalent: @""].representedObject = projectionMethod;
			}
			
			openDialog.accessoryView = videoTypeSelector;
			openDialog.accessoryViewDisclosed = YES;
		}
		
		if([openDialog runModal] != NSModalResponseOK) {
			[NSApp terminate: nil];
		}
		
		targetURL = openDialog.URL;
		targetProjectionMethod = videoTypeSelector.selectedItem.representedObject;
	}
	
	VideoPlayerView * videoPlayerView = [[VideoPlayerView alloc] initWithFrame: mainWindow.contentView.bounds];
	videoPlayerView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
	[mainWindow.contentView addSubview: videoPlayerView];
	[videoPlayerView loadURL: targetURL projectionMethod: targetProjectionMethod];
	[mainWindow makeFirstResponder: videoPlayerView];
	
	[mainWindow setTitleWithRepresentedFilename: targetURL.path];
	[mainWindow makeKeyAndOrderFront: nil];
	
	[videoPlayerView toggleFullscreen];
	
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) sender {
	return YES;
}

@end
