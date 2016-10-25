//
//  EyeView.h
//  MacMorpheus
//
//  Created by emoRaivis on 20.10.2016.
//  Copyright © 2016 emoRaivis. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface EyeView : SCNView

@property (nonatomic, assign) id contents;

@property (nonatomic, assign) float roll;
@property (nonatomic, assign) float pitch;
@property (nonatomic, assign) float yaw;

@end
