//
//  HONRegisterViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>


typedef NS_ENUM(NSInteger, HONRegisterCheckErrorType) {
	HONRegisterCheckErrorTypeNone		= 0,
	HONRegisterCheckErrorTypeUsername	= 1 << 0,
	HONRegisterCheckErrorTypePhone		= 1 << 1
};

typedef NS_ENUM(NSInteger, HONRegisterErrorType) {
	HONRegisterErrorTypeNone		= 0,
	HONRegisterErrorTypeUsername	= 1 << 0,
	HONRegisterErrorTypePhone		= 1 << 1
};

@interface HONRegisterViewController : UIViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@end
