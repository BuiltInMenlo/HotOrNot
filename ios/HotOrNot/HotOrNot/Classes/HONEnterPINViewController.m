//
//  HONEnterPINViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/28/2014 @ 16:36 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONEnterPINViewController.h"
#import "HONAnalyticsParams.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONAllowContactsViewController.h"
#import "HONHeaderView.h"

@interface HONEnterPINViewController ()
@property (nonatomic, strong) NSString *pin;
@property (nonatomic, strong) UIButton *pinButton;
@property (nonatomic, strong) UITextField *pinTextField;
@end


@implementation HONEnterPINViewController

- (id)init {
	if ((self = [super init])) {
		
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Enter pin" hasTranslucency:NO];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 94.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
	
	
	_pinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_pinButton.frame = CGRectMake(0.0, 64.0, 320.0, 64.0);
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowPinBackround_nonActive"] forState:UIControlStateNormal];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowPinBackround_Active"] forState:UIControlStateHighlighted];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowPinBackround_Active"] forState:UIControlStateSelected];
	[self.view addSubview:_pinButton];
	
	_pinTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 82.0, 75.0, 30.0)];
	[_pinTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_pinTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_pinTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_pinTextField setReturnKeyType:UIReturnKeyDone];
	[_pinTextField setTextColor:[[HONColorAuthority sharedInstance] honDarkGreyTextColor]];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_pinTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_pinTextField.keyboardType = UIKeyboardTypeDecimalPad;
	_pinTextField.textAlignment = NSTextAlignmentCenter;
//	_pinTextField.placeholder = @"PIN";
	_pinTextField.text = @"";
	_pinTextField.delegate = self;
	[self.view addSubview:_pinTextField];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Validate PIN - Back" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goNext {
	[[Mixpanel sharedInstance] track:@"Validate PIN - Next" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[self.navigationController pushViewController:[[HONAllowContactsViewController alloc] init] animated:YES];
}

- (void)_goResend {
	[[Mixpanel sharedInstance] track:@"Validate PIN - Resend" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {

//		_usernameCheckImageView.alpha = 0.0;
		[_pinButton setSelected:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return (!([textField.text length] > 3 && [string length] > range.length));
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_pin = _pinTextField.text;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_pin = _pinTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}

@end
