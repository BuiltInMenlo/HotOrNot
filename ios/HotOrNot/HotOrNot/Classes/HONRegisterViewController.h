//
//  HONRegisterViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>

typedef enum {
	HONRegisterErrorTypeUsernameEmailBirthday = 0,
	HONRegisterErrorTypeEmailBirthday,
	HONRegisterErrorTypeUsernameBirthday,
	HONRegisterErrorTypeBirthday,
	HONRegisterErrorTypeUsernameEmail,
	HONRegisterErrorTypeEmail,
	HONRegisterErrorTypeUsername
} HONRegisterErrorType;

@interface HONRegisterViewController : UIViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@end
