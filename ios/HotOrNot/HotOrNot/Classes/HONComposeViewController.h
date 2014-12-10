//
//  HONComposeViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONUserClubVO.h"

@interface HONComposeViewController : HONViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
- (id)initWithClub:(HONUserClubVO *)clubVO;
@end
