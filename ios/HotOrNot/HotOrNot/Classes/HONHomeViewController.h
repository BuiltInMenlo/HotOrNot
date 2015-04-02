//
//  HONHomeViewController.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONViewController.h"

typedef NS_ENUM(NSUInteger, HONHomeAlertViewType) {
	HONHomeAlertViewTypeFlag = 0,
	HONHomeAlertViewTypeCompose,
	HONHomeAlertViewTypeJoin,
	HONHomeAlertViewTypeShare,
	HONHomeAlertViewTypeInvite,
	HONHomeAlertViewTypeShowTerms,
	HONHomeAlertViewTypeTermsAgreement,
};




@interface HONHomeViewController : HONViewController <CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate>
@end
