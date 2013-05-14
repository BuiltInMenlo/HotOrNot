//
//  HONFindFriendsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.09.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONFindFriendsViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONImagingDepictor.h"
#import "HONUserVO.h"

@interface HONFindFriendsViewController () <UITextFieldDelegate, UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONFindFriendsViewController 

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - Data Calls
- (void)_checkUsername {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 8], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									_username, @"username",
									nil];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_checkUsername", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONFindFriendsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_usernameNotFound", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSLog(@"HONFindFriendsViewController AFNetworking: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null]) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_USER_CHALLENGE" object:[HONUserVO userWithDictionary:userResult]];
				}];
				
			} else {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_usernameNotFound", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONFindFriendsViewController AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];

}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"findFriendsBackground-568h@2x" : @"findFriendsBackground"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[headerView hideRefreshing];
	[self.view addSubview:headerView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 12.0, 200.0, 24.0)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:18];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = NSLocalizedString(@"header_findFriends", nil);
	[headerView addSubview:titleLabel];
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:skipButton];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(37.0, 399.0, 245.0, 36.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goInstagram) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:shareButton];
	
	/*
	UIImageView *subjectBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(34.0, 262.0, 251.0, 48.0)];
	subjectBGImageView.image = [UIImage imageNamed:@"firstRun_InputField_nonActive"];
	subjectBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:subjectBGImageView];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 12.0, 230.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeySend];
	[_usernameTextField setTextColor:[HONAppDelegate honGreyInputColor]];
	[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:18];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.textAlignment = NSTextAlignmentCenter;
	_usernameTextField.text = @"Input your friends @handle to start having fun.";//NSLocalizedString(@"register_username", nil);//[NSString stringWithFormat:([[_username substringToIndex:1] isEqualToString:@"@"]) ? @"%@" : @"@%@", _username];
	_usernameTextField.delegate = self;
	[subjectBGImageView addSubview:_usernameTextField];
	 */
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Find Friends - Skip"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

- (void)_goInstagram {
	[[Mixpanel sharedInstance] track:@"Find Friends - Instagram"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIImage *image = [HONImagingDepictor prepImageForInstagram:[UIImage imageNamed:@"instagram_template-0000"] avatarImage:[HONAppDelegate avatarImage] username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
	NSString *instaURL = @"instagram://app";
	NSString *instaFormat = @"com.instagram.exclusivegram";
	NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_instagram.igo"];
	
	[UIImageJPEGRepresentation(image, 1.0f) writeToFile:savePath atomically:YES];
	
	
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instaURL]]) {
		//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:instaURL]];
		
		_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
		_documentInteractionController.UTI = instaFormat;
		_documentInteractionController.delegate = self;
		_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[HONAppDelegate instagramShareComment] forKey:@"InstagramCaption"];
		[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_instagramError_t", nil)
																			 message:NSLocalizedString(@"alert_instagramError_m", nil)
																			delegate:nil
																cancelButtonTitle:nil
																otherButtonTitles:@"OK", nil];
		[alertView show];
	}
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_TO_INSTAGRAM" object:[NSDictionary dictionaryWithObjectsAndKeys:
																														 [HONAppDelegate instagramShareComment], @"caption",
																														 image, @"image", nil]];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = @"@";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 0) {
		if ([textField.text isEqualToString:@""])
			textField.text = @"@";
	}
	
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	//	if ([textField.text isEqualToString:@"@"] || [textField.text isEqualToString:NSLocalizedString(@"register_username", nil)])
	//		textField.text = [NSString stringWithFormat:@"@%@", _username];
	
	_username = ([[textField.text substringToIndex:1] isEqualToString:@"@"]) ? [textField.text substringFromIndex:1] : textField.text;	
	[[Mixpanel sharedInstance] track:@"Find Friends - Lookup Friend"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 _username, @"username", nil]];
	
	[textField resignFirstResponder];
	[self _checkUsername];
}
@end
