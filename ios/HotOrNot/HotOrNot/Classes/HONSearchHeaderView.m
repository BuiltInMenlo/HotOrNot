//
//  HONSearchHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchHeaderView.h"
#import "HONAppDelegate.h"

@interface HONSearchHeaderView() <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *subjectButton;
@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchHeaderView

@synthesize inviteFriendsButton = _inviteFriendsButton;
@synthesize dailyChallengeButton = _dailyChallengeButton;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 71.0)];
		bgImageView.image = [UIImage imageNamed:@"lockedHeaderBackground"];
		[self addSubview:bgImageView];
		
		_isUser = NO;
		
		_inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteFriendsButton.frame = CGRectMake(0.0, 0.0, 91.0, 70.0);
		[_inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_nonActive"] forState:UIControlStateNormal];
		[_inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateHighlighted];
		[self addSubview:_inviteFriendsButton];
		
		_dailyChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_dailyChallengeButton.frame = CGRectMake(91.0, 0.0, 229.0, 70.0);
		[_dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"startDailyChallenge_nonActive"] forState:UIControlStateNormal];
		[_dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"startDailyChallenge_Active"] forState:UIControlStateHighlighted];
		_dailyChallengeButton.titleLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:15];
		[_dailyChallengeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		_dailyChallengeButton.titleEdgeInsets = UIEdgeInsetsMake(10.0, -30.0, -10.0, 30.0);
		[_dailyChallengeButton setTitle:[HONAppDelegate dailySubjectName] forState:UIControlStateNormal];
		[self addSubview:_dailyChallengeButton];
		
		_userButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_userButton.frame = CGRectMake(0.0, 44.0, 160.0, 35.0);
		[_userButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_nonActive"] forState:UIControlStateNormal];
		[_userButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateHighlighted];
		[_userButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateSelected];
		[_userButton addTarget:self action:@selector(_goUser) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_userButton];
		
		_subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_subjectButton.frame = CGRectMake(160.0, 44.0, 160.0, 35.0);
		[_subjectButton setBackgroundImage:[UIImage imageNamed:@"startDailyChallenge_nonActive"] forState:UIControlStateNormal];
		[_subjectButton setBackgroundImage:[UIImage imageNamed:@"startDailyChallenge_Active"] forState:UIControlStateHighlighted];
		[_subjectButton setBackgroundImage:[UIImage imageNamed:@"startDailyChallenge_Active"] forState:UIControlStateSelected];
		[_subjectButton addTarget:self action:@selector(_goSubject) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_subjectButton];
		
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 35.0, 320.0, 44.0)];
		_searchBar.autoresizingMask = self.searchBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
		_searchBar.tintColor = [UIColor colorWithWhite:0.75 alpha:1.0];
		_searchBar.delegate = self;
		_searchBar.showsCancelButton = YES;
		[self addSubview:_searchBar];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goUser {
	_isUser = YES;
	
	[_userButton setSelected:YES];
	[_subjectButton setSelected:NO];
	
	_searchBar.text = @"";
	[_searchBar becomeFirstResponder];
}

- (void)_goSubject {
	_isUser = NO;
	
	[_userButton setSelected:NO];
	[_subjectButton setSelected:YES];
	
	_searchBar.text = @"#";
	[_searchBar becomeFirstResponder];
}

#pragma mark SearchBar Delegates
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	searchBar.text = (_isUser) ? @"" : @"#";
	
	[_userButton setSelected:_isUser];
	[_subjectButton setSelected:!_isUser];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([searchText isEqualToString:@""] && !_isUser)
		searchBar.text = @"#";
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 35.0, 320.0, 44.0);
	}];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 35.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:(_isUser) ? @"SHOW_USER_SEARCH_RESULTS" : @"SHOW_SUBJECT_SEARCH_RESULTS" object:searchBar.text];
}

@end
