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
#import "HONAppDelegate.h"
#import "HONAddFriendsViewController.h"

@interface HONVerifyMobileViewController () <MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, retain) UITextField *mobileTextField;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) UIButton *submitButton;
@end

@implementation HONVerifyMobileViewController 

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Find Friends - Open"
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
	
	[self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"firstRunBackground-568h" : @"firstRunBackground"]]];
	
	UIImageView *promoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 35.0, 320.0, 94.0)];
	[promoteImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate promoteInviteImageForType:1]] placeholderImage:nil];
	[self.view addSubview:promoteImageView];
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(253.0, 3.0, 64.0, 44.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:skipButton];
	
	UIButton *inputBGButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inputBGButton.frame = CGRectMake(38.0, 220.0, 244.0, 44.0);
	[inputBGButton setBackgroundImage:[UIImage imageNamed:@"mobileInput_nonActive"] forState:UIControlStateNormal];
	[inputBGButton setBackgroundImage:[UIImage imageNamed:@"mobileInput_Active"] forState:UIControlStateHighlighted];
	[inputBGButton addTarget:self action:@selector(_goTextfieldFocus) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:inputBGButton];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 53.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
	
//	_mobileTextField = [[UITextField alloc] initWithFrame:CGRectMake(61.0, 220.0, 230.0, 30.0)];
//	//[_mobileTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//	[_mobileTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//	[_mobileTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
//	_mobileTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
//	[_mobileTextField setReturnKeyType:UIReturnKeyGo];
//	[_mobileTextField setTextColor:[HONAppDelegate honBlueTxtColor]];
//	//[_mobileTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEnd];
//	_mobileTextField.font = [[HONAppDelegate cartoGothicBook] fontWithSize:18];
//	_mobileTextField.keyboardType = UIKeyboardTypeDefault;//UIKeyboardTypePhonePad;
//	_mobileTextField.text = @"";
//	_mobileTextField.delegate = self;
//	[self.view addSubview:_mobileTextField];
}

- (void)viewDidLoad {
	[super viewDidLoad];
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
	[[Mixpanel sharedInstance] track:@"Find Friends - Skip"
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
	if (![_mobileTextField isFirstResponder]) {
		[_mobileTextField becomeFirstResponder];
		
		_submitButton.hidden = NO;
		[UIView animateWithDuration:0.25 animations:^(void) {
			_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
		}];
	}
}

- (void)_goNext {
	//[[[UIAlertView alloc] initWithTitle:@"Feature Disabled" message:@"This feature is turned off during testing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	[self.navigationController pushViewController:[[HONAddFriendsViewController alloc] init] animated:YES];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Find Friends - Skip Cancel"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Find Friends - Skip Confirm"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
				break;
		}
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = @"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if ([textField.text length] > 0) {
		_phoneNumber = textField.text;
		[[Mixpanel sharedInstance] track:@"Find Friends - Entered Mobile Number"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													 _phoneNumber, @"mobile", nil]];
		
		//[textField resignFirstResponder];
		[self _goNext];
		
	} else
		textField.text = @"";
}

- (void)_onTxtDoneEditing:(id)sender {
	[_mobileTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
	}];
	[self _goNext];
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
