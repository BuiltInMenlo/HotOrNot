//
//  HONCreateClubViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/28/2014 @ 19:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"
#import "HONViewController.h"

@class HONCreateClubViewController;
@protocol HONCreateClubViewControllerDelegate <NSObject>
@optional
- (void)createClubViewController:(HONCreateClubViewController *)viewController didCreateClub:(HONUserClubVO*) clubV0;
@end

@interface HONCreateClubViewController : HONViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (nonatomic, assign) id <HONCreateClubViewControllerDelegate> delegate;
@end
