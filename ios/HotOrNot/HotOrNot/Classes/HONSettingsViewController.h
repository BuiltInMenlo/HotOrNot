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
	HONSettingsSectionTypeLocations			= 0 << 0,	//>> 0
	HONSettingsSectionTypeSocial			= 1 << 0,	//>> 1
	HONSettingsSectionTypeNotifications		= 1 << 1,	//>> 2
	HONSettingsSectionTypeLegal				= 1 << 2,	//>> 4
	HONSettingsSectionTypeAppInfo			= 1 << 3	//>> 8
};

typedef NS_ENUM(NSUInteger, HONSettingsCellType) {
	HONSettingsCellTypeLocation		= 0,	//> 0 + (0 << 0)
	
	HONSettingsCellTypeShare,				//> 0 + (1 << 0)
	HONSettingsCellTypeRate,				//> 1 + (1 << 0)
	
	HONSettingsCellTypeNotifications,		//> 0 + (1 << 1)
	
	HONSettingsCellTypeSupport,				//> 0 + (1 << 2)
	HONSettingsCellTypeTermsOfService,		//> 1 + (1 << 2)
	HONSettingsCellTypePrivacy,				//> 2 + (1 << 2)
	
	HONSettingsCellTypeVersion				//> 0 + (1 << 3)
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
