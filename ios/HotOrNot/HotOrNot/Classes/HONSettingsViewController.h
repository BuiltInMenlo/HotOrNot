//
//  HONSettingsViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>

typedef enum {
	HONSettingsCellTypeHelp = 0,
	HONSettingsCellTypeNotifications,
	HONSettingsCellTypeChangeUsername,
	HONSettingsCellTypeChangeEmail,
	HONSettingsCellTypeDeleteChallenges,
	HONSettingsCellTypeDeactivate,
	HONSettingsCellTypeReportAbuse,
	HONSettingsCellTypeTermsConditions
} HONSettingsCellType;

typedef enum {
	HONSettingsMailComposerTypeChangeEmail = 0,
	HONSettingsMailComposerTypeReportAbuse
} HONSettingsMailComposerType;

typedef enum {
	HONSettingsAlertTypeNotifications = 0,
	HONSettingsAlertTypeDeleteChallenges,
	HONSettingsAlertTypeDeactivate
} HONSettingsAlertType;


@interface HONSettingsViewController : UIViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@end
