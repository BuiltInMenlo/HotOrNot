//
//  HONClubInviteViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AddressBook/AddressBook.h>

#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

#import "HONClubInviteViewController.h"
#import "HONUserProfileViewController.h"

@interface HONClubInviteViewController ()
@property (nonatomic, strong) NSMutableArray *selectedNonAppContacts;
@property (nonatomic, strong) NSMutableArray *selectedInAppContacts;
@end


@implementation HONClubInviteViewController

- (id)initWithClub:(HONUserClubVO *)userClub {
	if ((self = [super init])) {
		_userClubVO = userClub;
		
		if (_userClubVO == nil) {
			_userClubVO = [HONUserClubVO clubWithDictionary:@{@"id"				: @"32",
															  @"name"			: @"snap_club",
															  @"added"			: @"2014-04-06 21:20:02",
															  @"description"	: @"",
															  @"img"			: @"",
															  @"members"		: @[],
															  @"total_members"	: @"0",
															  @"owner"			: @{@"id"		: @"131249",
																					@"username"	: @"snap",
																					@"avatar"	: @"https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png",
																					@"age"		: @"2001-04-06 00:00:00"},
															  @"pending"		: @[],
															  @"blocked"		: @[]}];
		}
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}



#pragma mark - Data Calls
- (void)_sendClubInvites {
	HONUserClubInviteType userClubInviteType = (HONUserClubInviteTypeInApp * (int)([_selectedInAppContacts count] > 0)) + (HONUserClubInviteTypeNonApp * (int)([_selectedNonAppContacts count] > 0));
	
	if (userClubInviteType == HONUserClubInviteTypeInApp)
		[self _sendInAppUserInvites];
	
	else if (userClubInviteType == HONUserClubInviteTypeNonApp)
		[self _sendNonAppUserInvites];
	
	else
		[self _sendCombinedUserInvites];
}

- (void)_sendCombinedUserInvites {
	[[HONAPICaller sharedInstance] inviteInAppUsers:[_selectedInAppContacts copy] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID inviteNonAppContacts:[_selectedNonAppContacts copy] completion:^(NSObject *result) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}];
}

- (void)_sendInAppUserInvites {
	[[HONAPICaller sharedInstance] inviteInAppUsers:[_selectedInAppContacts copy] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID completion:^(NSObject *result) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}];
}


- (void)_sendNonAppUserInvites {
	[[HONAPICaller sharedInstance] inviteNonAppUsers:[_selectedNonAppContacts copy] toClubWithID:_userClubVO.clubID withClubOwnerID:_userClubVO.ownerID completion:^(NSObject *result) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	[_headerView setTitle:@"Invite Friends"];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:doneButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Invite - Back"
									   withUserClub:_userClubVO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goClose {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Invite - Close"
									   withUserClub:_userClubVO];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goDone {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Invite - Done"
									   withUserClub:_userClubVO];
	[self _sendClubInvites];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Club Invite - No Users Selected " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]
										   withUserClub:_userClubVO];
		
		if (buttonIndex == 1)
			[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
