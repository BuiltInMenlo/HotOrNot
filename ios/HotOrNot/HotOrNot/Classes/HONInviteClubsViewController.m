//
//  HONCameraSubmitViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONInviteClubsViewController.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONClubToggleViewCell.h"
#import "HONUserClubVO.h"


@interface HONInviteClubsViewController ()
@property (nonatomic, strong) HONContactUserVO *contactUserVO;
@property (nonatomic, strong) HONTrivialUserVO *trivialUserVO;
@end


@implementation HONInviteClubsViewController

- (id)initWithContactUser:(HONContactUserVO *)contactUserVO {
	NSLog(@"[:|:] [%@ initWithContactUser] (%d - %@)", self.class, contactUserVO.userID, contactUserVO.username);
	if ((self = [super init])) {
		_contactUserVO = contactUserVO;
	}
	
	return (self);
}

- (id)initWithTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"[:|:] [%@ initWithTrivialUser] (%d - %@)", self.class, trivialUserVO.userID, trivialUserVO.username);
	if ((self = [super init])) {
		_trivialUserVO = trivialUserVO;
	}
	
	return (self);
}


#pragma mark - Data Calls


#pragma mark - Data Handling


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	[_headerView setTitle:NSLocalizedString(@"invite_club", nil)];//@"Invite to Club"];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:doneButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goDone {
	
		[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goRefresh {
	[super _goRefresh];
}

- (void)_goSubmit {
	if ([_selectedClubs count] == 0) {
		NSLog(@"******* NON SELECTED ******");
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_nofriends_t", nil)
									message:[NSString stringWithFormat:NSLocalizedString(@"alert_nofriends_m", nil), (_trivialUserVO != nil) ? _trivialUserVO.username : _contactUserVO.fullName]
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
		if (_contactUserVO != nil) {
			for (HONUserClubVO *vo in _selectedClubs) {
				[[HONAPICaller sharedInstance] inviteNonAppUsers:@[_contactUserVO] toClubWithID:vo.clubID withClubOwnerID:vo.ownerID completion:^(NSDictionary *result) {
					[[HONContactsAssistant sharedInstance] writeContactUser:_contactUserVO toInvitedClub:vo];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_TOTAL_UPDATED" object:nil];
				}];

			}
		}
		
		if (_trivialUserVO != nil) {
			for (HONUserClubVO *vo in _selectedClubs) {
				[[HONAPICaller sharedInstance] inviteInAppUsers:@[_trivialUserVO] toClubWithID:vo.clubID withClubOwnerID:vo.ownerID completion:^(NSDictionary *result) {
					[[HONContactsAssistant sharedInstance] writeTrivialUser:_trivialUserVO toInvitedClub:vo];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_TOTAL_UPDATED" object:nil];
				}];
			}
		}
		
		[super _goSubmit];
	}
}

- (void)_goSelectAllToggle {
	[super _goSelectAllToggle];
}


#pragma mark - ClubToggleViewCell Delegates


#pragma mark - TableView DataSource Delegates


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 0) {
		HONClubToggleViewCell *cell = (HONClubToggleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell invertSelected];
		
		
		
		if (cell.isSelected) {
			if (![_selectedClubs containsObject:cell.userClubVO])
				[_selectedClubs addObject:cell.userClubVO];
		
		} else {
			if ([_selectedClubs containsObject:cell.userClubVO])
				[_selectedClubs removeObject:cell.userClubVO];
		}
		
	} else
		[self _goSelectAllToggle];
}


#pragma mark - AlertView Delegates


#pragma mark - Data Manip


@end
