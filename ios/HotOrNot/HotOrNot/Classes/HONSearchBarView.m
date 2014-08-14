//
//  HONSearchBarView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchBarView.h"

@interface HONSearchBarView ()
@property (nonatomic, strong) UIImageView *unfocusedBGImageView;
@property (nonatomic, strong) UIImageView *focusedBGImageView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchBarView
@synthesize delegate = _delegate;

- (id)initAsHighSchoolSearchWithFrame:(CGRect)frame {
	if ((self = [self initWithFrame:frame])) {
		_isUser = NO;
		
		_unfocusedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBG_clubs"]];
		_unfocusedBGImageView.userInteractionEnabled = YES;
		[self addSubview:_unfocusedBGImageView];
		
		_focusedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBG_blank"]];
		_focusedBGImageView.userInteractionEnabled = YES;
		_focusedBGImageView.alpha = 0.0;
		[self addSubview:_focusedBGImageView];
		
		_searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 11.0, 296.0, 22.0)];
		[_searchTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_searchTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_searchTextField setReturnKeyType:UIReturnKeyDefault];
		[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
		[_searchTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_searchTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		_searchTextField.keyboardType = UIKeyboardTypeAlphabet;
		_searchTextField.text = @"";
		_searchTextField.delegate = self;
		[self addSubview:_searchTextField];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(275.0, 0.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"xIcon"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"xIcon"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		_cancelButton.alpha = 0.0;
		[self addSubview:_cancelButton];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isUser = YES;
		
		_unfocusedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBG_users"]];
		_unfocusedBGImageView.userInteractionEnabled = YES;
		[self addSubview:_unfocusedBGImageView];
		
		_focusedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchInputBG_blank"]];
		_focusedBGImageView.userInteractionEnabled = YES;
		_focusedBGImageView.alpha = 0.0;
		[self addSubview:_focusedBGImageView];
		
		_searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 11.0, 296.0, 22.0)];
		[_searchTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_searchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_searchTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_searchTextField setReturnKeyType:UIReturnKeyDefault];
		[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
		[_searchTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_searchTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		_searchTextField.keyboardType = UIKeyboardTypeAlphabet;
		_searchTextField.text = @"";
		_searchTextField.delegate = self;
		[self addSubview:_searchTextField];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(275.0, 0.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"xIcon"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"xIcon"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		_cancelButton.alpha = 0.0;
		[self addSubview:_cancelButton];
	}
	
	return (self);
}


- (void)backgroundingReset {
	[_searchTextField resignFirstResponder];
	
	_searchTextField.text = @"";
	[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_cancelButton.alpha = 0.0;
		_focusedBGImageView.alpha = 0.0;
	}];
	
	_searchTextField.frame = CGRectMake(_searchTextField.frame.origin.x, _searchTextField.frame.origin.y, 296.0, _searchTextField.frame.size.height);
}


#pragma mark - Navigation
- (void)_goCancel {
	[_searchTextField resignFirstResponder];
	
	_searchTextField.text = @"";
	[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_cancelButton.alpha = 0.0;
		_focusedBGImageView.alpha = 0.0;
	}];
	
	_searchTextField.frame = CGRectMake(_searchTextField.frame.origin.x, _searchTextField.frame.origin.y, 296.0, _searchTextField.frame.size.height);
	
	if ([self.delegate respondsToSelector:@selector(searchBarViewCancel:)])
		[self.delegate searchBarViewCancel:self];
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	[_searchTextField resignFirstResponder];
	
	if ([_searchTextField.text length] > 0)
		[self.delegate searchBarView:self enteredSearch:_searchTextField.text];
	
	else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_cancelButton.alpha = 0.0;
			_focusedBGImageView.alpha = 0.0;
		}];
		
		_searchTextField.text = @"";
		_searchTextField.frame = CGRectMake(_searchTextField.frame.origin.x, _searchTextField.frame.origin.y, 296.0, _searchTextField.frame.size.height);
		[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
		
		if ([self.delegate respondsToSelector:@selector(searchBarViewCancel:)])
			[self.delegate searchBarViewCancel:self];
	}
}


#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_cancelButton.alpha = 1.0;
		_focusedBGImageView.alpha = 1.0;
	}];
	
	textField.text = @"";
	textField.frame = CGRectMake(_searchTextField.frame.origin.x, _searchTextField.frame.origin.y, 265.0, _searchTextField.frame.size.height);
	[_searchTextField setTextColor:[[HONColorAuthority sharedInstance] honGreyTextColor]];
	
	if ([self.delegate respondsToSelector:@selector(searchBarViewHasFocus:)])
		[self.delegate searchBarViewHasFocus:self];
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
