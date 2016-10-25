//
//  VideoPlayerView.h
//  MacMorpheus
//
//  Created by emoRaivis on 21.10.2016.
//  Copyright © 2016 emoRaivis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

// ----

@class VideoPlayerViewProjectionMethod;

// ----

@interface VideoPlayerView : NSView

- (void) loadURL: (NSURL *) movieURL projectionMethod: (VideoPlayerViewProjectionMethod *) projectionMethod;
- (void) toggleFullscreen;

@property (nonatomic, readonly) NSURL * URL;
@property (nonatomic, readonly) VideoPlayerViewProjectionMethod * projectionMethod;

@end

// ----

@interface VideoPlayerViewProjectionMethod : NSObject

+ (NSArray<VideoPlayerViewProjectionMethod *> *) allProjectionMethods;

+ (instancetype) projectionMethodWithName: (NSString *) name
						  eyeLayerHandler: (void (^)(CALayer * eyeLayer, int eye, CGSize contentSize, AVPlayerLayer * playerLayer)) eyeLayerHandler;

@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) void (^eyeLayerHandler)(CALayer * eyeLayer, int eye, CGSize contentSize, AVPlayerLayer * playerLayer);

@end

// ----

