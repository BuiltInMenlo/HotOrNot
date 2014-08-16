//
//  HONClubCoverCameraViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/31/2014 @ 20:54 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"

@class HONClubCoverCameraViewController;
@protocol HONClubCoverCameraViewControllerDelegate <NSObject>
- (void)clubCoverCameraViewController:(HONClubCoverCameraViewController *)viewController didFinishProcessingImage:(UIImage *)image withPrefix:(NSString *)imagePrefix;
@optional
- (void)clubCoverCameraViewController:(HONClubCoverCameraViewController *)viewController didBeginUploadWithImagePrefix:(NSString *)imagePrefix;
@end

@interface HONClubCoverCameraViewController : HONViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, assign) id <HONClubCoverCameraViewControllerDelegate> delegate;
@end
