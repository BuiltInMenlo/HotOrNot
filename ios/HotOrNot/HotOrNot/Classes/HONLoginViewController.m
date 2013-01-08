//
//  HONLoginViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONLoginViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"


@interface HONLoginViewController () <ASIHTTPRequestDelegate>
@end

@implementation HONLoginViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	[[Mixpanel sharedInstance] track:@"Login Screen"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	NSString *bgAsset = ([HONAppDelegate isRetina5]) ? @"facebookBackground-568h" : @"facebookBackground";
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 548.0 : 470.0)];
	bgImgView.image = [UIImage imageNamed:bgAsset];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"FACEBOOK"];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 55.0, 300.0, 264.0)];
	imageView.backgroundColor = [UIColor blackColor];
	[imageView setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil];
	[self.view addSubview:imageView];
	
	UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	facebookButton.frame = CGRectMake(19.0, 365.0, 283.0, 74.0);
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"connectFacebook_nonActive"] forState:UIControlStateNormal];
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"connectFacebook_Active"] forState:UIControlStateHighlighted];
	[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:facebookButton];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
}

- (void)viewDidLoad {
	[super viewDidLoad];
		
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_goDone)];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)_goCancel {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goFacebook {
	[[Mixpanel sharedInstance] track:@"Login Facebook Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[FBSession openActiveSessionWithPermissions:[HONAppDelegate fbPermissions] allowLoginUI:YES completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
		 NSLog(@"///////////// OPEN SESSION /////////////");
		 
		 if (FBSession.activeSession.isOpen) {
			 [[FBRequest requestForMe] startWithCompletionHandler:
			  ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
				if (!error) {
					NSLog(@"user [%@]", user);
					  
					[HONAppDelegate writeFBProfile:user];
					[HONAppDelegate setAllowsFBPosting:YES];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_FB_POSTING" object:nil];
					//[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
					//if ([[HONAppDelegate infoForUser] objectForKey:@"id"] != @"1") {
						ASIFormDataRequest *userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
						[userRequest setDelegate:self];
						[userRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
						[userRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
						[userRequest setPostValue:[user objectForKey:@"username"] forKey:@"username"];
						[userRequest setPostValue:[user objectForKey:@"id"] forKey:@"fbID"];
						[userRequest setPostValue:[[[user objectForKey:@"gender"] uppercaseString] substringToIndex:1] forKey:@"gender"];
						[userRequest startAsynchronous];
					//}
				}
			}];
		 }
		 
		 
		 switch (state) {
			 case FBSessionStateOpen: {
				 NSLog(@"--FBSessionStateOpen--Login");
				 FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
				 [cacheDescriptor prefetchAndCacheForSession:session];
				 				 
				 [self _goDone];
			 }
				 break;
			 case FBSessionStateClosed:
				 NSLog(@"--FBSessionStateClosed--Login");
				 break;
				 
			 case FBSessionStateClosedLoginFailed:
				 NSLog(@"--FBSessionStateClosedLoginFailed--Login");
				 break;
			 default:
				 break;
		 }
		 
		 [[NSNotificationCenter defaultCenter] postNotificationName:HONSessionStateChangedNotification object:session];
		 
		 if (error) {
			 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																				  message:error.localizedDescription
																				 delegate:nil
																	 cancelButtonTitle:@"OK"
																	 otherButtonTitles:nil];
			 [alertView show];
		 }
	 }];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"HONLoginViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			[HONAppDelegate writeUserInfo:userResult];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
