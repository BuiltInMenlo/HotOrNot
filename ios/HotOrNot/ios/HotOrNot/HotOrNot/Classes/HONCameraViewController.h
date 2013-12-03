//
//  HONCameraViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "HONChallengeVO.h"

@interface HONCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewAccessibilityDelegate> {
	UIScrollView *_scrollView;
	UIImageView *_imageView;
	NSMutableArray *_assets;
}

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

- (id)initWithUser:(int)userID;
- (id)initWithSubject:(NSString *)subject;
- (id)initWithSubject:(NSString *)subject withFriendID:(NSString *)fbID;
- (id)initWithChallenge:(HONChallengeVO *)vo;
- (id)initWithSubject:(NSString *)subject withUser:(int)userID;

- (void)changeFlash:(id)sender;
- (void)changeCamera;
- (void)showLibrary;

- (void)showCamera;
- (void)takePicture;

@end
