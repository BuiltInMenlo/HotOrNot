//
//  HONSearchBarHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchBarHeaderView.h"
#import "HONAppDelegate.h"

@interface HONSearchBarHeaderView() <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchBarHeaderView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSearchHeaderHeight)];
		bgImageView.image = [UIImage imageNamed:@"lockedHeaderBackground"];
		[self addSubview:bgImageView];
		
		_isUser = YES;
				
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
		_searchBar.autoresizingMask = self.searchBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
		_searchBar.tintColor = [UIColor colorWithWhite:0.75 alpha:1.0];
		_searchBar.delegate = self;
		_searchBar.showsCancelButton = NO;
		_searchBar.keyboardType = UIKeyboardTypeDefault;
		[_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self addSubview:_searchBar];
	}
	
	return (self);
}


- (void)toggleFocus:(BOOL)isFocused {
	if (isFocused)
		[_searchBar becomeFirstResponder];
	
	else
		[_searchBar resignFirstResponder];
	
	_searchBar.showsCancelButton = isFocused;
}

#pragma mark - Navigation


#pragma mark - Notifications
- (void)_resignSearchBarFocus:(NSNotification *)notification {
	
//	if ([_searchBar isFirstResponder])
//		[_searchBar resignFirstResponder];
}


#pragma mark - SearchBar Delegates
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.showsCancelButton = YES;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	searchBar.text = (_isUser) ? @"" : @"#";	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SEARCH_TABLE" object:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([searchText isEqualToString:@""] && !_isUser)
		searchBar.text = @"#";
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	searchBar.text = @"";
	_searchBar.showsCancelButton = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	_searchBar.showsCancelButton = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:(_isUser) ? @"RETRIEVE_USER_SEARCH_RESULTS" : @"RETRIEVE_SUBJECT_SEARCH_RESULTS" object:searchBar.text];
}

@end
