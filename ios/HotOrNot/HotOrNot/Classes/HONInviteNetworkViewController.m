//
//  HONInviteNetworkViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.26.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <FacebookSDK/FacebookSDK.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "KikAPI.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONInviteNetworkViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONContactUserVO.h"
#import "HONInviteNetworkViewCell.h"

@interface HONInviteNetworkViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *contactUsers;
@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation HONInviteNetworkViewController

@synthesize requestConnection = _requestConnection;

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Invite Friends - Open"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[_requestConnection cancel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - Data Calls
- (void)_callFB {
	FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
	FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"/me/friends"];
	[newConnection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (self.requestConnection && connection != self.requestConnection)
			return;
		
		self.requestConnection = nil;
		
		if (error == nil) {
			int cnt = 0;
			NSMutableArray *friends = [NSMutableArray array];
			for (NSDictionary *dict in [(NSDictionary *)result objectForKey:@"data"]) {
				[friends addObject:[dict objectForKey:@"id"]];
				
				cnt++;
				if (cnt == 50)
					break;
			}
			
			//FBFrictionlessRecipientCache *friendCache = [[FBFrictionlessRecipientCache alloc] init];
			//[friendCache prefetchAndCacheForSession:nil];
			
			//NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[friends componentsJoinedByString:@","], @"to", nil];
			NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1554917948", @"to", nil];
			[FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Come snap @ me in Volley!" title:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
				if (error)
					NSLog(@"Error sending request.");
				
			 	else
					NSLog((result == FBWebDialogResultDialogNotCompleted) ? @"User canceled request." : @"Request Sent.");
			}];
		}
		
		NSLog(@"%@", (error) ? error.localizedDescription : (NSDictionary *)result);
	}];
	
	[self.requestConnection cancel];
	self.requestConnection = newConnection;
	[newConnection start];
}


#pragma mark - Device Functions
- (void)_retrieveContacts {
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	
	for (int i=0; i<nPeople; i++) {
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		
		NSString *fName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		NSString *lName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
		
		if ([fName length] == 0 || [lName length] == 0)
			continue;
		
		ABMultiValueRef phoneProperties = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		CFIndex phoneCount = ABMultiValueGetCount(phoneProperties);
		
		NSString *phoneNumber = @"";
		for(CFIndex j=0; j<phoneCount; j++) {
			NSString *mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneProperties, j);
			if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
				
			} else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
				phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneProperties, j);
				break ;
			}
		}
		CFRelease(phoneProperties);
		
		
		NSString *email = @"";
		ABMultiValueRef emailProperties = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex emailCount = ABMultiValueGetCount(emailProperties);
		
		if (emailCount > 0) {
			for (CFIndex j=0; j<emailCount; j++) {
				email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailProperties, j);
			}
		}
		CFRelease(emailProperties);
		
		if ([phoneNumber length] > 0 || [email length] > 0) {
			[_contactUsers addObject:[HONContactUserVO contactWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																									fName, @"f_name",
																									lName, @"l_name",
																									phoneNumber, @"phone",
																									email, @"email", nil]]];
		}
	}
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [HONAppDelegate honGreenColor];
	
	UIImageView *promoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 35.0, 320.0, 94.0)];
	[promoteImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate promoteInviteImageForType:0]] placeholderImage:nil];
	[self.view addSubview:promoteImageView];
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(253.0, 3.0, 64.0, 44.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:skipButton];
	
	
	//_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 100.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (100.0 + (kNavBarHeaderHeight + kTabSize.height))) style:UITableViewStylePlain];
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 116.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 116.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Skip"
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

- (void)_goContacts {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Contacts"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _showDisabledAlert];
//	ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
//		ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//			[self _retrieveContacts];
//		});
//		
//	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
//		[self _retrieveContacts];
//		
//	} else {
//		// denied access
//	}
}

- (void)_goInstagram {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Instagram"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
//	UITextField *textField;
//	UITextField *textField2;
//	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Instagram Login"
//																	 message:@"\n\n\n"
//																	delegate:nil
//														cancelButtonTitle:@"Cancel"
//														otherButtonTitles:@"OK", nil];
//	
//	textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];
//	[textField setBackgroundColor:[UIColor whiteColor]];
//	[textField setPlaceholder:@"username"];
//	[prompt addSubview:textField];
//								  
//	textField2 = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 85.0, 260.0, 25.0)];
//	[textField2 setBackgroundColor:[UIColor whiteColor]];
//	[textField2 setPlaceholder:@"password"];
//	[textField2 setSecureTextEntry:YES];
//	[prompt addSubview:textField2];
//	
//	[prompt show];
	
	[self _showDisabledAlert];
}

- (void)_goFacebook {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Facebook"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _showDisabledAlert];
	
//	if (FBSession.activeSession.isOpen)
//		[self _callFB];
//		
//	else {
//		[FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//			if (error) {
//				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//																				message:error.localizedDescription
//																			  delegate:nil
//																  cancelButtonTitle:@"OK"
//																  otherButtonTitles:nil];
//				[alert show];
//	
//			} else if (FB_ISSESSIONOPENWITHSTATE(status))
//				[self _callFB];
//		}];
//	}
}

- (void)_goTumblr {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Tumblr"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _showDisabledAlert];
}

- (void)_goTwitter {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Twitter"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _showDisabledAlert];
}

- (void)_goKik {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Kik"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _showDisabledAlert];
	
//	UIImage *shareImage = [UIImage imageNamed:@"instagram_template-0000"];
//	NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_test.jpg"];
//	[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
//	
//	KikAPIMessage *myMessage = [KikAPIMessage message];
//	myMessage.title = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]];
//	myMessage.description = @"";
//	myMessage.previewImage = UIImageJPEGRepresentation(shareImage, 1.0f);
//	myMessage.filePath = savePath;
//	myMessage.iphoneURIs = [NSArray arrayWithObjects:@"my iphone URI", nil];
//	myMessage.genericURIs = [NSArray arrayWithObjects:@"my generic URI", nil];
//	
//	[KikAPIClient sendMessage:myMessage];
}


#pragma mark - UI Presentation
- (void)_showDisabledAlert {
	[[[UIAlertView alloc] initWithTitle:@"Feature Disabled" message:@"This feature is turned off during testing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (6);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBackground"]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 310.0, 29.0)];
	label.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:15];
	label.textColor = [HONAppDelegate honBlueTxtColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = @"Promote Volley";
	[headerImageView addSubview:label];

	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONInviteNetworkViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	NSDictionary *dict;
	
	if (cell == nil)
		cell = [[HONInviteNetworkViewCell alloc] init];
	
	if (indexPath.row == 0) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				  @"icon_SMS", @"image",
				  @"SMS Contacts", @"name", nil];
		
	} else if (indexPath.row == 1) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				  @"icon_Instagram", @"image",
				  @"Instagram", @"name", nil];
		
	} else if (indexPath.row == 2) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"icon_Facebook", @"image",
				@"Facebook", @"name", nil];
		
	} else if (indexPath.row == 3) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				  @"icon_Tumblr", @"image",
				  @"Tumblr", @"name", nil];
		
	} else if (indexPath.row == 4) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				  @"icon_Twitter", @"image",
				  @"Twitter", @"name", nil];
		
	} else if (indexPath.row == 5) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				  @"icon_Kik", @"image",
				  @"Kik", @"name", nil];
	}
	
	[cell setContents:dict];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.row == 0) {
		[self _goContacts];
		
	} else if (indexPath.row == 1) {
		[self _goInstagram];
		
	} else if (indexPath.row == 2) {
		[self _goFacebook];
		
	} else if (indexPath.row == 3) {
		[self _goTumblr];
		
	} else if (indexPath.row == 4) {
		[self _goTwitter];
		
	} else if (indexPath.row == 5) {
		[self _goKik];
	}
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Invite Friends - Skip Cancel"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Invite Friends - Skip Confirm"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
				break;
		}
	}
}

@end
