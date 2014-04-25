//
//  HONClubCoverCameraViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/31/2014 @ 20:54 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@class HONClubCoverCameraViewController;
@protocol HONClubCoverCameraViewControllerDelegate
- (void)clubCoverCameraViewController:(HONClubCoverCameraViewController *)viewController didFinishProcessingImage:(UIImage *)image withPrefix:(NSString *)imagePrefix;
//- (void)clubCoverCameraViewController:(HONClubCoverCameraViewController *)viewController didBeginUploadWithImagePrefix:(NSString *)imagePrefix;
@end

@interface HONClubCoverCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, assign) id <HONClubCoverCameraViewControllerDelegate> delegate;
@end
