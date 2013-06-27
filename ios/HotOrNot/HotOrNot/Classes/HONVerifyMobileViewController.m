//
//  HONHONVerifyMobileViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.09.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMessageComposeViewController.h>

#import "UIImageView+AFNetworking.h"

#import "HONVerifyMobileViewController.h"
#import "HONAddFriendsViewController.h"


@interface HONVerifyMobileViewController () <MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, retain) UITextField *mobileTextField1;
@property (nonatomic, retain) UITextField *mobileTextField2;
@property (nonatomic, retain) UITextField *mobileTextField3;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic) float submitButtonOriginY;
@end

@implementation HONVerifyMobileViewController 

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Mobile Verification - Open"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	NSLog(@"frame:[%@] bounds:[%@]", NSStringFromCGRect(self.view.frame), NSStringFromCGRect([UIScreen mainScreen].bounds));
	
	[self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"firstRunBackground-568h" : @"firstRunBackground"]]];
	
	UIImageView *promoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 49.0, 320.0, 94.0)];
	[promoteImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate promoteInviteImageForType:1]] placeholderImage:nil];
	[self.view addSubview:promoteImageView];
	
	NSLog(@"URL:[%@]", [HONAppDelegate promoteInviteImageForType:1]);
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(252.0, 4.0, 64.0, 44.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:skipButton];
		
	UIButton *inputBGButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inputBGButton.frame = CGRectMake(37.0, 192.0, 244.0, 44.0);
	[inputBGButton setBackgroundImage:[UIImage imageNamed:@"mobileInput_nonActive"] forState:UIControlStateNormal];
	[inputBGButton setBackgroundImage:[UIImage imageNamed:@"mobileInput_Active"] forState:UIControlStateHighlighted];
	[inputBGButton addTarget:self action:@selector(_goTextfieldFocus) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:inputBGButton];
	
	_mobileTextField1 = [[UITextField alloc] initWithFrame:CGRectMake(45.0, 200.0, 35.0, 30.0)];
	[_mobileTextField1 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_mobileTextField1 setAutocorrectionType:UITextAutocorrectionTypeNo];
	_mobileTextField1.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_mobileTextField1 setReturnKeyType:UIReturnKeyGo];
	[_mobileTextField1 setTextColor:[HONAppDelegate honBlueTextColor]];
	[_mobileTextField1 addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_mobileTextField1 addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_mobileTextField1.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_mobileTextField1.keyboardType = UIKeyboardTypePhonePad;
	_mobileTextField1.text = @"";
	_mobileTextField1.delegate = self;
	[_mobileTextField1 setTag:0];
	[self.view addSubview:_mobileTextField1];
	
//	_mobileTextField2 = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 200.0, 35.0, 30.0)];
//	[_mobileTextField2 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//	[_mobileTextField2 setAutocorrectionType:UITextAutocorrectionTypeNo];
//	_mobileTextField2.keyboardAppearance = UIKeyboardAppearanceDefault;
//	[_mobileTextField2 setReturnKeyType:UIReturnKeyGo];
//	[_mobileTextField2 setTextColor:[HONAppDelegate honBlueTextColor]];
//	[_mobileTextField2 addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
//	[_mobileTextField2 addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	_mobileTextField2.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
//	_mobileTextField2.keyboardType = UIKeyboardTypePhonePad;
//	_mobileTextField2.text = @"";
//	_mobileTextField2.delegate = self;
//	[_mobileTextField2 setTag:1];
//	[self.view addSubview:_mobileTextField2];
//	
//	_mobileTextField3 = [[UITextField alloc] initWithFrame:CGRectMake(175.0, 200.0, 90.0, 30.0)];
//	[_mobileTextField3 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//	[_mobileTextField3 setAutocorrectionType:UITextAutocorrectionTypeNo];
//	_mobileTextField3.keyboardAppearance = UIKeyboardAppearanceDefault;
//	[_mobileTextField3 setReturnKeyType:UIReturnKeyGo];
//	[_mobileTextField3 setTextColor:[HONAppDelegate honBlueTextColor]];
//	[_mobileTextField3 addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
//	[_mobileTextField3 addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	_mobileTextField3.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
//	_mobileTextField3.keyboardType = UIKeyboardTypePhonePad;
//	_mobileTextField3.text = @"";
//	_mobileTextField3.delegate = self;
//	[_mobileTextField1 setTag:2];
//	[self.view addSubview:_mobileTextField3];
	
	_submitButtonOriginY = ([UIScreen mainScreen].bounds.size.height == self.view.frame.size.height) ? [UIScreen mainScreen].bounds.size.height - 53.0 : [UIScreen mainScreen].bounds.size.height - 73.0;
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, _submitButtonOriginY, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	//[_mobileTextField1 becomeFirstResponder];
//
//	_submitButton.hidden = NO;
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		//_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
//		_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY - 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);
//	}];
}


#pragma mark - Navigation
- (void)_goSMS {
	if ([MFMessageComposeViewController canSendText]) {
//		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//		pasteboard.persistent = YES;
//		pasteboard.image = [UIImage imageNamed:@"instagram_template-0001"];
//
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"sms:" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
		
		
		MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
		messageComposeViewController.messageComposeDelegate = self;
		messageComposeViewController.recipients = [NSArray arrayWithObject:@"2394313268"];
		messageComposeViewController.body = [NSString stringWithFormat:[HONAppDelegate smsInviteFormat], [[HONAppDelegate infoForUser] objectForKey:@"name"]];
		//messageComposeViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SMS Error"
															message:@"Cannot send SMS from this device!"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}


- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Mobile Verification - Skip"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																		 message:@"Really!? Volley is more fun with friends!"
																		delegate:self
															cancelButtonTitle:@"Cancel"
															otherButtonTitles:@"Yes, I'm Sure", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goTextfieldFocus {
	[_mobileTextField1 becomeFirstResponder];
}

- (void)_goNext {
	[_mobileTextField1 resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY + 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);//_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
	} completion:^(BOOL finished) {
		//_submitButton.hidden = YES;
	}];

	//[[[UIAlertView alloc] initWithTitle:@"Feature Disabled" message:@"This feature is turned off during testing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	[self.navigationController pushViewController:[[HONAddFriendsViewController alloc] init] animated:YES];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Mobile Verification - Skip Cancel"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Mobile Verification - Skip Confirm"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
				break;
		}
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = @"";
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY - 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);//_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY + 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);//_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
	} completion:^(BOOL finished) {
		//_submitButton.hidden = YES;
	}];
}

- (void)_onTextEditingDidEnd:(id)sender {
//	if ([_mobileTextField1.text length] > 0) {
//		_phoneNumber = _mobileTextField1.text;
//		
//		[[Mixpanel sharedInstance] track:@"Mobile Verification - Entered Mobile Number"
//									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
//													 _phoneNumber, @"mobile", nil]];
//		
//		[self _goNext];
//		
//	} else
//		_mobileTextField1.text = @"";
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	if ([_mobileTextField1.text length] > 0) {
		_phoneNumber = _mobileTextField1.text;
		
		[[Mixpanel sharedInstance] track:@"Mobile Verification - Entered Mobile Number"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													 _phoneNumber, @"mobile", nil]];
		
		//[self _goNext];
		
	} else
		_mobileTextField1.text = @"";
	
	
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"SMS: canceled");
			break;
			
		case MessageComposeResultSent:
			NSLog(@"SMS: sent");
			break;
			
		case MessageComposeResultFailed:
			NSLog(@"SMS: failed");
			break;
			
		default:
			NSLog(@"SMS: not sent");
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
	//[self _goNext];
}


@end
