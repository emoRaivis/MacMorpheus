//
//  VideoPlayerView.m
//  MacMorpheus
//
//  Created by emoRaivis on 21.10.2016.
//  Copyright © 2016 emoRaivis. All rights reserved.
//

#import "VideoPlayerView.h"

// ----

#import "PSVR.h"

// ----

#import <SceneKit/SceneKit.h>

// ----

@implementation VideoPlayerView {
	EyeView * leftView;
	EyeView * rightView;
	
	AVPlayer * player;
}

- (id) initWithFrame: (NSRect) frameRect {
	if((self = [super initWithFrame: frameRect])) {
		
		NSRect r = self.bounds;
		r.size.width /= 2.0;
		leftView = [[EyeView alloc] initWithFrame: r];
		leftView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable | NSViewMaxXMargin);
		[self addSubview: leftView];
		
		r.origin.x += r.size.width;
		rightView = [[EyeView alloc] initWithFrame: r];
		rightView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin);
		[self addSubview: rightView];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(psvrDataReceivedNotification:)
													 name: PSVRDataReceivedNotification
												   object: [PSVR sharedInstance]];
		
	}
	return self;
}

- (void) loadURL: (NSURL *) movieURL projectionMethod: (VideoPlayerViewProjectionMethod *) projectionMethod {
	if(player) {
		return;
	}
	
	_URL = movieURL;
	_projectionMethod = projectionMethod;
	
	player = [AVPlayer playerWithURL: _URL];
	[player addObserver: self forKeyPath: @"currentItem.presentationSize" options: 0 context: 0];
	[player play];

}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context {
	if(object == player) {
		if([keyPath isEqualToString: @"currentItem.presentationSize"]) {
			if(player.status == AVPlayerStatusReadyToPlay) {
				
				CGSize contentSize = player.currentItem.presentationSize;
				
				for(int i = 0; i < 2; i++) {
				
					AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer: player];
					playerLayer.videoGravity = AVLayerVideoGravityResize;
					playerLayer.frame = CGRectMake(0,0, contentSize.width, contentSize.height);
					
					CALayer * eyeViewLayer = [CALayer layer];
					eyeViewLayer.backgroundColor = [NSColor darkGrayColor].CGColor;
					
					EyeView * targetEyeView = (i == 0 ? leftView : rightView);
					_projectionMethod.eyeLayerHandler(eyeViewLayer, i, contentSize, playerLayer, targetEyeView);

					[eyeViewLayer addSublayer: playerLayer];
					
					targetEyeView.contents = eyeViewLayer;
					
				}
			}
		}
	}
}

- (void) toggleFullscreen {
	if([self isInFullScreenMode]) {
		[self exitFullScreenModeWithOptions: @{}];
		[NSCursor unhide];
	} else {
		[self enterFullScreenMode: [PSVR screen] withOptions: @{
			NSFullScreenModeAllScreens: @(NO)
		}];
		[NSCursor hide];
	}
}

- (void) advancePlaybackBySeconds: (int) sec {
	[player seekToTime: CMTimeAdd(player.currentTime, CMTimeMake(sec, 1)) toleranceBefore: kCMTimeZero toleranceAfter: kCMTimeZero];
}

- (void) keyUp: (NSEvent *) event {
	if(event.keyCode == 53) { // ESC
		if([self isInFullScreenMode]) {
			[self toggleFullscreen];
		} else {
			[self.window close];
		}
	} else if(event.keyCode == 36) { // ENTER
		[self toggleFullscreen];
	} else if(event.keyCode == 49) { // SPACE
		if (player.rate != 0 && player.error == nil) {
			[player pause];
		} else {
			[player play];
		}
	} else if(event.keyCode == 124) { // RIGHT
		
		[self advancePlaybackBySeconds: 15];
		
	} else if(event.keyCode == 123) { // LEFT
		
		[self advancePlaybackBySeconds: -15];
	
	} else if(event.keyCode == 34) { // i
		
		leftView.showsStatistics = !leftView.showsStatistics;
		rightView.showsStatistics = leftView.showsStatistics;
	
	} else if(event.keyCode == 15) { // r
	
		leftView.yaw = 0;
		leftView.pitch = 0;
		leftView.roll = 0;
		[self syncRightCameraFromLeft];
		
	} else {
	
		NSLog(@"Key Down: %d", event.keyCode);
		
	}
}

- (void) mouseDragged: (NSEvent *) event {
	float speed = 0.3;
	
	leftView.yaw += (event.deltaX * speed);
	leftView.pitch += (event.deltaY * speed);
	
	[self syncRightCameraFromLeft];
}

- (void) psvrDataReceivedNotification: (NSNotification *) notification {
	PSVRData * data = notification.userInfo[PSVRDataReceivedNotificationDataKey];
	
	float accelerationCoef = 0.00003125;
	
	leftView.yaw += (data.yawAcceleration * accelerationCoef);
	leftView.pitch += (data.pitchAcceleration * accelerationCoef);
//	leftView.roll += (data.rollAcceleration * accelerationCoef);
	
	[self syncRightCameraFromLeft];
}

- (void) syncRightCameraFromLeft {
	rightView.yaw = leftView.yaw;
	rightView.pitch = leftView.pitch;
	rightView.roll = leftView.roll;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end

// ----

@implementation VideoPlayerViewProjectionMethod

+ (NSArray *) allProjectionMethods {
	
	static NSArray * projectionMethods = nil;
	
	if(!projectionMethods) {
		
		projectionMethods = @[
				
//			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"2D Regular" eyeLayerHandler: nil],
//			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"2D 180° Regular" eyeLayerHandler: nil],
//			// --
//
//			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"3D Horizontal (Stacked)" eyeLayerHandler: nil],
//			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"3D 180° Horizontal (Stacked)" eyeLayerHandler: nil],
//			// --
//			
//			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"3D Vertical (Side By Side)" eyeLayerHandler: nil],
//			// --
//			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"3D 360° Vertical (Side By Side)" eyeLayerHandler: nil],

			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"2D 360° Regular" eyeLayerHandler: ^(CALayer * eyeLayer, int eye, CGSize contentSize, AVPlayerLayer * playerLayer, EyeView * eyeView) {
			
				CGRect eyeFrame = CGRectMake(0, 0, contentSize.width, contentSize.height);
				eyeLayer.frame = eyeFrame;
				
				eyeView.projectionTransform = SCNMatrix4MakeRotation(M_PI, 0, 1, 0);;
			
			}],
			
			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"3D 360° Horizontal (Stacked)" eyeLayerHandler: ^(CALayer * eyeLayer, int eye, CGSize contentSize, AVPlayerLayer * playerLayer, EyeView * eyeView) {
				
				CGRect eyeFrame = CGRectMake(0, 0, contentSize.width, round(contentSize.height / 2.0));
				if(eye == 1) {
					eyeFrame.origin.y += eyeFrame.size.height;
				}
				eyeLayer.frame = eyeFrame;
				
				eyeView.projectionTransform = SCNMatrix4MakeRotation(M_PI, 0, 1, 0);;
				
			}],
			
			[VideoPlayerViewProjectionMethod projectionMethodWithName: @"3D 180° Vertical (Side By Side)" eyeLayerHandler: ^(CALayer * eyeLayer, int eye, CGSize contentSize, AVPlayerLayer * playerLayer, EyeView * eyeView) {
				
				CGRect eyeFrame = CGRectMake(0, 0, contentSize.width, contentSize.height);
				if(eye == 1) {
					CGRect playerFrame = playerLayer.frame;
					playerFrame.origin.x -= round(eyeFrame.size.width / 2.0);
					playerLayer.frame = playerFrame;
				} else {
					CALayer * maskLayer = [CALayer layer];
					maskLayer.backgroundColor = [NSColor redColor].CGColor;
					maskLayer.frame = CGRectMake(0, 0, (contentSize.width / 2.0), contentSize.height);
					playerLayer.mask = maskLayer;
				}
				eyeLayer.frame = eyeFrame;

				eyeView.projectionTransform = SCNMatrix4MakeRotation(M_PI / 2.0, 0, 1, 0);
				
/*
				CGRect eyeFrame = CGRectMake(0, 0, round(contentSize.width / 2.0), contentSize.height);
				if(eye == 1) {
					CGRect playerFrame = playerLayer.frame;
					playerFrame.origin.x -= eyeFrame.size.width;
					playerLayer.frame = playerFrame;
				}
				eyeLayer.frame = eyeFrame;
*/
				
			}]
			
		];
		
	}
	
	return projectionMethods;
}

- (instancetype) initWithName: (NSString *) name eyeLayerHandler: (void (^)(CALayer * eyeLayer, int eye, CGSize contentSize, AVPlayerLayer * playerLayer, EyeView * eyeView)) eyeLayerHandler {
	if((self = [super init])) {
		_name = name;
		_eyeLayerHandler = eyeLayerHandler;
	}
	return self;
}

+ (instancetype) projectionMethodWithName: (NSString *) name eyeLayerHandler: (void (^)(CALayer * eyeLayer, int eye, CGSize contentSize, AVPlayerLayer * playerLayer, EyeView * eyeView)) eyeLayerHandler {
	return [[self alloc] initWithName: name eyeLayerHandler: eyeLayerHandler];
}

@end

// ----
