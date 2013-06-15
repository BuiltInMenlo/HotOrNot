//
//  HONRestrictedLocaleViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.13.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONRestrictedLocaleViewController.h"
#import "HONAppDelegate.h"

@interface HONRestrictedLocaleViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation HONRestrictedLocaleViewController

- (id)init {
	if((self = [super init])) {
		
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	_bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
	_bgImageView.userInteractionEnabled = YES;
	[self.view addSubview:_bgImageView];
	
	UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 180.0, 280.0, 30.0)];
	captionLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:11];
	captionLabel.textColor = [HONAppDelegate honGrey635Color];
	captionLabel.backgroundColor = [UIColor clearColor];
	captionLabel.textAlignment = NSTextAlignmentCenter;
	captionLabel.numberOfLines = 0;
	captionLabel.text = NSLocalizedString(@"restricted_caption", nil);
	[self.view addSubview:captionLabel];
	
	_textField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 300.0, 280.0, 20.0)];
	//[_textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_textField setReturnKeyType:UIReturnKeyDone];
	[_textField setTextColor:[HONAppDelegate honGrey518Color]];
	[_textField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_textField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:13];
	_textField.keyboardType = UIKeyboardTypeDefault;
	_textField.textAlignment = NSTextAlignmentCenter;
	_textField.text = NSLocalizedString(@"restricted_inviteCode", nil);
	_textField.delegate = self;
	[_textField setTag:0];
	[_bgImageView addSubview:_textField];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(20.0, 400.0, 280.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_bgImageView addSubview:submitButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Locale Restriction - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 _textField.text, @"code", nil]];
	
	[_textField resignFirstResponder];
	if ([_textField.text isEqualToString:@""])
		_textField.text = NSLocalizedString(@"restricted_inviteCode", nil);
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, 0.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
	}];
	
	if ([HONAppDelegate isInviteCodeValid:_textField.text]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			//[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_invite"];
			//[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_REGISTRATION" object:nil];
		}];
	
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Invalid Code"
											 message:@"That invite code won't work!"
											delegate:nil
								cancelButtonTitle:@"OK"
								otherButtonTitles:nil]
		 show];
	}
}

-(void)_onTxtDoneEditing:(id)sender {
	[_textField resignFirstResponder];
	
	[self _goSubmit];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = @"";
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, _bgImageView.frame.origin.y - 215.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
}

@end