//
//  HONLoginViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"

#import "HONLoginViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"


@interface HONLoginViewController ()
@end

@implementation HONLoginViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[[Mixpanel sharedInstance] track:@"FB Login"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	NSString *bgAsset = ([HONAppDelegate isRetina5]) ? @"facebookBackground-568h@2x" : @"facebookBackground";
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, ([HONAppDelegate isRetina5]) ? 523.0 : 425.0)];
	bgImgView.image = [UIImage imageNamed:bgAsset];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Facebook"];
	[headerView hideRefreshing];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	facebookButton.frame = CGRectMake(27.0, ([HONAppDelegate isRetina5]) ? 471.0 : 382.0, 264.0, 64.0);
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"connectFacebook_nonActive"] forState:UIControlStateNormal];
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"connectFacebook_Active"] forState:UIControlStateHighlighted];
	[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:facebookButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
		
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_goDone)];
}


#pragma mark - Navigation
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goCancel {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goFacebook {
	[[Mixpanel sharedInstance] track:@"Login Facebook Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[FBSession openActiveSessionWithPublishPermissions:[HONAppDelegate fbPermissions]
												  defaultAudience:FBSessionDefaultAudienceEveryone
													  allowLoginUI:YES
												completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//	[FBSession openActiveSessionWithPermissions:[HONAppDelegate fbPermissions] allowLoginUI:YES completionHandler:
//	 ^(FBSession *session, FBSessionState state, NSError *error) {
		 NSLog(@"///////////// OPEN SESSION /////////////");
		 
		 if (FBSession.activeSession.isOpen) {
			 [[FBRequest requestForMe] startWithCompletionHandler:
			  ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
				if (!error) {
					//NSLog(@"user [%@]", user);
					  
					[HONAppDelegate writeFBProfile:user];
					[HONAppDelegate setAllowsFBPosting:YES];
					
					//[[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_FB_POSTING" object:nil];
					//if ([[HONAppDelegate infoForUser] objectForKey:@"id"] != @"1") {
					
					AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
					NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
													[NSString stringWithFormat:@"%d", 2], @"action",
													[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
													[user objectForKey:@"username"], @"username",
													[user objectForKey:@"id"], @"fbID",
													[[[user objectForKey:@"gender"] uppercaseString] substringToIndex:1], @"gender",
													nil];
					
					[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
						NSError *error = nil;
						if (error != nil) {
							NSLog(@"HONLoginViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
							
						} else {
							NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
							//NSLog(@"HONLoginViewController AFNetworking: %@", userResult);
							
							if ([userResult objectForKey:@"id"] != [NSNull null])
								[HONAppDelegate writeUserInfo:userResult];
						}
						
					} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
						NSLog(@"LoginViewController AFNetworking %@", [error localizedDescription]);
					}];
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


@end
