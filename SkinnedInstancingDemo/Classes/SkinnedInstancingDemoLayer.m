/**
 *  SkinnedInstancingDemoLayer.m
 *  SkinnedInstancingDemo
 *
 *  Created by Paritosh Shah on 8/22/14.
 *  Copyright Paritosh Shah 2014. All rights reserved.
 */

#import "SkinnedInstancingDemoLayer.h"
#import "SkinnedInstancingDemoScene.h"


@implementation SkinnedInstancingDemoLayer

/**
 * Override to set up your 2D controls and other initial state, and to initialize update processing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) initializeControls {
	[self scheduleUpdate];
}

/**
 * Returns the contained CC3Scene, cast into the appropriate type.
 * This is a convenience method to perform automatic casting.
 */
-(SkinnedInstancingDemoScene*) skinnedScene { return (SkinnedInstancingDemoScene*) self.cc3Scene; }

#pragma mark Updating layer

/**
 * Override to perform set-up activity prior to the scene being opened
 * on the view, such as adding gesture recognizers.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onOpenCC3Layer {

	// Register for tap gestures to select 3D nodes.
	// This layer has child buttons on it. To ensure that those buttons receive their
	// touch events, we set cancelsTouchesInView to NO so that the gesture recognizer
	// allows the touch events to propagate to the buttons.
	// Register for single-finger dragging gestures used to spin the two cubes.
//	UIPanGestureRecognizer* dragPanner = [[UIPanGestureRecognizer alloc]
//										  initWithTarget: self action: @selector(handleDrag:)];
//	dragPanner.minimumNumberOfTouches = 1;
//	dragPanner.maximumNumberOfTouches = 1;
//	[self cc3AddGestureRecognizer: dragPanner];
//    
//	// Register for double-finger dragging to pan the camera.
//	UIPanGestureRecognizer* cameraPanner = [[UIPanGestureRecognizer alloc]
//											initWithTarget: self action: @selector(handleCameraPan:)];
//	cameraPanner.minimumNumberOfTouches = 2;
//	cameraPanner.maximumNumberOfTouches = 2;
//	[self cc3AddGestureRecognizer: cameraPanner];
	
	// Register for double-finger dragging to pan the camera.
	UIPinchGestureRecognizer* cameraMover = [[UIPinchGestureRecognizer alloc]
											 initWithTarget: self action: @selector(handleCameraMove:)];
	[self cc3AddGestureRecognizer: cameraMover];

}

/**
 * Override to perform tear-down activity prior to the scene disappearing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onCloseCC3Layer {}

/**
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, uncomment the following method implementation.
 */
/*
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
 */

/**
 * This handler is invoked when a pinch gesture is recognized.
 *
 * If the pinch starts within a descendant CCNode that wants to capture the touch,
 * such as a menu or button, the gesture is cancelled.
 *
 * The CC3Scene marks the camera location when pinching begins, and is notified
 * as pinching proceeds. It uses the relative scale of the pinch gesture to determine
 * a new location for the camera. Finally, the scene is notified when the pinching
 * gesture finishes.
 *
 * Note that the pinching does not zoom the camera, although the visual effect is
 * very similar. For this application, moving the camera is more flexible and useful
 * than zooming. But other application might prefer to use the pinch gesture scale
 * to modify the uniformScale or fieldOfView properties of the camera, to perform
 * a true zooming effect.
 */
-(void) handleCameraMove: (UIPinchGestureRecognizer*) gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
			if ( [self cc3ValidateGesture: gesture] ) [self.skinnedScene startMovingCamera];
			break;
		case UIGestureRecognizerStateChanged:
			[self.skinnedScene moveCameraBy: gesture.scale];
			break;
		case UIGestureRecognizerStateEnded:
			[self.skinnedScene stopMovingCamera];
			break;
		default:
			break;
	}
}


@end
