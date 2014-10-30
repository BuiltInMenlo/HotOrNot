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


typedef NS_ENUM(NSUInteger, HONSettingsCellType) {
	HONSettingsCellTypeSearch = 0,
	HONSettingsCellTypeSupport,
	HONSettingsCellTypeNotifications,
	HONSettingsCellTypeTermsOfService,
//	HONSettingsCellTypePrivacyPolicy,
	HONSettingsCellTypeShareClub,
//	HONSettingsCellTypeRateThisApp,
//	HONSettingsCellTypeNetworkStatus,
	HONSettingsCellTypeVersion
//	HONSettingsCellTypeLogout
};

typedef NS_ENUM(NSUInteger, HONSettingsMailComposerType) {
	HONSettingsMailComposerTypeChangeEmail = 0,
	HONSettingsMailComposerTypeReportAbuse
};

typedef NS_ENUM(NSUInteger, HONSettingsAlertType) {
	HONSettingsAlertTypeNotifications = 0,
	HONSettingsAlertTypeDeleteChallenges,
	HONSettingsAlertTypeDeactivate,
	HONSettingsAlertTypeLogout
};


@interface HONSettingsViewController : HONViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
@end
