/**
 *  SkinnedInstancingDemoScene.h
 *  SkinnedInstancingDemo
 *
 *  Created by Paritosh Shah on 8/22/14.
 *  Copyright Paritosh Shah 2014. All rights reserved.
 */


#import "CC3Scene.h"

/** A sample application-specific CC3Scene subclass.*/
@interface SkinnedInstancingDemoScene : CC3Scene {
    	CC3Vector _cameraMoveStartLocation;
}

/**
 * Start moving the camera using the feedback from a UIPinchGestureRecognizer.
 *
 * This method is invoked once at the beginning of each pinch gesture.
 * The current location of the camera is cached. Subsequent invocations of the
 * moveCameraBy: method will move the camera relative to this starting location.
 */
-(void) startMovingCamera;

/**
 * Moves the camera using the feedback from a UIPinchGestureRecognizer.
 *
 * Since the specified movement comes from a pinch gesture, it's value will be a
 * scale, where one represents the initial pinch size, zero represents a completely
 * closed pinch, and values larget than one represent an expanded pinch.
 *
 * Taking the initial pinch size to reference the initial camera location, the camera
 * is moved backwards relative to that location as the pinch closes, and forwards as
 * the pinch opens. Movement is linear and relative to the forwardDirection of the camera.
 *
 * This method is invoked repeatedly during a pinching gesture.
 *
 * Note that the pinching does not zoom the camera, although the visual effect is
 * very similar. For this application, moving the camera is more flexible and useful
 * than zooming. But other application might prefer to use the pinch gesture scale
 * to modify the uniformScale or fieldOfView properties of the camera, to perform
 * a true zooming effect.
 */
-(void) moveCameraBy: (CGFloat) aMovement;

/**
 * Stop moving the camera using the feedback from a UIPinchGestureRecognizer.
 *
 * This method is invoked once at the end of each pinch gesture.
 * This method does nothing.
 */
-(void) stopMovingCamera;

@end
