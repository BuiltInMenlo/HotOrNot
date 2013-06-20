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
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBackgroundGreen"]];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		_isUser = YES;
		
		_searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 12.0, 294.0, 24.0)];
		//[_searchTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_searchTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_searchTextField setReturnKeyType:UIReturnKeyDefault];
		[_searchTextField setTextColor:[HONAppDelegate honGrey455Color]];
		[_searchTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_searchTextField.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:15];
		_searchTextField.keyboardType = UIKeyboardTypeAlphabet;
		//_searchTextField.text = NSLocalizedString(@"search_placeHolder", nil);
		_searchTextField.delegate = self;
		[_bgImageView addSubview:_searchTextField];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(246.0, 0.0, 74.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"searchCancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"searchCancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		_cancelButton.hidden = YES;
		[_bgImageView addSubview:_cancelButton];
	}
	
	return (self);
}


- (void)toggleFocus:(BOOL)isFocused {
	if (isFocused) {
		[_searchTextField becomeFirstResponder];
		_bgImageView.image = [UIImage imageNamed:@"searchInputBackgroundGreen"];
	
	} else {
		[_searchTextField resignFirstResponder];
		_bgImageView.image = [UIImage imageNamed:@"searchInputBackgroundGreen"];
		_searchTextField.text = @"";//NSLocalizedString(@"search_placeHolder", nil);
	}
	
	//_searchBar.showsCancelButton = isFocused;
}

- (void)backgroundingReset {
	[_searchTextField resignFirstResponder];
	_bgImageView.image = [UIImage imageNamed:@"searchInputBackgroundGreen"];
	_searchTextField.text = @"";//NSLocalizedString(@"search_placeHolder", nil);
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
}


#pragma mark - Navigation
- (void)_goCancel {
	[_searchTextField resignFirstResponder];
	_bgImageView.image = [UIImage imageNamed:@"searchInputBackgroundGreen"];
	_searchTextField.text = @"";//NSLocalizedString(@"search_placeHolder", nil);
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
	
	else {
		_bgImageView.image = [UIImage imageNamed:@"searchInputBackgroundGreen"];
		_searchTextField.text = @"";//NSLocalizedString(@"search_placeHolder", nil);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
	}
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
	
	//_bgImageView.image = [UIImage imageNamed:@"searchInputBackgroundGreen"];
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
