//
//  HONSearchBarHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchBarHeaderView.h"


@interface HONSearchBarHeaderView() <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *staticBGImageView;
@property (nonatomic, strong) UIImageView *greenBGImageView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchBarHeaderView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isUser = YES;
		
		_staticBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBackground"]];
		_staticBGImageView.userInteractionEnabled = YES;
		_staticBGImageView.alpha = 0.85;
		[self addSubview:_staticBGImageView];
		
		_greenBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBackgroundGreen"]];
		_greenBGImageView.userInteractionEnabled = YES;
		_greenBGImageView.alpha = 0.0;
		[_staticBGImageView addSubview:_greenBGImageView];
		
		_searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(39.0, 11.0, 275.0, 24.0)];
		[_searchTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_searchTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_searchTextField setReturnKeyType:UIReturnKeyDefault];
		[_searchTextField setTextColor:[UIColor whiteColor]];
		[_searchTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_searchTextField.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
		_searchTextField.keyboardType = UIKeyboardTypeAlphabet;
		//_searchTextField.text = NSLocalizedString(@"search_placeHolder", nil);
		_searchTextField.delegate = self;
		[_staticBGImageView addSubview:_searchTextField];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[_greenBGImageView addSubview:_cancelButton];
	}
	
	return (self);
}


- (void)toggleFocus:(BOOL)isFocused {
	if (isFocused)
		[_searchTextField becomeFirstResponder];
	
	else
		[_searchTextField resignFirstResponder];
	
	_staticBGImageView.alpha = (isFocused) ? 1.0 : 0.85;
	_searchTextField.frame = CGRectMake(39.0, 11.0, 200.0 + ((int)!isFocused * 75), 24.0);
	_searchTextField.text = @"";//NSLocalizedString(@"search_placeHolder", nil);
	[UIView animateWithDuration:0.25 animations:^(void) {
		_greenBGImageView.alpha = (int)isFocused;
	}];
}

- (void)backgroundingReset {
	[self _goCancel];
}


#pragma mark - Navigation
- (void)_goCancel {
	[_searchTextField resignFirstResponder];
	
	[[Mixpanel sharedInstance] track:@"Search - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	_searchTextField.text = @"";//NSLocalizedString(@"search_placeHolder", nil);
	[UIView animateWithDuration:0.25 animations:^(void) {
		_greenBGImageView.alpha = 0.0;
		_staticBGImageView.alpha = 0.85;
	}];
	
	_searchTextField.frame = CGRectMake(39.0, 11.0, 275.0, 24.0);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	[_searchTextField resignFirstResponder];
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Search - %@ Search", (_isUser) ? @"User" : @"Hashtag"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  _searchTextField.text, @"query", nil]];
	
	if (![_searchTextField.text isEqualToString:@"@"] && ![_searchTextField.text isEqualToString:@"search for users to snap with…"])
		[[NSNotificationCenter defaultCenter] postNotificationName:(_isUser) ? @"RETRIEVE_USER_SEARCH_RESULTS" : @"RETRIEVE_SUBJECT_SEARCH_RESULTS" object:[_searchTextField.text substringFromIndex:1]];
	
	else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_greenBGImageView.alpha = 0.0;
			_staticBGImageView.alpha = 0.85;
		}];
		
		_searchTextField.text = @"";//NSLocalizedString(@"search_placeHolder", nil);
		_searchTextField.frame = CGRectMake(39.0, 11.0, 275.0, 24.0);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
	}
}


#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_cancelButton.alpha = 0.0;
	_cancelButton.hidden = NO;
	
	[[Mixpanel sharedInstance] track:@"Search - Clicked"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_staticBGImageView.alpha = 1.0;
		_greenBGImageView.alpha = 1.0;
		_cancelButton.alpha = 1.0;
	}];
	
	textField.text = (_isUser) ? @"@" : @"#";
	textField.frame = CGRectMake(39.0, 11.0, 200.0, 24.0);
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
