//
//  HONSearchBarHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchBarHeaderView.h"
#import "HONAppDelegate.h"

@interface HONSearchBarHeaderView() <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchBarHeaderView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSearchHeaderHeight)];
		_bgImageView.image = [UIImage imageNamed:@"searchBar_nonActive"];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		_isUser = YES;
		
		_searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13.0, 220.0, 20.0)];
		//[_searchTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_searchTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_searchTextField setReturnKeyType:UIReturnKeyDefault];
		[_searchTextField setTextColor:[HONAppDelegate honGreyInputColor]];
		[_searchTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_searchTextField.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
		_searchTextField.keyboardType = UIKeyboardTypeAlphabet;
		_searchTextField.text = NSLocalizedString(@"search_placeHolder", nil);
		_searchTextField.delegate = self;
		[_bgImageView addSubview:_searchTextField];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(256.0, -1.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		_cancelButton.hidden = YES;
		[_bgImageView addSubview:_cancelButton];
	}
	
	return (self);
}


- (void)toggleFocus:(BOOL)isFocused {
	if (isFocused)
		[_searchTextField becomeFirstResponder];
	
	else {
		[_searchTextField resignFirstResponder];
		_searchTextField.text = NSLocalizedString(@"search_placeHolder", nil);
	}
	
	//_searchBar.showsCancelButton = isFocused;
}

- (void)backgroundingReset {
	[_searchTextField resignFirstResponder];
	_searchTextField.text = NSLocalizedString(@"search_placeHolder", nil);
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
}


#pragma mark - Navigation
- (void)_goCancel {
	[_searchTextField resignFirstResponder];
	_searchTextField.text = NSLocalizedString(@"search_placeHolder", nil);
	_cancelButton.hidden = YES;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
}

- (void)_onTxtDoneEditing:(id)sender {
	[_searchTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	if (![_searchTextField.text isEqualToString:@"@"] && ![_searchTextField.text isEqualToString:@"search for users to snap with…"])
		[[NSNotificationCenter defaultCenter] postNotificationName:(_isUser) ? @"RETRIEVE_USER_SEARCH_RESULTS" : @"RETRIEVE_SUBJECT_SEARCH_RESULTS" object:[_searchTextField.text substringFromIndex:1]];
}


#pragma mark - Notifications
- (void)_resignSearchBarFocus:(NSNotification *)notification {
	
//	if ([_searchBar isFirstResponder])
//		[_searchBar resignFirstResponder];
}


#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_cancelButton.alpha = 0.0;
	_cancelButton.hidden = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
		_cancelButton.alpha = 1.0;
	}];
	
	textField.text = (_isUser) ? @"@" : @"#";
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SEARCH_TABLE" object:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {	
	if ([textField.text isEqualToString:@""])
		textField.text = (_isUser) ? @"@" : @"#";
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];	
}

@end
