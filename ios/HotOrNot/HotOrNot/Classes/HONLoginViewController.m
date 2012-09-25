//
//  HONLoginViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ASIFormDataRequest.h"

#import "HONLoginViewController.h"
#import "HONAppDelegate.h"



@interface HONLoginViewController () <ASIHTTPRequestDelegate>

@end

@implementation HONLoginViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
	facebookButton.frame = CGRectMake(30.0, 250.0, 100.0, 48.0);
	[facebookButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
	[facebookButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];
	[facebookButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	//facebookButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	[facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
	[self.view addSubview:facebookButton];
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
- (void)_goFacebook {
	[FBSession openActiveSessionWithPermissions:[HONAppDelegate fbPermissions] allowLoginUI:YES completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
		 
		 NSLog(@"---------OPEN SESSION------------");
		 
		 if (FBSession.activeSession.isOpen) {
			 [[FBRequest requestForMe] startWithCompletionHandler:
			  ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
				if (!error) {
					NSLog(@"user [%@]", user);
					  
					[HONAppDelegate writeFBProfile:user];
					
					//if ([[HONAppDelegate infoForUser] objectForKey:@"id"] != @"1") {
						ASIFormDataRequest *userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kUsersAPI]]];
						[userRequest setDelegate:self];
						[userRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
						[userRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
						[userRequest setPostValue:[user objectForKey:@"first_name"] forKey:@"username"];
						[userRequest startAsynchronous];
					//}
				}
			}];
		 }
		 
		 
		 switch (state) {
			 case FBSessionStateOpen: {
				 FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
				 [cacheDescriptor prefetchAndCacheForSession:session];
				 				 
				 [self _goDone];
			 }
				 break;
			 case FBSessionStateClosed:
			 case FBSessionStateClosedLoginFailed:
				 break;
			 default:
				 break;
		 }
		 
		 //		 [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification object:session];
		 
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
	NSLog(@"HONLoginViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
