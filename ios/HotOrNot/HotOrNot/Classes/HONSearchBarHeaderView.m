//
//  HONSearchBarHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchBarHeaderView.h"


@interface HONSearchBarHeaderView ()
@property (nonatomic, strong) UIImageView *staticBGImageView;
@property (nonatomic, strong) UIImageView *greenBGImageView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchBarHeaderView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isUser = YES;
		
		_staticBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBackground"]];
		_staticBGImageView.userInteractionEnabled = YES;
		_staticBGImageView.alpha = 0.85;
		[self addSubview:_staticBGImageView];
		
		_greenBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 49.0)];
		_greenBGImageView.backgroundColor = [UIColor whiteColor];
		_greenBGImageView.userInteractionEnabled = YES;
		_greenBGImageView.alpha = 0.0;
		[_staticBGImageView addSubview:_greenBGImageView];
		
		_searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(9.0, 11.0, 275.0, 24.0)];
		[_searchTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_searchTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_searchTextField setReturnKeyType:UIReturnKeyDefault];
		[_searchTextField setTextColor:[HONAppDelegate honLightGreyTextColor]];
		[_searchTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_searchTextField.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
		_searchTextField.keyboardType = UIKeyboardTypeAlphabet;
		_searchTextField.text = @"Tap here to search";
		_searchTextField.delegate = self;
		[_staticBGImageView addSubview:_searchTextField];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(277.0, 0.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
//		[_greenBGImageView addSubview:_cancelButton];
	}
	
	return (self);
}


- (void)toggleFocus:(BOOL)isFocused {
	if (isFocused) {
		[_searchTextField becomeFirstResponder];
		[_searchTextField setTextColor:[UIColor whiteColor]];
	
	} else {
		[_searchTextField resignFirstResponder];
		[_searchTextField setTextColor:[HONAppDelegate honLightGreyTextColor]];
	}
	
	_staticBGImageView.alpha = (isFocused) ? 1.0 : 0.85;
	_searchTextField.frame = CGRectMake(9.0, 11.0, 200.0 + ((int)!isFocused * 75), 24.0);
	_searchTextField.text = @"Tap here to search";
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
	
	
	_searchTextField.text = @"Tap here to search";
	[_searchTextField setTextColor:[HONAppDelegate honLightGreyTextColor]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_greenBGImageView.alpha = 0.0;
		_staticBGImageView.alpha = 0.85;
	}];
	
	_searchTextField.frame = CGRectMake(9.0, 11.0, 275.0, 24.0);
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
	
	[self.delegate searchBarHeaderCancel:self];
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	[_searchTextField resignFirstResponder];
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Search - %@ Search", (_isUser) ? @"User" : @"Hashtag"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  _searchTextField.text, @"query", nil]];
	
	if (![_searchTextField.text isEqualToString:@"@"] && ![_searchTextField.text isEqualToString:@"search for users to snap with…"])
		[self.delegate searchBarHeader:self enteredSearch:[_searchTextField.text substringFromIndex:1]];//[[NSNotificationCenter defaultCenter] postNotificationName:(_isUser) ? @"RETRIEVE_USER_SEARCH_RESULTS" : @"RETRIEVE_SUBJECT_SEARCH_RESULTS" object:[_searchTextField.text substringFromIndex:1]];
	
	else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_greenBGImageView.alpha = 0.0;
			_staticBGImageView.alpha = 0.85;
		}];
		
		_searchTextField.text = @"Tap here to search";
		_searchTextField.frame = CGRectMake(9.0, 11.0, 275.0, 24.0);
		[_searchTextField setTextColor:[HONAppDelegate honLightGreyTextColor]];
		[self.delegate searchBarHeaderCancel:self];
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
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
	
	textField.text = @"";
	textField.frame = CGRectMake(9.0, 11.0, 200.0, 24.0);
	[_searchTextField setTextColor:[HONAppDelegate honGreyTextColor]];
	[self.delegate searchBarHeaderFocus:self];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SEARCH_TABLE" object:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {	
	if ([textField.text isEqualToString:@""])
		textField.text = @"";
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
}

@end
