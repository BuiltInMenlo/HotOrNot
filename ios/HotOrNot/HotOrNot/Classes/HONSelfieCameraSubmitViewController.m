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

#import "HONSelfieCameraSubmitViewController.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONClubToggleViewCell.h"
#import "HONUserClubVO.h"

@interface HONSelfieCameraSubmitViewController () <HONClubToggleViewCellDelegate>
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSMutableDictionary *submitParams;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@end


@implementation HONSelfieCameraSubmitViewController

- (id)initWithSubmitParameters:(NSDictionary *)submitParams {
	NSLog(@"[:|:] [%@ initWithSubmitParameters] (%@)", self.class, submitParams);
	if ((self = [super init])) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		_submitParams = [submitParams mutableCopy];
		_clubID = [[_submitParams objectForKey:@"club_id"] intValue];
		
		if (_clubID != 0) {
			[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubID withOwnerID:[[_submitParams objectForKey:@"owner_id"] intValue] completion:^(NSDictionary *result) {
				_clubVO = [HONUserClubVO clubWithDictionary:result];
				[_selectedClubs addObject:_clubVO];
			}];
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


#pragma mark - Data Handling


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	[_headerView setTitle: NSLocalizedString(@"select_club", nil)]; //@"Select Club"];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
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
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Back"];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Refresh"];
	[super _goRefresh];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Submit"];
	
	if (_clubVO != nil) {
		if (![_selectedClubs containsObject:_clubVO])
			[_selectedClubs addObject:_clubVO];
	}
	
	if ([_selectedClubs count] == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Club Selected!"
															message:@"You have to choose at least one club to submit your photo into."
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView setTag:0];
		[alertView show];
	
	} else {
//		[[[UIApplication sharedApplication] delegate] performSelector:@selector(changeTabToIndex:) withObject:@1];
	
	
		[HONAppDelegate incTotalForCounter:@"camera"];
		
		for (HONUserClubVO *vo in _selectedClubs) {
			[_submitParams setObject:[@"" stringFromInt:vo.clubID] forKey:@"club_id"];
			
			[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
				if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
					if (_progressHUD == nil)
						_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
					_progressHUD.labelText = @"Error!";
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kHUDErrorTime];
					_progressHUD = nil;
					
				}
			}];
		}
	
		[super _goSubmit];
	}
}

- (void)_goSelectAllToggle {
	[super _goSelectAllToggle];
}


#pragma mark - ClubToggleViewCell Delegates
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO {
	[super clubToggleViewCell:viewCell deselectedClub:userClubVO];
	
	if (_clubVO != nil && userClubVO.clubID == _clubVO.clubID)
		_clubVO = nil;
}

- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO {
	[super clubToggleViewCell:viewCell selectedClub:userClubVO];
}

- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectAllToggled:(BOOL)isSelected {
	[super clubToggleViewCell:viewCell selectAllToggled:isSelected];
}


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
			
			if (_clubVO != nil && _clubVO.clubID == cell.userClubVO.clubID)
				_clubVO = nil;
		}
		
	} else
		[self _goSelectAllToggle];
}

#pragma mark - AlertView Delegates


#pragma mark - Data Manip



@end
