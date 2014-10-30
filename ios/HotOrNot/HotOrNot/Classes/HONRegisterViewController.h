//
//  HONRegisterViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>

#import "HONViewController.h"

typedef NS_ENUM(NSUInteger, HONRegisterCheckErrorType) {
	HONRegisterCheckErrorTypeNone		= (0UL << 0),
	HONRegisterCheckErrorTypeUsername	= (1UL << 0),
	HONRegisterCheckErrorTypePhone		= (1UL << 1)
};

typedef NS_ENUM(NSUInteger, HONRegisterErrorType) {
	HONRegisterErrorTypeNone		= (0UL << 0),
	HONRegisterErrorTypeUsername	= (1UL << 0),
	HONRegisterErrorTypePhone		= (1UL << 1)
};

@interface HONRegisterViewController : HONViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@end
