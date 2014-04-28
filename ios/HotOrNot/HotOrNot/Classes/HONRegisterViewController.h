//
//  HONRegisterViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>


typedef enum {
	HONRegisterCheckErrorTypeNone		= 0,
	HONRegisterCheckErrorTypeUsername	= 1 << 0,
	HONRegisterCheckErrorTypePhone		= 1 << 1
} HONRegisterCheckErrorType;

typedef enum {
	HONRegisterErrorTypeNone		= 0,
	HONRegisterErrorTypeUsername	= 1 << 0,
	HONRegisterErrorTypePassword	= 1 << 1,
	HONRegisterErrorTypePhone		= 1 << 2
} HONRegisterErrorType;

@interface HONRegisterViewController : UIViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@end
