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
			
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSearchHeaderHeight-2)];
		_searchBar.autoresizingMask = self.searchBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
		[_searchBar setImage:[UIImage imageNamed:@"whiteOverlay"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
		//[_searchBar setImage:[UIImage imageNamed:@"whiteOverlay"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
		[_searchBar setImage:[UIImage imageNamed:@"whiteOverlay"] forSearchBarIcon:UISearchBarIconResultsList state:UIControlStateNormal];
		//[_searchBar setImage:[UIImage imageNamed:@"whiteOverlay"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
		_searchBar.tintColor = [UIColor colorWithWhite:0.75 alpha:1.0];
		_searchBar.delegate = self;
		_searchBar.showsCancelButton = NO;
		//_searchBar.backgroundImage = [UIImage imageNamed:@"searchBar_nonActive"];
		_searchBar.keyboardType = UIKeyboardTypeDefault;
		_searchBar.text = @"search for users to snap with…";
		//[_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"whiteOverlay"] forState:UIControlStateNormal];
		[_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self addSubview:_searchBar];
		
		UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchBar_nonActive"]];
		backgroundImageView.frame = CGRectMake(0.0, 0.0, 320.0, kSearchHeaderHeight);
		//[_searchBar addSubview:backgroundImageView];
		//[_searchBar sendSubviewToBack:backgroundImageView];
		
		
//		for (UIView *view in [_searchBar subviews]) {
//			NSLog(@"SEARCH VIEW:[%@]", view);
//			if ([NSStringFromClass([view class]) isEqualToString:@"UISearchBarTextField"]) {
//				for (UIView *view2 in [view subviews]) {
//					NSLog(@"TXT VIEW:[%@]", view2);
//				}
//			}
//		}
		
		
//		for (UIView *view in [_searchBar subviews]) {
//			NSLog(@"SEARCH VIEW:[%@]", view);
//			if ([NSStringFromClass([view class]) isEqualToString:@"UISearchBarBackground"])
//				[_searchBar sendSubviewToBack:view];
//			
//			if ([NSStringFromClass([view class]) isEqualToString:@"UISearchBarTextField"])
//				[_searchBar bringSubviewToFront:view];
//			
//			if ([NSStringFromClass([view class]) isEqualToString:@"UIImageView"] && view != backgroundImageView)
//				[view removeFromSuperview];//[_searchBar sendSubviewToBack:view];
//		}
	}
	
	return (self);
}


- (void)toggleFocus:(BOOL)isFocused {
	if (isFocused)
		[_searchBar becomeFirstResponder];
	
	else {
		[_searchBar resignFirstResponder];
		_searchBar.text = @"search for users to snap with…";
	}
	
	//_searchBar.showsCancelButton = isFocused;
}

- (void)backgroundingReset {
	[_searchBar resignFirstResponder];
	_searchBar.text = @"search for users to snap with…";
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
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
	
	searchBar.text = (_isUser) ? @"@" : @"#";	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SEARCH_TABLE" object:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([searchText isEqualToString:@""])
		searchBar.text = (_isUser) ? @"@" : @"#";
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	searchBar.text = @"search for users to snap with…";
	_searchBar.showsCancelButton = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	//_searchBar.showsCancelButton = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_searchBar.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:(_isUser) ? @"RETRIEVE_USER_SEARCH_RESULTS" : @"RETRIEVE_SUBJECT_SEARCH_RESULTS" object:[searchBar.text substringFromIndex:1]];
}

@end