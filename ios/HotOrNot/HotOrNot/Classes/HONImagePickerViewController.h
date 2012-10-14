//
//  HONImagePickerViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@interface HONImagePickerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithUser:(int)userID;
- (id)initWithSubject:(NSString *)subject;
- (id)initWithChallenge:(HONChallengeVO *)vo;

- (void)showLibrary;
- (void)takePicture;
- (void)closeCamera;
- (void)changeCamera;
@end
