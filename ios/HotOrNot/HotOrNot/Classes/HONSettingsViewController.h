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


typedef NS_OPTIONS(NSUInteger, HONSettingsSectionType) {
	HONSettingsSectionTypeSocial			= 0 << 0,	//>> 1
	HONSettingsSectionTypeNotifications		= 1 << 0,	//>> 2
	HONSettingsSectionTypeLegal				= 1 << 1,	//>> 4
	HONSettingsSectionTypeAppInfo			= 1 << 2	//>> 8
};

typedef NS_ENUM(NSUInteger, HONSettingsCellType) {
	HONSettingsCellTypeShare = 0,
	HONSettingsCellTypeRate,
	
	HONSettingsCellTypeNotifications,
	
	HONSettingsCellTypeSupport,
	HONSettingsCellTypeTermsOfService,
	HONSettingsCellTypePrivacy,
	
	HONSettingsCellTypeVersion
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
