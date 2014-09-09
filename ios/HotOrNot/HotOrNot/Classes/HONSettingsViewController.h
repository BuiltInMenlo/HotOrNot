//
//  HONSettingsViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "HONViewController.h"


typedef NS_ENUM(NSInteger, HONSettingsCellType) {
    HONSettingsCellTypeShareSignupClub = 0,
    HONSettingsCellTypeNotifications,
	HONSettingsCellTypeCopyClub,
    HONSettingsCellTypeRateThisApp,
	//HONSettingsCellTypePrivacyPolicy,
	HONSettingsCellTypeSupport,
    HONSettingsCellTypeTermsOfService,
	//HONSettingsCellTypeNetworkStatus,
	HONSettingsCellTypeLogout
};

typedef NS_ENUM(NSInteger, HONSettingsMailComposerType) {
	HONSettingsMailComposerTypeChangeEmail = 0,
	HONSettingsMailComposerTypeReportAbuse
};

typedef NS_ENUM(NSInteger, HONSettingsAlertType) {
	HONSettingsAlertTypeNotifications = 0,
	HONSettingsAlertTypeDeleteChallenges,
	HONSettingsAlertTypeDeactivate,
	HONSettingsAlertTypeLogout
};


@interface HONSettingsViewController : HONViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@end
