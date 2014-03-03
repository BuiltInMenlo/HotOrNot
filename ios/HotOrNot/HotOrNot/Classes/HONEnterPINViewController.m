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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Enter pin"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 94.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
	
	
	_pinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_pinButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowPinBackround_nonActive"] forState:UIControlStateNormal];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowPinBackround_Active"] forState:UIControlStateHighlighted];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowPinBackround_Active"] forState:UIControlStateSelected];
	[self.view addSubview:_pinButton];
	
	_pinTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 94.0, 77.0, 30.0)];
	[_pinTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_pinTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_pinTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_pinTextField setReturnKeyType:UIReturnKeyDone];
	[_pinTextField setTextColor:[[HONColorAuthority sharedInstance] honDarkGreyTextColor]];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_pinTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:19];
	_pinTextField.keyboardType = UIKeyboardTypeDecimalPad;
	_pinTextField.textAlignment = NSTextAlignmentCenter;
	_pinTextField.text = @"";
	_pinTextField.delegate = self;
	[self.view addSubview:_pinTextField];
	
	
	UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	resendButton.frame = CGRectMake(234.0, 88.0, 74.0, 44.0);
	[resendButton setBackgroundImage:[UIImage imageNamed:@"resendButton_nonActive"] forState:UIControlStateNormal];
	[resendButton setBackgroundImage:[UIImage imageNamed:@"resendButton_Active"] forState:UIControlStateHighlighted];
	[resendButton addTarget:self action:@selector(_goResend) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:resendButton];
	
	[_pinTextField becomeFirstResponder];
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
	
	_pin = _pinTextField.text;
	if ([_pin length] < 4) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid Pin!"
									message:@"Pin numbers need to be 4 numbers"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else
		[self.navigationController pushViewController:[[HONAllowContactsViewController alloc] init] animated:YES];
}

- (void)_goResend {
	[[Mixpanel sharedInstance] track:@"Validate PIN - Resend" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	_pinTextField.text = @"";
	[_pinTextField resignFirstResponder];
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
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
	[_pinButton setSelected:NO];
	
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
