//
//  HONHomeViewController.h
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONViewController.h"

typedef NS_ENUM(NSUInteger, HONHomeActionSheetType) {
	HONHomeActionSheetTypeTermsAgreement = 0
};

typedef NS_ENUM(NSUInteger, HONHomeAlertViewType) {
	HONHomeAlertViewTypeFlag = 0,
	HONHomeAlertViewTypeCompose,
	HONHomeAlertViewTypeJoin,
	HONHomeAlertViewTypeShare,
	HONHomeAlertViewTypeInvite,
	HONHomeAlertViewTypeShowTerms,
	HONHomeAlertViewTypeTermsAgreement,
	HONHomeAlertViewTypePurchase
};




@interface HONHomeViewController : HONViewController <CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@end
