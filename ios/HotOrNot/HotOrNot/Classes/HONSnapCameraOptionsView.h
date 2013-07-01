//
//  HONSnapCameraOptionsView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 6/30/13 @ 10:31 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONSnapCameraOptionsViewDelegate;
@interface HONSnapCameraOptionsView : UIView
@property(nonatomic, assign) id <HONSnapCameraOptionsViewDelegate> delegate;
@end

@protocol HONSnapCameraOptionsViewDelegate
- (void)cameraOptionsViewCameraRoll:(HONSnapCameraOptionsView *)cameraOptionsView;
- (void)cameraOptionsViewFlipCamera:(HONSnapCameraOptionsView *)cameraOptionsView;
- (void)cameraOptionsViewClose:(HONSnapCameraOptionsView *)cameraOptionsView;
@end