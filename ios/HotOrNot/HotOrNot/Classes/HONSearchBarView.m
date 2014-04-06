//
//  HONSearchBarView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchBarView.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"

@interface HONSearchBarView ()
@property (nonatomic, strong) UIImageView *staticBGImageView;
@property (nonatomic, strong) UIImageView *greenBGImageView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchBarView

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
		[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
		[_searchTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_searchTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_searchTextField.keyboardType = UIKeyboardTypeAlphabet;
		_searchTextField.text = @"Tap here to search";
		_searchTextField.delegate = self;
		[_staticBGImageView addSubview:_searchTextField];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(257.0, 0.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"xButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"xButton_Active"] forState:UIControlStateHighlighted];
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
		[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
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
	
	_searchTextField.text = @"Tap here to search";
	[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_greenBGImageView.alpha = 0.0;
		_staticBGImageView.alpha = 0.85;
	}];
	
	_searchTextField.frame = CGRectMake(9.0, 11.0, 275.0, 24.0);
	[self.delegate searchBarViewCancel:self];
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	[_searchTextField resignFirstResponder];
	
	if (![_searchTextField.text isEqualToString:@"@"] && ![_searchTextField.text isEqualToString:@"search for users to snap with…"])
		[self.delegate searchBarView:self enteredSearch:_searchTextField.text];
	
	else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_greenBGImageView.alpha = 0.0;
			_staticBGImageView.alpha = 0.85;
		}];
		
		_searchTextField.text = @"Tap here to search";
		_searchTextField.frame = CGRectMake(9.0, 11.0, 275.0, 24.0);
		[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
		[self.delegate searchBarViewCancel:self];
	}
}


#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_cancelButton.alpha = 0.0;
	_cancelButton.hidden = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_staticBGImageView.alpha = 1.0;
		_greenBGImageView.alpha = 1.0;
		_cancelButton.alpha = 1.0;
	}];
	
	textField.text = @"";
	textField.frame = CGRectMake(9.0, 11.0, 200.0, 24.0);
	[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honGreyTextColor]];
	[self.delegate searchBarViewHasFocus:self];
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
