//
//  EyeView.m
//  MacMorpheus
//
//  Created by emoRaivis on 20.10.2016.
//  Copyright © 2016 emoRaivis. All rights reserved.
//

#import "EyeView.h"

@implementation EyeView {
	SCNNode * cameraNode;
	SCNSphere * dome;
}

- (id) initWithFrame: (NSRect) frameRect {
	if((self = [super initWithFrame: frameRect])) {
		
		self.scene = [SCNScene scene];
		
		cameraNode = [SCNNode node];
		cameraNode.camera = [SCNCamera camera];
		cameraNode.camera.yFov = 80;
		[self.scene.rootNode addChildNode: cameraNode];

		dome = [SCNSphere sphereWithRadius: 20.0];
		dome.segmentCount = 480;
		SCNNode * domeNode = [SCNNode nodeWithGeometry: dome];
		domeNode.transform = SCNMatrix4MakeRotation(M_PI, 0, 1, 0);
//		domeNode.transform = SCNMatrix4MakeRotation(M_PI / -2.0, 0, 1, 0);
		[self.scene.rootNode addChildNode: domeNode];
		
	}
	return self;
}

- (void) setContents: (id) contents {
	SCNMaterial * contentMaterial = [SCNMaterial material];
	contentMaterial.cullMode = SCNCullModeFront;
	contentMaterial.diffuse.contents = contents;
	dome.materials = @[contentMaterial];
}

- (id) contents {
	return dome.materials.firstObject.diffuse.contents;
}

- (void) setYaw: (float) yaw {
	_yaw = yaw;
	[self applyCameraTransform];
}

- (void) setPitch: (float) pitch {
	_pitch = pitch;
	[self applyCameraTransform];
}

- (void) setRoll: (float) roll {
	_roll = roll;
	[self applyCameraTransform];
}

- (void) applyCameraTransform {
	
	SCNMatrix4 cameraMatrix = SCNMatrix4Identity;
	
	cameraMatrix = SCNMatrix4Mult(cameraMatrix, SCNMatrix4MakeRotation((_roll * M_PI / 180.0), 0, 0, 1));
	cameraMatrix = SCNMatrix4Mult(cameraMatrix, SCNMatrix4MakeRotation((_pitch * M_PI / 180.0), 1, 0, 0));
	cameraMatrix = SCNMatrix4Mult(cameraMatrix, SCNMatrix4MakeRotation((_yaw * M_PI / 180.0), 0, 1, 0));
	
	cameraNode.transform = cameraMatrix;
}

@end
