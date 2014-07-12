//
//  HONCameraSubmitViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
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

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls


#pragma mark - Data Handling


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	[_headerView setTitle:@"Invite"];
	
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

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goDone {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Done"];
	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Refresh"];
	[super _goRefresh];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Submit"];
	
	[super _goSubmit];
	
	if (_trivialUserVO != nil) {
		
	}
	
	
	if (_contactUserVO != nil) {
		
	}
}

- (void)_goSelectAllToggle {
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Create Selfie - Select %@", ([_selectedClubs count] == [_allClubs count]) ? @"None" : @"All"]];
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
		
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Create Selfie - %@elected Club", (cell.isSelected) ? @"S" : @"Des"]
										   withUserClub:cell.userClubVO];
		
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
