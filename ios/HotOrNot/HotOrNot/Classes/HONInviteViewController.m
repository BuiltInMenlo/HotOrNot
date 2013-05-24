//
//  HONInviteViewController.m
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

#import "HONInviteViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONContactUserVO.h"

@interface HONInviteViewController ()
@property (nonatomic, strong) NSMutableArray *contactUsers;
@property (strong, nonatomic) FBRequestConnection *requestConnection;
@end

@implementation HONInviteViewController

@synthesize requestConnection = _requestConnection;

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Share Modal - Open"
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
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Share Volley"];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	
	UIButton *instagramButton = [UIButton buttonWithType:UIButtonTypeCustom];
	instagramButton.frame = CGRectMake(37.0, 100.0, 245.0, 36.0);
	[instagramButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[instagramButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[instagramButton addTarget:self action:@selector(_goInstagram) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:instagramButton];
	
	UIButton *kikButton = [UIButton buttonWithType:UIButtonTypeCustom];
	kikButton.frame = CGRectMake(37.0, 150.0, 245.0, 36.0);
	[kikButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[kikButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[kikButton addTarget:self action:@selector(_goKik) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:kikButton];
	
	UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	facebookButton.frame = CGRectMake(37.0, 200.0, 245.0, 36.0);
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:facebookButton];
	
	UIButton *contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	contactsButton.frame = CGRectMake(37.0, 250.0, 245.0, 36.0);
	[contactsButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_nonActive"] forState:UIControlStateNormal];
	[contactsButton setBackgroundImage:[UIImage imageNamed:@"tapToShareButton_Active"] forState:UIControlStateHighlighted];
	[contactsButton addTarget:self action:@selector(_goContacts) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:contactsButton];	
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

#pragma mark - Navigation
- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Share Modal - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goInstagram {
	[[Mixpanel sharedInstance] track:@"Share Modal - Instagram"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	UITextField *textField;
	UITextField *textField2;
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Instagram Login"
																	 message:@"\n\n\n"
																	delegate:nil
														cancelButtonTitle:@"Cancel"
														otherButtonTitles:@"OK", nil];
	
	textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];
	[textField setBackgroundColor:[UIColor whiteColor]];
	[textField setPlaceholder:@"username"];
	[prompt addSubview:textField];
								  
	textField2 = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 85.0, 260.0, 25.0)];
	[textField2 setBackgroundColor:[UIColor whiteColor]];
	[textField2 setPlaceholder:@"password"];
	[textField2 setSecureTextEntry:YES];
	[prompt addSubview:textField2];
	
	[prompt show];
								  
								  // set cursor and show keyboard [textField becomeFirstResponder];
}

- (void)_goKik {
	[[Mixpanel sharedInstance] track:@"Share Modal - Kik"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIImage *shareImage = [UIImage imageNamed:@"instagram_template-0000"];
	NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_test.jpg"];
	[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
	
	KikAPIMessage *myMessage = [KikAPIMessage message];
	myMessage.title = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]];
	myMessage.description = @"";
	myMessage.previewImage = UIImageJPEGRepresentation(shareImage, 1.0f);
	myMessage.filePath = savePath;
	myMessage.iphoneURIs = [NSArray arrayWithObjects:@"my iphone URI", nil];
	myMessage.genericURIs = [NSArray arrayWithObjects:@"my generic URI", nil];
	
	[KikAPIClient sendMessage:myMessage];

}

- (void)_goFacebook {
	[[Mixpanel sharedInstance] track:@"Share Modal - Facebook"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (FBSession.activeSession.isOpen)
		[self _callFB];
		
	else {
		[FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
			if (error) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
																				message:error.localizedDescription
																			  delegate:nil
																  cancelButtonTitle:@"OK"
																  otherButtonTitles:nil];
				[alert show];
	
			} else if (FB_ISSESSIONOPENWITHSTATE(status))
				[self _callFB];
		}];
	}
}

- (void)_goContacts {
	[[Mixpanel sharedInstance] track:@"Share Modal - Contacts"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
		ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
			[self _retrieveContacts];
		});
		
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		[self _retrieveContacts];
		
	} else {
		// denied access
	}
}

@end
